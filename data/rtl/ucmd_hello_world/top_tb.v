`timescale 1ns / 1ps

module top_tb;

	// Inputs
	reg clk;
	reg rst;
	reg rx;
	wire tx;
	localparam frequency = 1600;
	localparam baudrate = 10;
	localparam tick = 10;
	localparam rx_delay = tick*frequency/baudrate;

	// Instantiate the Unit Under Test (UUT)
	uart_top #(.frequency(frequency),.baudrate(baudrate)) uut (
		.clk(clk), 
		.rst(rst), 
		.rx(rx), 
		.tx(tx)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		rx = 1;
		//tx = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;
		#rx_delay;
		////////////////////
		rx = 0; //start
		#rx_delay;
		rx = 1; //0x53
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //stop
		#rx_delay;
		/////////////////////

		////////////////////
		rx = 0; //start
		#rx_delay;
		rx = 0; //0xCD
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 1; //stop
		#rx_delay;
		/////////////////////

		////////////////////
		rx = 0; //start
		#rx_delay;
		rx = 1; //0x53
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //stop
		#rx_delay;
		/////////////////////

		////////////////////
		rx = 0; //start
		#rx_delay;
		rx = 1; //0xAB
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 1; //stop
		#rx_delay;
		/////////////////////

		// ERROR
		////////////////////
		rx = 0; //start
		#rx_delay;
		rx = 1; //0xAB
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //stop
		#rx_delay;
		rx = 1;
		#rx_delay;
		#rx_delay;
		#rx_delay;
		#rx_delay;
		/////////////////////



		////////////////////
		rx = 0; //start
		#rx_delay;
		rx = 0; //0x30
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 1; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 0; //
		#rx_delay;
		rx = 1; //stop
		#rx_delay;
		/////////////////////
		



		// Add stimulus here

	end
	
	always #(tick/2) clk = ~clk;
      
endmodule

