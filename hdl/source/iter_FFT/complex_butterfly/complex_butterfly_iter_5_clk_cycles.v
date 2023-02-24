//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: complex_butterfly_iter_5_clk_cycles
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: Данный блок операцию Бабочка за 5 периодов CLK.
// X =  A + W*B
// Y =  A - W*B
// где A, B, W, X, Y - комплексные числа
// 
// Revision:
// Revision 1.00 - Code comented
// Additional Comments:
//
// Parameters:
// IWL1				- Длинна входных слов А и В, мнимой и реальной части
// IWL2				- Длинна входного слова W, мнимой и реальной части
// OWL				- Длинна выходных слов X и Y, мнимой и реальной части
// CONSTANT_SHIFT	- Постоянный сдвиг рещультата вправо на 1 разряд(деление на 2) 
// synch_RESET		- Выбор сброса в тригерах синхронный(1), асинхронный(0).
// 
// Ports:
// din1_re			- Реальная часть В
// din1_im			- Мнимая часть В
//
// din2_re			- Реальная часть W
// din2_im			- Мнимая часть W
//
// din3_re			- Реальная часть A
// din3_im			- Мнимая часть A
//
// dout1_re			- Реальная часть X
// dout1_im			- Мнимая часть X
//
// dout2_re			- Реальная часть Y
// dout2_im			- Мнимая часть Y
//
// Операции выполняемые в каждом такте:
// Такт		pipe_cnt			Операции
// 	(1)		(0)3'b000		(din1_re * din2_re = mult_reg_1)
//							(din1_im * din2_im = mult_reg_2)
//							(mult_reg_2 - mult_reg_1 = re_reg)
//
// 	(2)		(1)3'b001		(din1_re * din2_im = mult_reg_1) 
//							(din1_im * din2_re = mult_reg_2)
//
// 	(3)		(2)3'b010		(mult_reg_2 + mult_reg_1 = im_reg)
//																	+			-
// 	(4)		(3)3'b011		(pre_sum_din3_re +- pre_sum_re_reg = dout1_re_b\dout2_re_b)
//																	+			-
// 	(5)		(4)3'b100		(pre_sum_din3_im +- pre_sum_im_reg = dout1_im\dout2_im) 
//							(dout1_re_b\dout2_re_b = dout1_re\dout2_re)
//
// -----!!!--ATTENTION--!!!-----
// Не рекомендуется ставить OWL => IWL1 + IWL2 - 1 
// Возможны ошибки в алгоритме!
//
//-----------------------------------------------------------------\\

