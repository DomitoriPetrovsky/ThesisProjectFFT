//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: complex_butterfly_pipe_2_clk_cycles
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: Данный блок операцию Бабочка за 2 периодов CLK.
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
// Такт					Операции
// 	(1)			(din1_re * din2_re = mult_reg_1)
//				(din1_im * din2_im = mult_reg_2)
//				(din1_re * din2_im = mult_reg_3) 
//				(din1_im * din2_re = mult_reg_4)
//																	+		-
// 	(2)			(pre_sum_din3_re +- (mult_reg_2 - mult_reg_1) = dout1_re\dout2_re)
//				(pre_sum_din3_im +- (mult_reg_3 + mult_reg_4) = dout1_im\dout2_im) 
//
// -----!!!--ATTENTION--!!!-----
// Не рекомендуется ставить OWL => IWL1 + IWL2 - 1 
// Возможны ошибки в алгоритме!
// Операции суммы и вычитания в SUB0 и ADD0 происходя без контроля переполнения!!
//
//-----------------------------------------------------------------\\

module complex_butterfly_pipe_2_clk_cycles #(
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
	wire	signed	[IWL1-1:0]			MUL_1_din1;
	wire	signed	[IWL2-1:0]			MUL_1_din2;

	wire	signed	[IWL1-1:0]			MUL_2_din1;
	wire	signed	[IWL2-1:0]			MUL_2_din2;

	wire	signed	[IWL1-1:0]			MUL_3_din1;
	wire	signed	[IWL2-1:0]			MUL_3_din2;

	wire	signed	[IWL1-1:0]			MUL_4_din1;
	wire	signed	[IWL2-1:0]			MUL_4_din2;

	reg		signed	[PROD_WL-1:0]		tmp_mult_1;
	reg		signed	[PROD_WL-1:0]		tmp_mult_2;
	reg		signed	[PROD_WL-1:0]		tmp_mult_3;
	reg		signed	[PROD_WL-1:0]		tmp_mult_4;

	reg		signed	[AWL:0]				tmp_mult_out_1;
	reg		signed	[AWL:0]				tmp_mult_out_2;
	reg		signed	[AWL:0]				tmp_mult_out_3;
	reg		signed	[AWL:0]				tmp_mult_out_4;

	wire			[AWL:0]				mult_out_1;
	wire			[AWL:0]				mult_out_2;
	wire			[AWL:0]				mult_out_3;
	wire			[AWL:0]				mult_out_4;

	reg				[AWL:0]				mult_out_reg_1;
	reg				[AWL:0]				mult_out_reg_2;
	reg				[AWL:0]				mult_out_reg_3;
	reg				[AWL:0]				mult_out_reg_4;

	//----------Сигналы приведения к формату суммы\вычитания----------\\
	wire 			[AWL:0]				pre_sum_din3_re;
	wire 			[AWL:0]				pre_sum_din3_im;

	//----------------Сигналы сумматоров и вычитателей-----------------\\
	wire	signed	[AWL:0]				ADD_0_din1;
	wire	signed	[AWL:0]				ADD_0_din2;

	wire	signed	[AWL:0]				SUB_0_din1; 
	wire	signed	[AWL:0]				SUB_0_din2;

	reg				[AWL:0]				add_0_out;
	reg				[AWL:0]				sub_0_out;
	//-----------------------------------------------------------------\\
	wire	signed	[AWL:0]				ADD_1_din1;
	wire	signed	[AWL:0]				ADD_1_din2;

	wire	signed	[AWL:0]				SUB_1_din1; 
	wire	signed	[AWL:0]				SUB_1_din2;

	reg		signed	[AWL:0]				tmp_add_1;
	reg		signed	[AWL:0]				tmp_sub_1;

	reg				[OWL-1:0]			add_1_out;
	reg				[OWL-1:0]			sub_1_out;
	//-----------------------------------------------------------------\\
	wire	signed	[AWL:0]				ADD_2_din1;
	wire	signed	[AWL:0]				ADD_2_din2;

	wire	signed	[AWL:0]				SUB_2_din1;
	wire	signed	[AWL:0]				SUB_2_din2;

	reg		signed	[AWL:0]				tmp_add_2;
	reg		signed	[AWL:0]				tmp_sub_2;

	reg				[OWL-1:0]			add_2_out;
	reg				[OWL-1:0]			sub_2_out;

	//-----------------------------------------------------------------\\

	assign strb_out		= 	strb_in;

	assign MUL_1_din1	=	din1_re;
	assign MUL_1_din2	=	din2_re;	
	assign MUL_2_din1	=	din1_im;
	assign MUL_2_din2	=	din2_im;	
	assign MUL_3_din1	=	din1_re;
	assign MUL_3_din2	=	din2_im;	
	assign MUL_4_din1	=	din1_im;
	assign MUL_4_din2	=	din2_re;

	always @(*) begin : mult_alw_1
		tmp_mult_1 = MUL_1_din1 * MUL_1_din2;
		tmp_mult_out_1 = tmp_mult_1[PROD_WL-1:PROD_WL-AWL-1];
	end
	always @(*) begin : mult_alw_2
		tmp_mult_2 = MUL_2_din1 * MUL_2_din2;
		tmp_mult_out_2 = tmp_mult_2[PROD_WL-1:PROD_WL-AWL-1];
	end
	always @(*) begin : mult_alw_3
		tmp_mult_3 = MUL_3_din1 * MUL_3_din2;
		tmp_mult_out_3 = tmp_mult_3[PROD_WL-1:PROD_WL-AWL-1];
	end
	always @(*) begin : mult_alw_4
		tmp_mult_4 = MUL_4_din1 * MUL_4_din2;
		tmp_mult_out_4 = tmp_mult_4[PROD_WL-1:PROD_WL-AWL-1];
	end

	//-------------------Реализация сдвига результата------------------\\
	assign mult_out_1 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_1 :  tmp_mult_out_1 >>> 1;
	assign mult_out_2 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_2 :  tmp_mult_out_2 >>> 1;
	assign mult_out_3 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_3 :  tmp_mult_out_3 >>> 1;
	assign mult_out_4 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_4 :  tmp_mult_out_4 >>> 1;

	//-----------------Приведения к формату суммы\вычитания------------\\
	assign pre_sum_din3_re 	= (CONSTANT_SHIFT == 0)? {din3_re[IWL1-1], din3_re, 1'b0}: {din3_re[IWL1-1], din3_re[IWL1-1], din3_re};
	assign pre_sum_din3_im 	= (CONSTANT_SHIFT == 0)? {din3_im[IWL1-1], din3_im, 1'b0}: {din3_im[IWL1-1], din3_im[IWL1-1], din3_im};
	
	//-----------------------------------------------------------------\\
	assign ADD_0_din1 =	mult_out_reg_3;
	assign ADD_0_din2 =	mult_out_reg_4;

	always @* begin : add_0_alw
		add_0_out = ADD_0_din1 + ADD_0_din2;
	end

	//-----------------------------------------------------------------\\
	assign SUB_0_din1 =	mult_out_reg_1;
	assign SUB_0_din2 =	mult_out_reg_2;

	always @* begin : sub_0_alw
		sub_0_out = SUB_0_din1 - SUB_0_din2;
	end

	//-----------------------------------------------------------------\\
	assign ADD_1_din1 =	pre_sum_din3_re;
	assign ADD_1_din2 =	sub_0_out;

	always @* begin : add_1_alw
		tmp_add_1 = ADD_1_din1 + ADD_1_din2 + 2'b01;
		if (tmp_add_1[AWL] == tmp_add_1[AWL-1]) begin 
			add_1_out = tmp_add_1[AWL-1: AWL-OWL];
		end else begin 
			add_1_out[OWL-1] = tmp_add_1[AWL];
			add_1_out[OWL-2:0] = {OWL-1{tmp_add_1[AWL-1]}};
		end 
	end

	//-----------------------------------------------------------------\\
	assign SUB_1_din1 =	pre_sum_din3_re;
	assign SUB_1_din2 =	sub_0_out;

	always @* begin : sub_1_alw
		tmp_sub_1 = SUB_1_din1 - SUB_1_din2 + 2'b01;
		if (tmp_sub_1[AWL] == tmp_sub_1[AWL-1]) begin 
			sub_1_out = tmp_sub_1[AWL-1: AWL-OWL];
		end else begin 
			sub_1_out[OWL-1] = tmp_sub_1[AWL];
			sub_1_out[OWL-2:0] = {OWL-1{tmp_sub_1[AWL-1]}};
		end 
	end

	//-----------------------------------------------------------------\\
	assign ADD_2_din1 = pre_sum_din3_im;
	assign ADD_2_din2 = add_0_out; 

	always @* begin : add_2_alw
		tmp_add_2 = ADD_2_din1 + ADD_2_din2 + 2'b01;
		if (tmp_add_2[AWL] == tmp_add_2[AWL-1]) begin 
			add_2_out = tmp_add_2[AWL-1: AWL-OWL];
		end else begin 
			add_2_out[OWL-1] = tmp_add_2[AWL];
			add_2_out[OWL-2:0] = {OWL-1{tmp_add_2[AWL-1]}};
		end 
	end

	//-----------------------------------------------------------------\\
	assign SUB_2_din1 = pre_sum_din3_im; 
	assign SUB_2_din2 = add_0_out; 

	always @* begin : sub_2_alw
		tmp_sub_2 = SUB_2_din1 - SUB_2_din2 + 2'b01;
		if (tmp_sub_2[AWL] == tmp_sub_2[AWL-1]) begin 
			sub_2_out = tmp_sub_2[AWL-1: AWL-OWL];
		end else begin 
			sub_2_out[OWL-1] = tmp_sub_2[AWL];
			sub_2_out[OWL-2:0] = {OWL-1{tmp_sub_2[AWL-1]}};
		end 
	end
	
	//---------------------Промежуточные регистры----------------------\\
	always @(posedge clk) begin : pipe
		mult_out_reg_1 <= mult_out_1;
		mult_out_reg_2 <= mult_out_2;
		mult_out_reg_3 <= mult_out_3;
		mult_out_reg_4 <= mult_out_4;
	end

	//---------------------------Результат-----------------------------\\
	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout1_re(
		.CLK			(clk			),
		.EN				(strb_in		),
		.RST			(rst			),
		.i_DATA			(add_1_out		),
		.o_DATA			(dout1_re		)
	);

	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout1_im(
		.CLK			(clk			),
		.EN				(strb_in		),
		.RST			(rst			),
		.i_DATA			(add_2_out		),
		.o_DATA			(dout1_im		)
	);

	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout2_re(
		.CLK			(clk			),
		.EN				(strb_in		),
		.RST			(rst			),
		.i_DATA			(sub_1_out		),
		.o_DATA			(dout2_re		)
	);

	param_register #(
		.BITNESS		(OWL			),
		.synch_RESET	(synch_RESET	))
	reg_dout2_im(
		.CLK			(clk			),
		.EN				(strb_in		),
		.RST			(rst			),
		.i_DATA			(sub_2_out		),
		.o_DATA			(dout2_im		)
	);
endmodule 