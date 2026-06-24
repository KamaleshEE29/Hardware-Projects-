
// data_mem.v - data memory

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input       clk, wr_en,
	 input 		 [2:0] func3,
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    output reg  [DATA_WIDTH-1:0] rd_data_mem
);

// array of 64 32-bit words or data
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

wire [ADDR_WIDTH-1:0] word_address = wr_addr[DATA_WIDTH-1:2] % 64;



always @(posedge clk) begin
    if (wr_en) begin 
        case (func3)
            3'b000: data_ram[word_address] <= (data_ram[word_address] & ~(8'b11111111 << (wr_addr[1:0] * 8))) | (wr_data[7:0] << (wr_addr[1:0] * 8)); // sb
            3'b001: data_ram[word_address] <= (data_ram[word_address] & ~(16'b1111111111111111 << (wr_addr[1] * 16))) | (wr_data[15:0] << (wr_addr[1] * 16)); // sh
            3'b010: data_ram[word_address] <= wr_data; // sw
        endcase
    end
end


always @(*) begin
    case (func3)
        3'b000: begin //lb
            case (wr_addr[1:0])
                2'b00: rd_data_mem = {{24{data_ram[word_address][ 7]}} ,data_ram[word_address][ 7: 0]};
                2'b01: rd_data_mem = {{24{data_ram[word_address][15]}} ,data_ram[word_address][15: 8]};
                2'b10: rd_data_mem = {{24{data_ram[word_address][23]}} ,data_ram[word_address][23:16]};
                2'b11: rd_data_mem = {{24{data_ram[word_address][31]}} ,data_ram[word_address][31:24]};
            endcase
        end

        3'b001: begin //lh
            case (wr_addr[1])
                1'b0: rd_data_mem = {{16{data_ram[word_address][ 15]}} ,data_ram[word_address][15: 0]};
                1'b1: rd_data_mem = {{16{data_ram[word_address][ 31]}} ,data_ram[word_address][31:16]};
            endcase
        end

        3'b010: begin //lw
				rd_data_mem = data_ram[word_address]; 
		  end
				
        3'b100: begin //lbu
            case (wr_addr[1:0])
                2'b00: rd_data_mem = {24'b0 ,data_ram[word_address][ 7: 0]};
                2'b01: rd_data_mem = {24'b0 ,data_ram[word_address][15: 8]};
                2'b10: rd_data_mem = {24'b0 ,data_ram[word_address][23:16]};
                2'b11: rd_data_mem = {24'b0 ,data_ram[word_address][31:24]};
            endcase
        end

        3'b101: begin //lhu
            case (wr_addr[1])
                1'b0: rd_data_mem = {16'b0 ,data_ram[word_address][15: 0]};
                1'b1: rd_data_mem = {16'b0 ,data_ram[word_address][31:16]};
            endcase
        end


    endcase

end

endmodule