module complex_butterfly_iter_5_clk_cycles #(
	parameter IWL1 				= 16,
	parameter IWL2 				= 16,
	parameter OWL 				= 16,
	parameter CONSTANT_SHIFT	= 1,
	parameter synch_RESET		= 1
)(
	input 	wire 				clk,
	input 	wire 				rst,
	input 	wire 				strb_in,
	input 	wire 	[IWL1-1:0]	din1_re,
	input 	wire 	[IWL1-1:0]	din1_im,
	input 	wire 	[IWL2-1:0]	din2_re,
	input 	wire 	[IWL2-1:0]	din2_im,
	input 	wire 	[IWL1-1:0]	din3_re,
	input 	wire 	[IWL1-1:0]	din3_im,
	output 	wire  	[OWL-1:0]	dout1_re,
	output 	wire  	[OWL-1:0]	dout1_im,
	output 	wire  	[OWL-1:0]	dout2_re,
	output 	wire  	[OWL-1:0]	dout2_im,
	output 	wire				strb_out
);
	localparam PROD_WL 	= IWL1 + IWL2;
	localparam AWL 		= OWL + 1 ;

	//-----------------------Сигналы умножителя----------------------\\
	wire	signed	[IWL1-1:0]			MUL_1_din1_mux;
	wire	signed	[IWL2-1:0]			MUL_1_din2_mux;

	wire	signed	[IWL1-1:0]			MUL_2_din1_mux;
	wire	signed	[IWL2-1:0]			MUL_2_din2_mux;

	reg		signed	[PROD_WL-1:0]		tmp_mult_1;
	reg		signed	[PROD_WL-1:0]		tmp_mult_2;

	reg		signed	[AWL:0]				tmp_mult_1_out;
	reg		signed	[AWL:0]				tmp_mult_2_out;

	wire			[AWL:0]				mult_1_out;
	wire			[AWL:0]				mult_2_out;

	reg				[AWL:0]				mult_reg_1;
	reg				[AWL:0]				mult_reg_2;
	
	//----------Сигналы приведения к формату суммы\вычитания----------\\
	wire 			[AWL:0]				pre_sum_din3_re;
	wire 			[AWL:0]				pre_sum_din3_im;

	wire 			[AWL:0]				pre_sum_re_reg;
	wire 			[AWL:0]				pre_sum_im_reg;

	//----------------Сигналы сумматоров и вычитателей-----------------\\
	wire	signed	[AWL:0]				ADD_1_din1_mux;
	wire	signed	[AWL:0]				ADD_1_din2_mux;

	wire	signed	[AWL:0]				SUB_1_din1_mux; 
	wire	signed	[AWL:0]				SUB_1_din2_mux;

	reg		signed	[AWL:0]				tmp_add_1;
	reg		signed	[AWL:0]				tmp_sub_1;

	reg				[OWL-1:0]			add_1_out;
	reg				[OWL-1:0]			sub_1_out;

	//---------------Регистры промжуточного результата-----------------\\
	reg				[OWL-1:0]			re_reg;
	reg				[OWL-1:0]			im_reg;

	reg			  	[OWL-1:0]			dout1_re_b;
	reg			  	[OWL-1:0]			dout2_re_b;

	//--------------------Управляющие сигналы--------------------------\\
	reg				[2:0]				pipe_cnt;
	wire								valid;
	wire								result_en;

	assign result_en	= 	strb_in && valid;
	assign valid 		= 	pipe_cnt[2];
	assign strb_out		= 	strb_in;


	always @(posedge clk) begin : pipe_alw
		if(rst) begin
			pipe_cnt <= 0;
		end else begin 
			if(strb_in) begin 
				pipe_cnt <= 0;
			end else begin
				if (!pipe_cnt[2]) begin
					pipe_cnt <= pipe_cnt + 1;
				end
			end
		end
	end

	assign MUL_1_din1_mux	=	din1_re;
	assign MUL_1_din2_mux	=	(pipe_cnt[0])	? 	din2_im	: din2_re;

	always @(*) begin : mult_1_alw
		tmp_mult_1 = MUL_1_din1_mux * MUL_1_din2_mux;
		tmp_mult_1_out = tmp_mult_1[PROD_WL-1:PROD_WL-AWL-1];
	end

	assign MUL_2_din1_mux	=	din1_im;
	assign MUL_2_din2_mux	=	(pipe_cnt[0] )	? 	din2_re	: din2_im;

	always @(*) begin : mult_2_alw
		tmp_mult_2 = MUL_2_din1_mux * MUL_2_din2_mux;
		tmp_mult_2_out = tmp_mult_2[PROD_WL-1:PROD_WL-AWL-1];
	end

	//-------------------Реализация сдвига результата------------------\\
	assign mult_1_out 		= (CONSTANT_SHIFT == 0)? tmp_mult_1_out :  tmp_mult_1_out >>> 1;
	assign mult_2_out 		= (CONSTANT_SHIFT == 0)? tmp_mult_2_out :  tmp_mult_2_out >>> 1;
	
	//-----------------Приведения к формату суммы\вычитания------------\\
	assign pre_sum_din3_re 	= (CONSTANT_SHIFT == 0)? {din3_re[IWL1-1], din3_re, 1'b0}: {din3_re[IWL1-1], din3_re[IWL1-1], din3_re};
	assign pre_sum_din3_im 	= (CONSTANT_SHIFT == 0)? {din3_im[IWL1-1], din3_im, 1'b0}: {din3_im[IWL1-1], din3_im[IWL1-1], din3_im};
	
	assign pre_sum_re_reg 	= {re_reg[OWL-1], re_reg, 1'b0};
	assign pre_sum_im_reg 	= {im_reg[OWL-1], im_reg, 1'b0};

	//-----------------------------------------------------------------\\
	assign ADD_1_din1_mux =	(pipe_cnt[2])? 	pre_sum_im_reg  :	((pipe_cnt[0])? pre_sum_re_reg : mult_reg_1) ;
	assign ADD_1_din2_mux =	(pipe_cnt[2])? 	pre_sum_din3_im :	((pipe_cnt[0])? pre_sum_din3_re : mult_reg_2) ;

	always @* begin : add_1_alw
		tmp_add_1 = ADD_1_din1_mux + ADD_1_din2_mux + 2'b01;
		if (tmp_add_1[AWL] == tmp_add_1[AWL-1]) begin 
			add_1_out = tmp_add_1[AWL-1: AWL-OWL];
		end else begin 
			add_1_out[OWL-1] = tmp_add_1[AWL];
			add_1_out[OWL-2:0] = {OWL-1{tmp_add_1[AWL-1]}};
		end 
	end

	//-----------------------------------------------------------------\\
	assign SUB_1_din2_mux =	(pipe_cnt[2])? 	pre_sum_im_reg  :	((pipe_cnt[1])? pre_sum_re_reg : mult_reg_2) ;
	assign SUB_1_din1_mux =	(pipe_cnt[2])? 	pre_sum_din3_im :	((pipe_cnt[1])? pre_sum_din3_re : mult_reg_1) ;

	always @* begin : sub_1_alw
		tmp_sub_1 = SUB_1_din1_mux - SUB_1_din2_mux + 2'b01;
		if (tmp_sub_1[AWL] == tmp_sub_1[AWL-1]) begin 
			sub_1_out = tmp_sub_1[AWL-1: AWL-OWL];
		end else begin 
			sub_1_out[OWL-1] = tmp_sub_1[AWL];
			sub_1_out[OWL-2:0] = {OWL-1{tmp_sub_1[AWL-1]}};
		end 
	end

	//---------------------Промежуточные регистры----------------------\\
	always @(posedge clk) begin : pipe_mult_reg1
		if((pipe_cnt[2] | pipe_cnt[1]) == 0) begin 
			mult_reg_1 <= mult_1_out;
			mult_reg_2 <= mult_2_out;
		end
	end

	always @(posedge clk) begin
		if(pipe_cnt == 3'b001) begin 
			re_reg <= sub_1_out;
		end
	end

	always @(posedge clk) begin
		if(pipe_cnt == 3'b010) begin 
			im_reg <= add_1_out;
		end
	end

	always @(posedge clk) begin
		if(pipe_cnt == 3'b011) begin 
			dout1_re_b <= add_1_out; 
			dout2_re_b <= sub_1_out;
		end
	end

	//---------------------------Результат-----------------------------\\
	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout1_re(
		.CLK			(clk			),
		.EN				(result_en		),
		.RST			(rst			),
		.i_DATA			(dout1_re_b		),
		.o_DATA			(dout1_re		)
	);

	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout1_im(
		.CLK			(clk			),
		.EN				(result_en		),
		.RST			(rst			),
		.i_DATA			(add_1_out		),
		.o_DATA			(dout1_im		)
	);

	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout2_re(
		.CLK			(clk			),
		.EN				(result_en		),
		.RST			(rst			),
		.i_DATA			(dout2_re_b		),
		.o_DATA			(dout2_re		)
	);

	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout2_im(
		.CLK			(clk			),
		.EN				(result_en		),
		.RST			(rst			),
		.i_DATA			(sub_1_out		),
		.o_DATA			(dout2_im		)
	);
endmodule