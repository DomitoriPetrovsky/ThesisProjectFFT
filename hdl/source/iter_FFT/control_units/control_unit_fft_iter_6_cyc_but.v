//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: control_unit_fft_iter_6_cyc_but
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: Устройство управления итерационным FFT с периодом 
// выполнения одной операции Бабочка 6 тактов.
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
//
//
// Transition graph:
//					 ___________________________________________________________________
//					/																	\
//		 START		V																	|
// [WAIT] --> [READ(R)] --> [DELAY_1] --> [STROB] --> [ADDRgen_WR] --> [DELAY_2] --> [DELAY_3]
//	^	|											tmp_end	| 
//	\	V													/	
//	 -------------------------------------------------------
//
//-----------------------------------------------------------------\\

module control_unit_fft_iter_6_cyc_but #(
	parameter LAYERS 		= 5,
	parameter BUTTERFLYES 	= 16,
	parameter LayWL 		= 3,
	parameter ButtWL 		= 4
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
	localparam FSM_BITNESS = 3;

	//-----------------Состояние управляющего автомата-----------------\\
	localparam FSM_STATE_WAIT 		= 0; // 3'b000
	localparam FSM_STATE_R 			= 4; // 3'b100
	localparam FSM_STATE_DELAY_1 	= 6; // 3'b110
	localparam FSM_STATE_STROB	 	= 7; // 3'b111
	localparam FSM_STATE_ADDRgen_WR = 3; // 3'b011
	localparam FSM_STATE_DELAY_2 	= 1; // 3'b001
	localparam FSM_STATE_DELAY_3 	= 5; // 3'b101
	
	
	reg 	[FSM_BITNESS-1:0]	state;
	reg 	[FSM_BITNESS-1:0]	next_state;

	//----------------Счетчик слоев и операций Бабочка-----------------\\
	reg 	[ButtWL+LayWL-1:0] 	counter;

	wire 	[ButtWL-1:0]		butt_count;
	wire 	[LayWL-1:0]			lay_count;

	//-----------------------Формируемые сигналы-----------------------\\
	wire						tmp_last_lay_en;
	reg							tmp_last_lay;

	wire 						tmp_but_strob;
	wire 						tmp_addr_en;

	wire						tmp_end;
	wire						tmp_end_next;

	wire						tmp_count_rst;

	wire						tmp_busy;

	wire						tmp_addr_rst;
	wire						tmp_lay_en;
	wire 						tmp_wr;
	wire 						tmp_ram_en_r;
	wire 						tmp_ram_en_wr;

	//-------------------Условия формирования сигналов-----------------\\
	assign tmp_busy 		= 	(state != FSM_STATE_WAIT)		? 1'b1 : 1'b0;
	assign tmp_but_strob 	= 	(state == FSM_STATE_STROB)		? 1'b1 : 1'b0;
	assign tmp_addr_en 		=	(state == FSM_STATE_ADDRgen_WR)	? 1'b1 : 1'b0; 
	assign tmp_wr 			= 	(state == FSM_STATE_ADDRgen_WR)	? 1'b1 : 1'b0;
	assign tmp_addr_rst 	= 	(state == FSM_STATE_WAIT)		? 1'b1 : 1'b0;
	assign tmp_count_rst 	= 	(state == FSM_STATE_WAIT)		? 1'b1 : 1'b0;
	assign tmp_ram_en_r 	= 	(state == FSM_STATE_R) 			? 1'b1 : 1'b0;
	assign tmp_ram_en_wr 	= 	(state == FSM_STATE_ADDRgen_WR) ? 1'b1 : 1'b0;

	assign tmp_end		 	= 	((butt_count == 1)				&&
								(lay_count == LAYERS))			? 1'b1 : 1'b0;

	assign tmp_last_lay_en	= 	((butt_count == 1)				&&  
								(lay_count == LAYERS-1))		? 1'b1 : 1'b0;

	assign tmp_lay_en 		= 	((butt_count == {ButtWL{1'b0}}) && 
								(state == FSM_STATE_ADDRgen_WR) && 
								(lay_count != {LayWL{1'b0}}))	? 1'b1 : 1'b0;
	
								
	assign butt_count 		= 	counter[ButtWL-1:0];
	assign lay_count		= 	counter[ButtWL+LayWL-1:ButtWL];


	//-----------------------------------------------------------------\\
	assign LAY_EN			= 	tmp_lay_en;
	assign Wr				= 	tmp_wr;
	assign LAST_LAY			= 	tmp_last_lay;
	assign BUT_STROB 		= 	tmp_but_strob;
	assign ADDR_EN 			= 	tmp_addr_en;
	assign RAM_EN_R			=	tmp_ram_en_r ;
	assign RAM_EN_WR		=	tmp_ram_en_wr;
	assign ADDR_RST			=	tmp_addr_rst;
	assign BUSY 			=	tmp_busy;

	//------------------------Условия переходов------------------------\\
	//--------------------^^----------------------^^-------------------\\
	//--------------------||-См.Transition graph -||-------------------\\
	always @(*) begin
		case (state)
			FSM_STATE_WAIT:
				if(START == 1) begin
					next_state = FSM_STATE_R;
				end else begin
					next_state = state;
				end
			FSM_STATE_R:
				next_state = FSM_STATE_DELAY_1;
			FSM_STATE_DELAY_1:
				next_state = FSM_STATE_STROB;
			FSM_STATE_STROB:
				next_state = FSM_STATE_ADDRgen_WR;
			FSM_STATE_ADDRgen_WR:
				if(tmp_end == 1) begin
					next_state = FSM_STATE_WAIT;
				end else begin
					next_state = FSM_STATE_DELAY_2;
				end
			FSM_STATE_DELAY_2:
				next_state = FSM_STATE_DELAY_3;
			FSM_STATE_DELAY_3:
				next_state = FSM_STATE_R;
		endcase
	end

	//----------------Счетчик слоев и операций Бабочка-----------------\\
	always @(posedge CLK) begin
		if(tmp_count_rst) begin 
			counter <= 0;
		end else begin 
			if (tmp_but_strob) begin
				counter <= counter + 1;
			end
		end
	end

	always @(posedge CLK) begin
		if(tmp_count_rst) begin 
			tmp_last_lay <= 0;
		end else begin 
			if (tmp_last_lay_en) begin
				tmp_last_lay <= 1;
			end
		end
	end

	//-------------------------Регистр состояний-----------------------\\
	always @(posedge CLK) begin
		if(RST) begin 
			state <= FSM_STATE_WAIT;
		end else begin 
			if (EN) begin
				state <= next_state;
			end
		end
	end
endmodule