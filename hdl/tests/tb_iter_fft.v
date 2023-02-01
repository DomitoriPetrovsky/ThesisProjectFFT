module tb_iter_fft;


	parameter DWL = 16;
	parameter AWL = 8;
	parameter INIT_FILE = "../matlab/data.txt";
	parameter DEBUG_RES_FILE_NAME = "../matlab/res.txt";
	reg 					CLK;
	reg 					WrE;
	reg 					EN;	

	reg wr_res;

	reg 					RST;
	reg 					START;
	wire 					block;




	top_fft_iter #(
		.IWL(32),
		.AWL(5),
		.INIT_FILE (INIT_FILE),
		.BUT_CLK_CYCLE(2),
		.DEBUG_RES_FILE_NAME(DEBUG_RES_FILE_NAME)
	)fft(	
		.wr_res(wr_res),


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

	initial begin 

		{CLK, EN, START, wr_res} <= 0;
		WrE <= 1;
		RST <= 1;
		#20 
		RST <= 0;
		#5
		EN <= 1;
		START <= 1;
		#20 START <= 0;
		
		#2465 wr_res <= 1;
	end 
    
endmodule 		
			
	