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
// Description: Модуль генерации адреса выборки данных для модуля Бабочка
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
// A_ADDR			- Адрес компоненты А
// B_ADDR			- Адрес компоненты В
//
//-----------------------------------------------------------------\\

module butterfly_address_gen_unit #(
	parameter AWL = 5,
	parameter synch_RESET = 1
)(
	input wire 					CLK,
	input wire 					RST,
	input wire 					EN,
	input wire 					LAY_EN,
	output wire 	[AWL-1:0] 	A_ADDR,
	output wire 	[AWL-1:0]	B_ADDR
);

	localparam shLeft		= 1;
	localparam RESET_VALUE	= 1;

	wire 	[AWL-1:0] addr;
	reg 	[AWL-1:0] next_addr;

	wire 	[AWL-1:0] lay;

	reg 	[AWL-1:0] a;
	reg 	[AWL-1:0] b;

	assign A_ADDR = a;
	assign B_ADDR = b;	

	//--------------------Значение адреса А и В------------------------\\
	always @(*) begin
		a <= addr;
		b <= addr | lay;
	end

	//----------------Формирование следующего адреса-------------------\\
	always @(*) begin
		next_addr <= ~(lay) & (b + 1);
	end

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
		.RESET_VALUE	(RESET_VALUE	),
		.synch_RESET	(synch_RESET	))
	ring_reg(
		.CLK			(CLK			),
		.EN				(LAY_EN			),
		.RST			(RST			),	
		.o_DATA			(lay			)
	);

endmodule