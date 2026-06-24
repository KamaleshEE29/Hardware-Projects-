module t2a_dht(
    input clk_50M,
    input reset,
    inout sensor,
    output reg [7:0] T_integral,
    output reg [7:0] RH_integral,
    output reg [7:0] T_decimal,
    output reg [7:0] RH_decimal,
    output reg [7:0] Checksum,
    output reg data_valid
);

    initial begin
        T_integral = 0;
        RH_integral = 0;
        T_decimal = 0;
        RH_decimal = 0;
        Checksum = 0;
        data_valid = 0;
    end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

parameter CLK_PER_US = 50;
parameter INIT_LOW_USEC  = 18000;
parameter INIT_HIGH_USEC = 40;
parameter BITCOUNT       = 40;

parameter S_INIT_LOW    = 3'd0,
          S_INIT_HIGH   = 3'd1,
          S_RESP_LOW    = 3'd2,
          S_RESP_HIGH   = 3'd3,
          S_SAMPLE      = 3'd4,
          S_DELAY       = 3'd5,
          S_OUTPUT      = 3'd6,
          S_WAIT_IDLE   = 3'd7;

reg [2:0] state;
reg sensor_driven;
reg sensor_out_val;
wire sensor_in;
/* single shared counter: 20 bits enough for 900k cycles (18ms) and 3500 pulse counts */
reg [19:0] counter;
reg [5:0]  bits_read;
reg [39:0] data_shift;

assign sensor = sensor_driven ? sensor_out_val : 1'bz;
assign sensor_in = sensor;

always @(posedge clk_50M or negedge reset) begin
    if (!reset) begin
        state <= S_INIT_LOW;
        sensor_driven <= 1'b1;
        sensor_out_val <= 1'b0;
        counter <= 0;
        bits_read <= 0;
        data_shift <= 0;
        T_integral <= 0;
        RH_integral <= 0;
        T_decimal <= 0;
        RH_decimal <= 0;
        Checksum <= 0;
        data_valid <= 0;
    end else begin

        data_valid <= 0;

        case(state)

        S_INIT_LOW: begin
            sensor_driven <= 1'b1;
            sensor_out_val <= 1'b0;
            if (counter < CLK_PER_US*INIT_LOW_USEC)
                counter <= counter + 1;
            else begin
                counter <= 0;
                state <= S_INIT_HIGH;
            end
        end

        S_INIT_HIGH: begin
            sensor_driven <= 1'b1;
            sensor_out_val <= 1'b1;
            if (counter < CLK_PER_US*INIT_HIGH_USEC)
                counter <= counter + 1;
            else begin
                counter <= 0;
                sensor_driven <= 1'b0;
                state <= S_RESP_LOW;
            end
        end

        S_RESP_LOW: begin
            if (!sensor_in)
                counter <= counter + 1;
            else if (counter > 5) begin
                counter <= 0;
                state <= S_RESP_HIGH;
            end
        end

        S_RESP_HIGH: begin
            if (sensor_in)
                counter <= counter + 1;
            else if (counter > 5) begin
                counter <= 0;
                bits_read <= 0;
                data_shift <= 0;
                state <= S_SAMPLE;
            end
        end

        S_SAMPLE: begin
            if (bits_read < BITCOUNT) begin
                if (sensor_in) begin
                    /* count HIGH pulse length in same counter */
                    counter <= counter + 1;
                end
                else if (counter != 0) begin
                    /* HIGH finished: decide bit */
                    if (counter > (CLK_PER_US*40))
                        data_shift <= {data_shift[38:0],1'b1};
                    else
                        data_shift <= {data_shift[38:0],1'b0};
                    counter <= 0;
                    bits_read <= bits_read + 1;
                end
            end else begin
                state <= S_DELAY;
            end
        end

        S_DELAY: begin
            state <= S_OUTPUT;
        end

        S_OUTPUT: begin
            RH_integral <= data_shift[39:32];
            RH_decimal  <= data_shift[31:24];
            T_integral  <= data_shift[23:16];
            T_decimal   <= data_shift[15:8];
            Checksum    <= data_shift[7:0];

            if (data_shift[7:0] ==
               (data_shift[39:32] + data_shift[31:24] +
                data_shift[23:16] + data_shift[15:8]))
                data_valid <= 1'b1;

            state <= S_WAIT_IDLE;
        end

        S_WAIT_IDLE: begin
            if (!sensor_driven) begin
                state <= S_INIT_LOW;
                counter <= 0;
                bits_read <= 0;
                data_shift <= 0;
            end
        end

        endcase
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////
endmodule
