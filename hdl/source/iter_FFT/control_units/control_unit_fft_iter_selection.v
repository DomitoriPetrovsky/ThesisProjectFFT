//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: control_unit_fft_iter_selection
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: Данный блок выбирает один из 5 блоков контроля.
// 
// Revision:
// Revision 1.00 - Code comented
// Additional Comments:
//
// Parameters:
// LAYERS			- Количество слоев в преобразовании FFT
// BUTTERFLYES		- Количество операций Бабочка на 1 слой
// LayWL			- Количество битов выделяемых для счетчика слоев в устройстве управления
// ButtWL			- Количество битов выделяемых для счетчика бабочек в устройстве управления
// BUT_CLK_CYCLE	- Количество тактов выполнения операции бабочка 
// 
// Ports:
// BUSY				- 
// BUT_STROB		- Сигнал стробирования модуля Бабочка
// LAY_EN			- Разрешающий сигнал смены адресации слоя 
// ADDR_EN			- Разрешаю щий сигнал генерации следующего адреса 
// ADDR_RST			- Сброс устройства адреса 
// RAM_EN_R			- Разрешающий сигнал чтения для RAM
// RAM_EN_WR		- Разрешающий сигнал записи для RAM
// Wr				- Режим работы портов RAM чтение(0) запись(1)
// LAST_LAY			- Сигнал переключения записи в выходное FIFO
//
//-----------------------------------------------------------------\\

module control_unit_fft_iter_selection #(
	parameter LAYERS 		= 5,
	parameter BUTTERFLYES 	= 16,
	parameter LayWL 		= 3,
	parameter ButtWL 		= 4,
	parameter BUT_CLK_CYCLE = 5
)(
	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,

	input 	wire					START,	

	output	wire					BUSY,
	output 	wire					BUT_STROB,
	output 	wire					LAY_EN,
	output 	wire					ADDR_EN,
	output 	wire					ADDR_RST,
	output 	wire					RAM_EN_R,
	output 	wire					RAM_EN_WR,
	output 	wire					Wr,
	output 	wire					LAST_LAY
);
	generate
		if (BUT_CLK_CYCLE == 6) begin
			control_unit_fft_iter_6_cyc_but #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUSY		(BUSY			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.ADDR_RST	(ADDR_RST		),
				.RAM_EN_R	(RAM_EN_R		),
				.RAM_EN_WR	(RAM_EN_WR		),
				.Wr			(Wr				),
				.LAST_LAY	(LAST_LAY		));	
		end
		if (BUT_CLK_CYCLE == 5) begin
			control_unit_fft_iter_5_cyc_but #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUSY		(BUSY			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.ADDR_RST	(ADDR_RST		),
				.RAM_EN_R	(RAM_EN_R		),
				.RAM_EN_WR	(RAM_EN_WR		),
				.Wr			(Wr				),
				.LAST_LAY	(LAST_LAY		));	
		end
		if (BUT_CLK_CYCLE == 4) begin
			control_unit_fft_iter_4_cyc_but #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUSY		(BUSY			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.ADDR_RST	(ADDR_RST		),
				.RAM_EN_R	(RAM_EN_R		),
				.RAM_EN_WR	(RAM_EN_WR		),
				.Wr			(Wr				),
				.LAST_LAY	(LAST_LAY		));	
		end
		if ((BUT_CLK_CYCLE == 3) || (BUT_CLK_CYCLE == 33)) begin
			control_unit_fft_iter_3_cyc_but #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUSY		(BUSY			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.ADDR_RST	(ADDR_RST		),
				.RAM_EN_R	(RAM_EN_R		),
				.RAM_EN_WR	(RAM_EN_WR		),
				.Wr			(Wr				),
				.LAST_LAY	(LAST_LAY		));
		end
		if (BUT_CLK_CYCLE == 2) begin
			control_unit_fft_iter_2_cyc_but #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUSY		(BUSY			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.ADDR_RST	(ADDR_RST		),
				.RAM_EN_R	(RAM_EN_R		),
				.RAM_EN_WR	(RAM_EN_WR		),
				.Wr			(Wr				),
				.LAST_LAY	(LAST_LAY		));
		end
	endgenerate
endmodule