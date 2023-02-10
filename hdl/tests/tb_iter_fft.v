module tb_iter_fft;


	parameter DWL = 16;
	parameter AWL = 11;
	parameter INIT_FILE = "../matlab/data.txt";
	parameter DEBUG_RES_FILE_NAME = "../matlab/res.txt";
	parameter  BIT_REVERS_WRITE = 0;
	reg 					CLK;
	reg 					CLK_1;
	reg 					WrE;
	reg 					EN;	

	reg wr_res;
	reg WR_DATA;
	reg 					RST;
	reg 					START;
	wire 					block;

	localparam  init_len = 2**AWL;
	reg [2*DWL-1:0] init [init_len-1:0];

	reg [AWL-1:0] res_c = {AWL{1'b0}};
	reg [DWL-1:0] res_r [init_len-1:0];
	reg [DWL-1:0] res_i [init_len-1:0];

	reg [AWL-1:0]i = 0;

	reg [DWL-1:0] i_DATA_R;
	reg [DWL-1:0] i_DATA_I;

	reg point;

	wire [DWL-1:0] o_DATA_R;
	wire [DWL-1:0] o_DATA_I;
	wire VALID;

	initial $readmemh(INIT_FILE, init, 0, init_len-1);
		


	top_fft_iter #(
		.DWL(DWL),
		.AWL(AWL),
		.BUT_CLK_CYCLE(2),
		.BIT_REVERS_WRITE(BIT_REVERS_WRITE),
		.DEBUG_RES_FILE_NAME(DEBUG_RES_FILE_NAME))
	fft(	
		.wr_res		(wr_res		),
		.CLK		(CLK		),
		.RST		(RST		),
		.EN			(EN			),
		.i_DATA_R	(i_DATA_R	),
		.i_DATA_I	(i_DATA_I	),
		.i_WR_DATA	(WR_DATA	),
		.FULL		(block		),
		.o_DATA_R	(o_DATA_R	),
		.o_DATA_I	(o_DATA_I	),
		.VALID		(VALID		)
	);

	always #5 CLK = ~CLK;
	always #5000 CLK_1 = ~CLK_1;

	always @(posedge CLK) begin
		if(VALID) begin 
			res_r[res_c] = o_DATA_R;
			res_i[res_c] = o_DATA_I;
			res_c = res_c + 1;
		end
	end

	always begin
		if (!RST && !block) begin 
			i_DATA_R = init[i][2*DWL-1:DWL]; 
			i_DATA_I = init[i][DWL-1:0];
			
			#10 WR_DATA = 1;
			#10 WR_DATA = 0;
			#4980 i =  i +  1;
		end else begin 
			#10 WR_DATA = 0;
		end
	end
	/*always @(posedge CLK_1) begin
		if(WR_DATA & !block)begin
			i = i + 1;
			i_DATA_R = init[i][2*DWL-1:DWL]; 
			i_DATA_I = init[i][DWL-1:0];
		end
	end*/

	initial begin 

		{CLK, CLK_1, EN, START, wr_res, WR_DATA} <= 0;
		i_DATA_R = init[0][2*DWL-1:DWL]; 
		i_DATA_I = init[0][DWL-1:0];
		RST <= 1;
		#20 
		RST <= 0;
		#5
		EN <= 1;
		//#10 WR_DATA <= 1;
		//#320 WR_DATA <= 0;
		
		//#2465 wr_res <= 1;
	end 
    
endmodule 		
			
	