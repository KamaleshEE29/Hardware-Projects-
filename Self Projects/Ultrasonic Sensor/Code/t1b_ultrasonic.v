/*
Module HC_SR04 Ultrasonic Sensor

This module will detect objects present in front of the range, and give the distance in mm.

Input:  clk_50M - 50 MHz clock
        reset   - reset input signal (Use negative reset)
        echo_rx - receive echo from the sensor

Output: trig    - trigger sensor for the sensor
        op     -  output signal to indicate object is present.
        distance_out - distance in mm, if object is present.
*/

// module Declaration
module t1b_ultrasonic(
    input clk_50M, reset, echo_rx,
    output reg trig,
    output op,
    output wire [15:0] distance_out
);

initial begin
    trig = 0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

localparam TRIGGER_PREV = 2'b00 ; 
localparam TRIGGER = 2'b01 ; 
localparam ECHO_CHK = 2'b10 ;

localparam TRIGGER_PREV_TIME = 50; 
localparam TRIGGER_TIME = 500; 
localparam ECHO_CHK_TIME = 600001; 

reg [1:0] state = TRIGGER_PREV; 
reg [21:0] counter = 22'b0; 
reg [21:0] echo_counter = 22'b0; 
reg [15:0] distance_storage = 16'b0 ;

assign op = distance_out <= 70 ; 
assign distance_out = distance_storage ;  

always@(posedge clk_50M or negedge reset) begin 
	if(!reset) begin 
		state <= TRIGGER_PREV ; 
		counter <= 22'b0 ; 
		echo_counter <= 22'b0 ; 
		distance_storage <= 16'b0 ; 
	end 
	else begin
		case(state) 
			TRIGGER_PREV : begin 
				trig <= 0 ; 
				counter <= counter + 22'b1 ;
				if(counter >= TRIGGER_PREV_TIME) begin 
					counter <= 22'b0 ;
					state <= TRIGGER ; 
				end 
			end 
			
			TRIGGER : begin 
				trig <= 1 ; 
				counter <= counter + 22'b1; 
				if(counter >= TRIGGER_TIME) begin
						trig <= 0 ; 
						counter <= 22'b0 ;
						state <= ECHO_CHK ; 
				end 
			end 
			ECHO_CHK : begin 
				trig <= 0 ; 
				counter <= counter + 22'b1 ; 
				if(counter >= ECHO_CHK_TIME) begin 
					state <= TRIGGER_PREV ;
					echo_counter <= 22'b0 ; 
					counter <= 22'b0  ;
				end
				else if(echo_rx) begin 
					echo_counter <= echo_counter + 22'b1; 
				end 
				else begin 
					distance_storage <= ((echo_counter)*34)/10000 ;
				end
			end
		endcase 
	end 
end		
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule