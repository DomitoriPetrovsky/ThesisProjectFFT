//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: butterfly_address_gen_unit
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: Модуль генерации адреса поворачивающего множителя в таблице 
// хранящей первую полуволну синуса и косинуса для модуля Бабочка
// алгоритма БПФ с прореживанием по времени
//
// Revision:
// Revision 1.00 - Code comented
// Additional Comments:
//
// Parameters:
// AWL				- Формат преобразования 2^AWL
// synch_RESET		- Выбор сброса в тригерах синхронный(1), асинхронный(0).
// 
// Ports:
// EN				- Разрешаю щий сигнал генерации следующего адреса 
// LAY_EN			- Разрешающий сигнал смены адресации слоя 
// W_ADDR			- Адрес поворачивающего множителя
//
//-----------------------------------------------------------------\\

module w_address_gen_unit #(
	parameter AWL = 5,
	parameter synch_RESET = 1
)(
	input wire 					CLK,
	input wire 					RST,
	input wire 					EN,
	input wire 					LAY_EN,
	output wire 	[AWL-1:0] 	W_ADDR
);

	localparam shLeft		= 0;
	localparam RESET_VALUE	= {1'b1, {(AWL-1){1'b0}}};

	wire [AWL-1:0] addr;
	wire [AWL-1:0] next_addr;
	wire [AWL-1:0] lay;
	wire [AWL-1:0] mask;
	
	assign mask = {1'b0, {(AWL-1){1'b1}}};

	//--------------------Значение адреса W----------------------------\\
	assign W_ADDR = addr & mask;

	//----------------Формирование следующего адреса-------------------\\
	assign next_addr = addr + lay;

	param_register #(
		.BITNESS		(AWL			),
		.synch_RESET	(synch_RESET	))
	addr_reg(
		.CLK			(CLK			),
		.EN				(EN				),
		.RST			(RST			),
		.i_DATA			(next_addr		),
		.o_DATA			(addr			)
	);

	ring_shift_register #(
		.BITNESS 		(AWL			),
		.shLeft			(shLeft			),
		.synch_RESET	(synch_RESET	),
		.RESET_VALUE	(RESET_VALUE	))
	ring_reg(
		.CLK			(CLK			),
		.EN				(LAY_EN			),
		.RST			(RST			),	
		.o_DATA			(lay			)
	);
	
endmodule