module tb_iter_fft;


	parameter DWL = 16;
	parameter AWL = 5;
	parameter INIT_FILE = "C:/Users/user1/Documents/MATLAB/function/data.txt";

	reg 					CLK;
	reg 					WrE;
	reg 					EN;	

	reg 					RST;
	reg 					START;
	wire 					block;

	 top_fft_iter #(
		.IWL(32),
		.INIT_FILE (INIT_FILE)
	)fft(	
		.CLK			(CLK),
		.RST			(RST),
		.EN				(EN),
		.START			(START),
		.i_A_DATA		(0),
		.i_B_DATA		(0),
		.i_A_ADDR		(0),
		.i_B_ADDR		(0),
		.i_RAM_Wr		(0),
		.o_RAM_BLOCK	(block)
	);

	always #5 CLK = ~CLK;

	always @( posedge CLK) begin
		if (!RST) begin
			WrE <=! WrE;
		end
	end


	initial begin 

		{CLK, EN, START} <= 0;
		WrE <= 1;
		RST <= 1;
		#20 
		RST <= 0;
		#5
		EN <= 1;
		START <= 1;
		#20 START <= 0;
		
	end 
    
endmodule 		
			
	