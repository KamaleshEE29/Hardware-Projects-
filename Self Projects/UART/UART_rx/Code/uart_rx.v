
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////


/* Add your logic here */

reg [4:0] clk_counter = 5'b0;
reg [3:0] bit_counter = 4'b0;

reg rx_active = 1'b0;
reg [7:0]rx_temp = 8'b0;
reg rx_par_temp = 1'b0;

always @(posedge clk_3125) begin
	// Block to pull rx_complete low after one clock cycle
	if (rx_complete) begin
		rx_complete <= 1'b0;
	end

	// Block to start receiving data
	if (!rx && !rx_active) begin
		rx_active <= 1'b1;
//		clk_counter <= 11111;
//		clk_counter <= clk_counter + 1;
//		if (!rx && !rx_active && clk_counter == 13) rx_active <= 1'b1;
	end
	
	// Block to process received bits
	if (rx_active) begin
		clk_counter <= clk_counter + 1;
		
		if (clk_counter == 26) begin
			bit_counter <= bit_counter + 1;
			clk_counter <= 5'b0;
		end
		if (clk_counter == 13) begin
			case (bit_counter) 
				0: ;								// Start Bit
				1: rx_temp[7] <= rx;			// LSB (check once with sim)
				2: rx_temp[6] <= rx;
				3: rx_temp[5] <= rx;
				4: rx_temp[4] <= rx;
				5: rx_temp[3] <= rx;
				6: rx_temp[2] <= rx;
				7: rx_temp[1] <= rx;
				8: rx_temp[0] <= rx;			// MSB
				9: rx_par_temp <= rx;		// Parity
//				10: begin						// Stop bit
//					if (clk_counter == 26) begin
//						rx_complete <= 1'b1;	
//						rx_msg <= rx_temp;
//						rx_parity <= ^(rx_temp);
//						bit_counter <= 4'b0;
//						rx_active <= 1'b0;
//						clk_counter <= 5'b1;
//					end
//				end
			endcase
		end
		
		if (bit_counter == 10) begin
			if (clk_counter == 26) begin
				rx_complete <= 1'b1;	
				rx_msg <= rx_temp;
				rx_parity <= ^(rx_temp);
				bit_counter <= 4'b0;
				rx_active <= 1'b0;
				clk_counter <= 5'b1;
			end
		end
	end
	
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
