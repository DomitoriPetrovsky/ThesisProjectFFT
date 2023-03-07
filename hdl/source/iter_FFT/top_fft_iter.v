//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: top_fft_iter
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: This description implements a stream coprocessor 
// FFT of the format equal to powers of 2
// 
// Revision:
// Revision 1.00 - Code comented
// Additional Comments:
//
// Parameters:
// DWL				- Длинна входного слова
// W_WDL			- Внутренняя длинна слова поворачивающего множителя
// AWL				- Формат преобразования 2^AWL
// BIT_REVERS_WRITE	- Запись входных данных в битинверсной адресации
// LayWL			- Количество битов выделяемых для счетчика слоев в устройстве управления
// INVERSE			- Обратное(1) или прямое(0) преобразование
// BUT_CLK_CYCLE	- Количество тактов выполнения операции бабочка 
// synch_RESET		- Выбор сброса в тригерах синхронный(1), асинхронный(0).
// 
// Ports:
// i_DATA_R			- Входной порт реальной составляющей
// i_DATA_I			- Входной порт мнимой составляющей
// i_WR_DATA		- Сигнал записи (валидности) входных данных 
// IN_FIFO_RST		- Сброс адрессации входного FIFO, 
// FULL				- Входное FIFO переполнено либо из него проиходит чтение по двум портам
// o_DATA_R			- Выходной порт реальной составляющей 
// o_DATA_I			- Выходной порт мнимой составляющей
// VALID			- Сигнал стробирующий выходные данные
//
//-----------------------------------------------------------------\\

