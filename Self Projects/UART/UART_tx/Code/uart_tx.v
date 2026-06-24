// MazeSolver Bot: Task 2B - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag


        Baudrate : 115200 bps
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

initial begin
    tx = 1'b1;
    tx_done = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
 
 /*  Add your logic here */

reg tx_active;

reg [4:0]clk_counter;
reg [3:0]bit_counter;

always @(posedge clk_3125) begin
	
	// Block to close off the current data packet
	if (tx_done) begin
		tx_done <= 1'b0;
		tx <= 1'b1;
	end
	
	// Block to start transmission
	if (tx_start) begin
		tx_active <= 1'b1;
		clk_counter <= 5'b1;
		bit_counter <= 4'b0;
		tx <= 1'b0;
	end
	
	// Block to transmit bits contituting the packet
	if (tx_active) begin
		if (clk_counter == 26) begin
			clk_counter <= 5'b0;
			bit_counter <= bit_counter + 1;
		end else begin
			clk_counter <= clk_counter + 1;
		end
		
		case (bit_counter)
			0: tx <= 1'b0;				//start bit
			1: tx <= data[7];	//LSB
			2: tx <= data[6];
			3: tx <= data[5];
			4: tx <= data[4];
			5: tx <= data[3];
			6: tx <= data[2];
			7: tx <= data[1];
			8: tx <= data[0];	//MSB
			9: tx <= parity_type ? ~(^data) : ^data;		//Parity Bit
			10: begin
					tx <= 1'b1;			//Stop Bit
					if (clk_counter == 26) begin
						tx_done <= 1'b1;
						tx_active <= 1'b0;
					end
				end
		endcase
		
	end
	
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule

