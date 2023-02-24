//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: complex_butterfly_selection
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: Данный блок выбирает один из 6 блоков операции Бабочка.
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
// BUT_CLK_CYCLE	- Количество тактов выполнения операции Бабочка :
//						2	- количество тактов на выполнение операции (4 MULT 3 SUB 3 ADD)
//						3	- количество тактов на выполнение операции (4 MULT 3 SUB 3 ADD)
//						33	- НЕ ОБОЗНАЧАЕТ КОЛИЧЕСТВО ТАКТОВ! медленный вариант бабочки на 3 такта (4 MULT 2 SUB 2 ADD)
//						4	- количество тактов на выполнение операции (2 MULT 2 SUB 2 ADD)
//						5	- количество тактов на выполнение операции (2 MULT 1 SUB 1 ADD)
//						6	- количество тактов на выполнение операции (1 MULT 1 SUB 1 ADD)
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
// -----!!!--ATTENTION--!!!-----
// Не рекомендуется ставить OWL => IWL1 + IWL2 - 1 
// Возможны ошибки в алгоритме!
//
//-----------------------------------------------------------------\\

module complex_butterfly_selection #(
	parameter IWL1 				= 16,
	parameter IWL2 				= 16,
	parameter OWL 				= 16,
	parameter CONSTANT_SHIFT	= 1,
	parameter BUT_CLK_CYCLE 	= 5,
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
	generate 
		if (BUT_CLK_CYCLE == 6) begin
			complex_butterfly_iter_6_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.OWL			(OWL			),
				.synch_RESET	(synch_RESET	),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	)) 
			cplx_but_1MUL_1ADD_1SUB(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 5) begin
			complex_butterfly_iter_5_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.OWL			(OWL			),
				.synch_RESET	(synch_RESET	),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	)) 
			cplx_but_2MUL_1ADD_1SUB(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 4) begin
			complex_butterfly_iter_4_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.OWL			(OWL			),
				.synch_RESET	(synch_RESET	),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	)) 
			cplx_but_2MUL_2ADD_2SUB(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 3) begin
			complex_butterfly_pipe_3_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.OWL			(OWL			),
				.synch_RESET	(synch_RESET	),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	))
			cplx_but_4MUL_3ADD_3SUB(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 33) begin
			complex_butterfly_iter_3_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.OWL			(OWL			),
				.synch_RESET	(synch_RESET	),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	))
			cplx_but_4MUL_2ADD_2SUB(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 2) begin
			complex_butterfly_pipe_2_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.OWL			(OWL			),
				.synch_RESET	(synch_RESET	),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	))
				cplx_but_4MUL_3ADD_3SUB(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
	endgenerate
endmodule	