module top_fft_iter #(
	parameter DWL 					= 16,
	parameter W_DWL					= 16,
	parameter AWL 					= 5,
	parameter BIT_REVERS_WRITE 		= 1,
	parameter LayWL 				= 4,
	parameter INVERSE 				= 0,
	parameter BUT_CLK_CYCLE 		= 3,
	parameter synch_RESET			= 1
)(	
	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,

	input 	wire 		[DWL-1:0] 	i_DATA_R,
	input 	wire 		[DWL-1:0] 	i_DATA_I,
	input 	wire					i_WR_DATA,
	input	wire 					IN_FIFO_RST,		
	output 	wire					FULL,

	output 	wire 		[DWL-1:0] 	o_DATA_R,
	output 	wire 		[DWL-1:0] 	o_DATA_I,
	output 	wire					VALID
);

	localparam BUT_NUM 	= 2^(AWL-1);
	
	localparam a_b_address_delay 	= (BUT_CLK_CYCLE == 33) || (BUT_CLK_CYCLE == 3) || (BUT_CLK_CYCLE == 2) ? 3	: 2;
	localparam w_value_delay 		= (BUT_CLK_CYCLE == 33) || (BUT_CLK_CYCLE == 3) || (BUT_CLK_CYCLE == 2) ? 2	: 1;

	localparam butterfly_constant_shift = (INVERSE == 0)? 1'b1 : 1'b0;
	
	//-----------------------------------------------------------------\\
	//----Сигналы мультиплексирование входных анных модуля Buttrfly----\\
	wire 	[DWL-1:0] 		a_value_r_mux;
	wire 	[DWL-1:0] 		b_value_r_mux;

	wire 	[DWL-1:0] 		a_value_i_mux;
	wire 	[DWL-1:0] 		b_value_i_mux;

	//------------------Входные регистры бабочки ----------------------\\
	wire  	[DWL-1:0] 		reg_a_value_r;
	wire  	[DWL-1:0] 		reg_b_value_r;

	wire  	[DWL-1:0] 		reg_a_value_i;
	wire  	[DWL-1:0] 		reg_b_value_i;

	//----------------Выходные значения модуля Buttrfly----------------\\
	wire 	[DWL-1:0] 		x_value_r;
	wire 	[DWL-1:0] 		y_value_r;
	wire 	[DWL-1:0] 		x_value_i;
	wire 	[DWL-1:0] 		y_value_i;

	//--------------Адреса выбоки\записи данных из\в памяти------------\\
	wire 	[AWL-1:0] 		a_addr_mux;
	wire 	[AWL-1:0] 		b_addr_mux;

	//----------------------Адреса записи данных ----------------------\\
	wire  	[AWL-1:0] 		wr_a_addr;
	wire  	[AWL-1:0] 		wr_b_addr;

	//---------------------Адреса выборки данных ----------------------\\
	wire 	[AWL-1:0] 		r_a_addr;
	wire 	[AWL-1:0] 		r_b_addr;

	//----------------Выходые порты рабочей памяти---------------------\\
	wire 	[DWL-1:0] 		RAM_a_value_r;
	wire 	[DWL-1:0] 		RAM_b_value_r;
	wire 	[DWL-1:0] 		RAM_a_value_i;
	wire 	[DWL-1:0] 		RAM_b_value_i;

	//---------Выходые порты модифицированного входного FIFO-----------\\
	wire 	[DWL-1:0] 		in_FIFO_a_value_r;//
	wire 	[DWL-1:0] 		in_FIFO_b_value_r;//
	wire 	[DWL-1:0] 		in_FIFO_a_value_i;//
	wire 	[DWL-1:0] 		in_FIFO_b_value_i;//

	//------Управляющие сигналы модифицированного входного FIFO--------\\
	wire 					tmp_in_fifo_empty;
	wire 					tmp_in_fifo_full;

	wire					tmp_in_fifo_rst;
	wire					in_fifo_r_en;

	//------Управляющие сигналы модифицированного выходного FIFO-------\\
	wire 					tmp_out_fifo_empty;
	wire 					tmp_out_fifo_full;
	wire 					tmp_out_fifo_block;
	wire					out_fifo_wr_en;
	
	//-----------------------------------------------------------------\\
	//---------------Адрес поворачивающего множителя-------------------\\
	wire 	[AWL-1:0] 		w_addr;

	//-Значение косинуса и синуса формирующие поворачивающий множитель-\\
	wire 	[W_DWL-1:0] 	cos_value;
	wire 	[W_DWL-1:0] 	sin_value;

	//---------------Значение поворачивающего множителя---------------\\
	wire 	[W_DWL-1:0] 	w_value_i;
	wire 	[W_DWL-1:0] 	w_value_r;

	//------Входной регистр бабочки поворачивающего множителя----------\\
	wire 	[W_DWL-1:0] 	reg_w_value_i;
	wire 	[W_DWL-1:0] 	reg_w_value_r;

	
	//-------------------Внешние управляющие сигналы-------------------\\
	wire					tmp_full;
	wire 					tmp_valid;

	//-------------------Вутренние управляющие сигналы-----------------\\
	//-----------------------------------------------------------------\\
	//------Сигал формирующийся во время выполнения первого слоя-------\\
	//-----для мультиплексирования выходных портов входнодго FIFO------\\
	wire 					first_lay;
	wire					first_reg;
	wire					first_reg_en;
	wire 					tmp_block_reg;
	wire 					tmp_block_rst;

	// Сигал формирующийся во время выполнения
	// последнего слоя преобразования 
	// для мультиплексирования выходных 
	// сигналов модуля Butterfly в выходное FIFO
	wire 					last_lay;

	//-------------------------------\\
	wire					tmp_start;
	wire 					busy;
	// Сигнал разрешение формирования следующего одреса выборки\записи данных из\в память
	wire 					addr_en;
	// Сигнал сброса устройсва формирования адресса
	wire 					addr_rst;
	// сигнал смены адрессации для следующего слоя FFT
	wire 					lay_en;
	// Управляющие сигналы рабочей памяти
	wire 					wr;
	wire 					ram_en;
	wire 					ram_en_r;
	wire 					ram_en_wr;
	// Стробирующий сигналала модуля Buttrfly
	wire 					but_strob;
	wire 					strb_out;
	
	//-----------------------------------------------------------------\\
	assign a_value_r_mux		= (first_lay )	? in_FIFO_a_value_r	: RAM_a_value_r;
	assign a_value_i_mux		= (first_lay )	? in_FIFO_a_value_i	: RAM_a_value_i;
	assign b_value_r_mux		= (first_lay )	? in_FIFO_b_value_r	: RAM_b_value_r;
	assign b_value_i_mux		= (first_lay )	? in_FIFO_b_value_i	: RAM_b_value_i;

	//-----------------------------------------------------------------\\
	assign a_addr_mux			= (wr		)	? wr_a_addr			: r_a_addr;
	assign b_addr_mux			= (wr		)	? wr_b_addr			: r_b_addr;

	//-----------------------------------------------------------------\\
	assign w_value_i 			= (INVERSE	)	? sin_value			: -sin_value;
	assign w_value_r 			= 				cos_value;

	//-----------------------------------------------------------------\\
	assign ram_en 				= (last_lay )	? ram_en_r			: ram_en_r | ram_en_wr;

	//-----------------------------------------------------------------\\
	assign in_fifo_r_en			= (first_lay	)	? ram_en_r			:	0;
	assign out_fifo_wr_en		= (last_lay	)	? ram_en_wr			:	0;

	//-----------------------------------------------------------------\\
	assign tmp_start			= tmp_in_fifo_full & (~busy);
	assign tmp_in_fifo_rst		= RST || (IN_FIFO_RST && !tmp_block_reg);
	assign tmp_block_rst		= RST | (tmp_in_fifo_empty & addr_en);

	assign first_reg_en			= ((BUT_CLK_CYCLE == 4) || (BUT_CLK_CYCLE == 5) || (BUT_CLK_CYCLE == 6)) ? ram_en_r : but_strob;
	assign first_lay				= first_reg || tmp_block_reg;

	assign tmp_full				= first_lay || tmp_in_fifo_full;

	//-----------------------------------------------------------------\\
	assign FULL					= tmp_full;
	assign VALID				= tmp_out_fifo_block & tmp_valid;
 

	//----------------Модифицированное входное FIFO--------------------\\
	in_fft_FIFO_unit #(
		.DWL			(DWL						),
		.AWL			(AWL						),
		.BIT_REVERS_WRITE(BIT_REVERS_WRITE			))
	in_fifo(
		.CLK			(CLK						),
		.RST			(tmp_in_fifo_rst			),
		.BLOCK			(tmp_full					),
		.R_INC			(in_fifo_r_en				),
		.WR_INC			(i_WR_DATA					),
		.R_DATA_1_R		(in_FIFO_a_value_r			),
		.R_DATA_1_I		(in_FIFO_a_value_i			),
		.R_DATA_2_R		(in_FIFO_b_value_r			),
		.R_DATA_2_I		(in_FIFO_b_value_i			),
		.WR_DATA_R		(i_DATA_R					),
		.WR_DATA_I		(i_DATA_I					),
		.R_EMPTY		(tmp_in_fifo_empty			),
		.WR_FULL		(tmp_in_fifo_full			)
	);

	//----------доп егистр формирования сигнала first_lay--------------\\
	param_register #(
		.BITNESS		(1							),
		.synch_RESET	(synch_RESET				))
	block_reg(
		.CLK			(CLK						),
		.EN				(tmp_start					),
		.RST			(tmp_block_rst				),
		.i_DATA			(1'b1						),
		.o_DATA			(tmp_block_reg				)
	);

	//------------Регистры формирования сигнала first_lay--------------\\
	param_register #(
		.BITNESS		(1							),
		.synch_RESET	(synch_RESET				))
	firstss_reg(
		.CLK			(CLK						),
		.EN				(first_reg_en				),
		.RST			(RST						),
		.i_DATA			(tmp_block_reg				),
		.o_DATA			(first_reg					)
	);

	butterfly_address_gen_unit #(
		.AWL			(AWL						),
		.synch_RESET	(synch_RESET				))
	butterfly_address_gen(
		.CLK			(CLK						),
		.RST			(addr_rst					),
		.EN				(addr_en					),
		.LAY_EN			(lay_en						),
		.A_ADDR			(r_a_addr					),
		.B_ADDR			(r_b_addr					)
	);

	//Задержка адреса чтения для использования его в качетсве адреса записи\\
	delay_unit #(
		.BITNESS		(AWL						),
		.delay			(a_b_address_delay			),
		.synch_RESET	(synch_RESET				))
	delay_address_A(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(r_a_addr					),
		.o_DATA			(wr_a_addr					)
	);
	//Задержка адреса чтения для использования его в качетсве адреса записи\\
	delay_unit #(
		.BITNESS		(AWL						),
		.delay			(a_b_address_delay			),
		.synch_RESET	(synch_RESET				))
	delay_address_B(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(r_b_addr					),
		.o_DATA			(wr_b_addr					)
	);

	//Блок формирования адреса поворачивающего множителя в таблице синуса и косинуса\\
	w_address_gen_unit #(
		.AWL 			(AWL						),
		.synch_RESET	(synch_RESET				))
	w_address_gen(
		.CLK			(CLK						),
		.RST			(addr_rst					),
		.EN				(addr_en					),
		.LAY_EN			(lay_en						),
		.W_ADDR			(w_addr						)
	);

	//------------------------Таблица синуса---------------------------\\
	sin_table_unit #(
		.DWL			(DWL						),
		.AWL			(AWL-1						),
		.table_division	(2							)) 
	sin_table (
		.i_ADDR			(w_addr[AWL-2:0]			),
		.o_DATA			(sin_value					)
	);

	//-----------------------Таблица косинуса--------------------------\\
	sin_table_unit #(
		.DWL			(DWL						),
		.AWL			(AWL-1						),
		.COS			(1							),
		.table_division	(2							)) 
	cos_table (
		.i_ADDR			(w_addr[AWL-2:0]			),
		.o_DATA			(cos_value					)
	);
	
	//Входной регистр поворачивающего множителя модуля Butterfly + задержка(оционально)\\
	delay_unit #(
		.BITNESS		(W_DWL						),
		.delay			(w_value_delay				),
		.synch_RESET	(synch_RESET				))
	delay_value_w_r(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(w_value_r					),
		.o_DATA			(reg_w_value_r				)
	);

	//Входной регистр поворачивающего множителя модуля Butterfly + задержка(оционально)\\
	delay_unit #(
		.BITNESS		(W_DWL						),
		.delay			(w_value_delay				),
		.synch_RESET	(synch_RESET				))
	delay_value_w_i(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(w_value_i					),
		.o_DATA			(reg_w_value_i				)
	);

	//----------------Входной регистр модуля Butterfly-----------------\\
	param_register #(
		.BITNESS		(DWL						),
		.synch_RESET	(synch_RESET				))
	a_r_reg(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(a_value_r_mux				),
		.o_DATA			(reg_a_value_r				)
	);

	//----------------Входной регистр модуля Butterfly-----------------\\
	param_register #(
		.BITNESS		(DWL						),
		.synch_RESET	(synch_RESET				))
	a_i_reg(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(a_value_i_mux				),
		.o_DATA			(reg_a_value_i				)
	);

	//----------------Входной регистр модуля Butterfly-----------------\\
	param_register #(
		.BITNESS		(DWL						),
		.synch_RESET	(synch_RESET				))
	b_r_reg(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(b_value_r_mux				),
		.o_DATA			(reg_b_value_r				)
	);

	//----------------Входной регистр модуля Butterfly-----------------\\
	param_register #(
		.BITNESS		(DWL						),
		.synch_RESET	(synch_RESET				))
	b_i_reg(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(b_value_i_mux				),
		.o_DATA			(reg_b_value_i				)
	);

	//------------------Выбор модуля опации Бабочка--------------------\\
	complex_butterfly_selection #(
		.IWL1			(DWL						),
		.IWL2			(W_DWL						),
		.OWL			(DWL						),
		.CONSTANT_SHIFT	(butterfly_constant_shift	),
		.synch_RESET	(synch_RESET				),
		.BUT_CLK_CYCLE	(BUT_CLK_CYCLE				)) 
	butterfly(
		.clk 			(CLK 						),	        
		.rst         	(RST         				),
		.strb_in 		(but_strob 					),	  
		// B port 
		.din1_re 		(reg_b_value_r				),	
		.din1_im     	(reg_b_value_i	   			),
		// W port
		.din2_re     	(reg_w_value_r				),  
		.din2_im     	(reg_w_value_i				),
		// A port
		.din3_re		(reg_a_value_r				),  
		.din3_im		(reg_a_value_i				),
		// X port
		.dout1_re     	(x_value_r					),
		.dout1_im     	(x_value_i		   			),
		// Y port
		.dout2_re     	(y_value_r		 			),
		.dout2_im     	(y_value_i		   			),
		
		.strb_out    	(strb_out    				)
	);

	//------------Рабочая память для реальной составляющей-------------\\
	(* DONT_TOUCH = "yes" *) dual_port_RAM_unit #(
		.DWL			(DWL						),
		.AWL			(AWL						),
		.RAM_PERFORMANCE("NO"						)) 
	workt_ram_unit_r (
		.CLK_A			(CLK						),
		.WrE_A			(wr							),
		.EN_A			(ram_en						),
		.RST_A			(RST						),
		.i_DATA_A		(x_value_r					),
		.i_ADDR_A		(a_addr_mux					),
		.o_DATA_A		(RAM_a_value_r				),

		.CLK_B			(CLK						),
		.WrE_B			(wr							),
		.EN_B			(ram_en						),
		.RST_B			(RST						),
		.i_DATA_B		(y_value_r					),
		.i_ADDR_B		(b_addr_mux					),
		.o_DATA_B		(RAM_b_value_r				)
	);

	//-------------Рабочая память для мнимой составляющей--------------\\
	(* DONT_TOUCH = "yes" *) dual_port_RAM_unit #(
		.DWL			(DWL						),
		.AWL			(AWL						),
		.RAM_PERFORMANCE("NO"						)) 
	workt_ram_unit_i (
		.CLK_A			(CLK						),
		.WrE_A			(wr							),
		.EN_A			(ram_en						),
		.RST_A			(RST						),
		.i_DATA_A		(x_value_i					),
		.i_ADDR_A		(a_addr_mux					),
		.o_DATA_A		(RAM_a_value_i				),

		.CLK_B			(CLK						),
		.WrE_B			(wr							),
		.EN_B			(ram_en						),
		.RST_B			(RST						),
		.i_DATA_B		(y_value_i					),
		.i_ADDR_B		(b_addr_mux					),
		.o_DATA_B		(RAM_b_value_i				)
	);

	//----------------Модифицированное выходное FIFO-------------------\\
	out_fft_FIFO_unit #(
		.DWL			(DWL						),
		.AWL			(AWL						),
		.BIT_REVERS_RIDE(0							))
	out_fifo(
		.CLK			(CLK						),
		.RST			(RST						),
		.BLOCK			(tmp_out_fifo_block			),
		.R_INC			(tmp_out_fifo_block			),
		.WR_INC			(out_fifo_wr_en				),
		.R_DATA_R		(o_DATA_R					),
		.R_DATA_I		(o_DATA_I					),
		.WR_DATA_1_R	(x_value_r					),
		.WR_DATA_1_I	(x_value_i					),
		.WR_DATA_2_R	(y_value_r					),
		.WR_DATA_2_I	(y_value_i					),
		.R_EMPTY		(tmp_out_fifo_empty			),
		.WR_FULL		(tmp_out_fifo_full			)
	);

	//------------доп регистр формирования сигнала valid---------------\\
	param_register #(
		.BITNESS		(1							),
		.synch_RESET	(synch_RESET				))
	out_fifo_block_reg(
		.CLK			(CLK						),
		.EN				(tmp_out_fifo_full			),
		.RST			(tmp_out_fifo_empty			),
		.i_DATA			(1'b1						),
		.o_DATA			(tmp_out_fifo_block			)
	);

	//--------------Регистр формирования сигнала valid-----------------\\
	param_register #(
		.BITNESS		(1							),
		.synch_RESET	(synch_RESET				))
	valid_reg(
		.CLK			(CLK						),
		.EN				(EN							),
		.RST			(RST						),
		.i_DATA			(tmp_out_fifo_block			),
		.o_DATA			(tmp_valid					)
	);
	//----------------Выбор управляющего устройства--------------------\\
	control_unit_fft_iter_selection #(
		.LAYERS 		(AWL						),
		.BUTTERFLYES	(BUT_NUM					),
		.LayWL 			(LayWL						),
		.ButtWL 		(AWL-1						),
		.BUT_CLK_CYCLE	(BUT_CLK_CYCLE				))	
	control_unit_selection(
		.CLK			(CLK						),
		.RST			(RST						),
		.EN				(EN							),
		.START			(first_lay					),
		.BUSY			(busy						),
		.BUT_STROB		(but_strob					),
		.LAY_EN			(lay_en						),
		.ADDR_EN		(addr_en					),
		.ADDR_RST		(addr_rst					),
		.RAM_EN_R		(ram_en_r					),
		.RAM_EN_WR		(ram_en_wr					),
		.Wr				(wr							),
		.LAST_LAY		(last_lay					)
	);

endmodule