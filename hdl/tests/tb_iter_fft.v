module tb_iter_fft;

	parameter DWL 				= 16;
	parameter AWL 				= 5;
	parameter BIT_REVERS_WRITE 	= 1;
	parameter BUT_CLK_CYCLE 	= 5;
	parameter INVERSE			= 0;
	parameter INIT_FILE 		= "../matlab/data.txt";

	parameter DEBUG_RES_R_FILE_NAME = "../matlab/res_r.txt";
	parameter DEBUG_RES_I_FILE_NAME = "../matlab/res_i.txt";

	parameter CLK_1_PER = 10 ;
	parameter CLK_2_PER = 150;

	localparam  init_len = 2**AWL;

	//-------------------Тактовый сигнал работы FFT--------------------\\
	reg 					CLK_1;

	//--------------Тактовый сигнал поступления дынных-----------------\\
	reg 					CLK_2;

	reg 					EN;	

	//----------------------Упарвляющие сигналы------------------------\\
	reg 					wr_res;
	reg 					WR_DATA;
	reg 					RST;
	reg 					START;
	reg 					fifo_RST;
	wire 					fifo_FULL;


	reg [2*DWL-1:0] 		init 		[init_len-1:0];

	reg [AWL-1:0] 			res_count 					= {AWL{1'b0}};
	reg [DWL-1:0] 			res_r 		[init_len-1:0];
	reg [DWL-1:0] 			res_i 		[init_len-1:0];


	reg [AWL-1:0]			i = 0;

	reg [DWL-1:0] 			i_DATA_R;
	reg [DWL-1:0] 			i_DATA_I;

	wire [DWL-1:0] 			t_DATA_R;
	wire [DWL-1:0] 			t_DATA_I;

	wire 					r_empty;
	wire 					r_full;

	wire 					i_empty;
	wire 					i_full;

	reg 					r_inc;
	reg 					wr_inc;

	wire [DWL-1:0] 			o_DATA_R;
	wire [DWL-1:0] 			o_DATA_I;
	wire 					VALID;

	//------------------Загружаем занчения из файла--------------------\\
	initial $readmemh(INIT_FILE, init, 0, init_len-1);
		
	always #(CLK_1_PER/2) CLK_1 = ~CLK_1;
	always #(CLK_2_PER/2) CLK_2 = ~CLK_2;


	always @(posedge CLK_2) begin
		if (!RST) begin 
			wr_inc = 1;
			i_DATA_R = init[i][2*DWL-1:DWL]; 
			i_DATA_I = init[i][DWL-1:0];
			i =  i +  1;
		end else begin 
			wr_inc = 0;
		end
	end

	always @(posedge CLK_1) begin
		if(r_inc) begin 
			WR_DATA <= 1;
		end else begin
			WR_DATA <= 0;
		end
	end

	always @(fifo_FULL or i_empty) begin
		if(!fifo_FULL && !i_empty) begin 
			r_inc <= 1;
		end else begin
			r_inc <= 0;
		end
	end

	always @(posedge CLK_1) begin
		if(VALID) begin 
			res_r[res_count] = o_DATA_R;
			res_i[res_count] = o_DATA_I;
			res_count = res_count + 1;
		end
	end

	always @(negedge VALID) begin
		#100 $writememh(DEBUG_RES_R_FILE_NAME, res_r, 0, 2**AWL-1 );
		$writememh(DEBUG_RES_I_FILE_NAME, res_i, 0, 2**AWL-1 );
	end

	initial begin 

		{CLK_1, CLK_2, EN, START, wr_res, WR_DATA, fifo_RST, wr_inc} <= 0;
		i_DATA_R = init[0][2*DWL-1:DWL]; 
		i_DATA_I = init[0][DWL-1:0];
		RST <= 1;
		#(2*CLK_2_PER)
		RST <= 0;
		#5
		EN <= 1;

		//#3300 fifo_RST = 1;
		//#10 fifo_RST = 0;

	end 
    
	
	FIFO_unit #(
		.DWL				(DWL				),
		.AWL				(AWL				))
	sync_fifo_r(		
		.R_CLK				(CLK_1				),
		.WR_CLK				(CLK_2				),
		
		.R_RST				(RST				),
		.WR_RST				(RST				),
		
		.R_INC				(r_inc				),
		.WR_INC				(wr_inc				),
		
		.R_DATA				(t_DATA_R			),
		.WR_DATA			(i_DATA_R			),
		
		.R_EMPTY			(r_empty			),
		.WR_FULL			(r_full				)
	);		
		
	FIFO_unit #(		
			.DWL			(DWL				),
			.AWL			(AWL				))
	sync_fifo_i(		
			.R_CLK			(CLK_1				),
			.WR_CLK			(CLK_2				),
		
			.R_RST			(RST				),
			.WR_RST			(RST				),
		
			.R_INC			(r_inc				),
			.WR_INC			(wr_inc				),
		
			.R_DATA			(t_DATA_I			),
			.WR_DATA		(i_DATA_I			),
		
			.R_EMPTY		(i_empty			),
			.WR_FULL		(i_full				)
	);

	top_fft_iter #(
		.DWL				(DWL				),
		.AWL				(AWL				),
		.BUT_CLK_CYCLE		(BUT_CLK_CYCLE		),
		.INVERSE			(INVERSE			),
		.BIT_REVERS_WRITE	(BIT_REVERS_WRITE	))
	fft(	
		.CLK				(CLK_1				),
		.RST				(RST				),
		.EN					(EN					),
		.i_DATA_R			(t_DATA_R			),
		.i_DATA_I			(t_DATA_I			),
		.i_WR_DATA			(WR_DATA			),
		.IN_FIFO_RST		(fifo_RST			),
		.FULL				(fifo_FULL				),
		.o_DATA_R			(o_DATA_R			),
		.o_DATA_I			(o_DATA_I			),
		.VALID				(VALID				)
	);
endmodule