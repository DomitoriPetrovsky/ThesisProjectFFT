module control_unit_fft_iter_5_cyc_but #(
	parameter LAYERS 		= 5,
	parameter BUTTERFLYES 	= 16,
	parameter LayWL 		= 3,
	parameter ButtWL 		= 4
)(
	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,

	input 	wire					START,	

	output 	wire					BUT_STROB,
	output 	wire					LAY_EN,
	output 	wire					ADDR_EN,
	output 	wire					RAM_EN,
	output 	wire					Wr,
	output 	wire					FIRST

);
	localparam FSM_BITNESS = 3;

	localparam FSM_STATE_WAIT 		= 0; // 3'b000
	localparam FSM_STATE_R 			= 4; // 3'b100
	localparam FSM_STATE_STROB	 	= 5; // 3'b101
	localparam FSM_STATE_ADDRgen_WR = 1; // 3'b001
	localparam FSM_STATE_DELAY_1 	= 3; // 3'b011
	localparam FSM_STATE_DELAY_2 	= 2; // 3'b010
	
	
	reg 	[FSM_BITNESS-1:0]	state;
	reg 	[FSM_BITNESS-1:0]	next_state;

	reg 	[ButtWL+LayWL-1:0] 	counter;

	wire 	[ButtWL-1:0]		butt_count;
	wire 	[LayWL-1:0]			lay_count;


	wire 						tmp_but_strob;
	wire 						addr_strob;

	reg							tmp_end;
	wire						tmp_end_next;

	wire						tmp_count_rst;

	wire						tmp_lay_en;
	wire 						tmp_wr;
	wire 						tmp_first;
	wire 						tmp_ram_en;

	assign tmp_but_strob 	= 	(state == FSM_STATE_STROB)		? 1'b1 : 1'b0;
	assign addr_strob 		=	(state == FSM_STATE_ADDRgen_WR)	? 1'b1 : 1'b0; 
	assign tmp_wr 			= 	(state == FSM_STATE_ADDRgen_WR)	? 1'b1 : 1'b0;
	assign tmp_count_rst 	= 	(state == FSM_STATE_WAIT)		? 1'b1 : 1'b0;

	assign tmp_ram_en 		= 	((state == FSM_STATE_R) 		|| 
								(state == FSM_STATE_ADDRgen_WR))? 1'b1 : 1'b0;

	assign tmp_first 		= 	((lay_count == {LayWL{1'b0}}) 	&& 
								(state != FSM_STATE_WAIT))		? 1'b1 : 1'b0;

	assign tmp_end_next 	= 	((butt_count == {ButtWL{1'b0}}) && 
								(lay_count == LAYERS))			? 1'b1 : 1'b0;

	assign tmp_lay_en 		= 	((butt_count == {ButtWL{1'b0}}) && 
								(state == FSM_STATE_ADDRgen_WR) && 
								(lay_count != {LayWL{1'b0}}))	? 1'b1 : 1'b0;
	
								
	assign butt_count 		= 	counter[ButtWL-1:0];
	assign lay_count		= 	counter[ButtWL+LayWL-1:ButtWL];

	assign LAY_EN			= 	tmp_lay_en;
	assign Wr				= 	tmp_wr;
	assign FIRST			= 	tmp_first;
	assign BUT_STROB 		= 	tmp_but_strob;
	assign ADDR_EN 			= 	addr_strob;
	assign RAM_EN 			= 	tmp_ram_en;

	always @(*) begin
		case (state)
			FSM_STATE_WAIT:
				if(START == 1) begin
					next_state <= FSM_STATE_R;
				end else begin
					next_state <= state;
				end
			FSM_STATE_R:
				next_state <= FSM_STATE_DELAY_1;
			FSM_STATE_DELAY_1:
				next_state <= FSM_STATE_STROB;
			FSM_STATE_STROB:
				next_state <= FSM_STATE_ADDRgen_WR;
			FSM_STATE_ADDRgen_WR:
				if(tmp_end == 1) begin
					next_state <= FSM_STATE_WAIT;
				end else begin
					next_state <= FSM_STATE_DELAY_2;
				end
			FSM_STATE_DELAY_2:
				next_state <= FSM_STATE_R;
		endcase
	end

	

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
		if(RST || START) begin 
			tmp_end <= 0;
		end else begin 
			if (tmp_lay_en) begin
				tmp_end <= tmp_end_next;
			end
		end
	end
	
	always @(negedge CLK) begin
		if(RST) begin 
			state <= FSM_STATE_WAIT;
		end else begin 
			if (EN) begin
				state <= next_state;
			end
		end
	end
endmodule