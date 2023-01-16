module control_unit_fft_iter #(
	parameter LAYERS = 5,
	parameter BUTTERFLYES = 16,

	parameter LayWL = 3,
	parameter ButtWL = 4
)(
	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,

	input 	wire					START,	

	output 	wire					LAY_EN,
	output 	wire					ADDR_EN,
	output 	wire					Wr,
	output 	wire					FIRST

);

	localparam FSM_BITNESS = 3;

	localparam FSM_STATE_WAIT = 0;
	localparam FSM_STATE_FIRST_R = 1;
	localparam FSM_STATE_FIRST_WR = 2;
	localparam FSM_STATE_OTHERS_R = 3;
	localparam FSM_STATE_OTHERS_WR = 4;



	reg [FSM_BITNESS-1:0]state;
	reg [FSM_BITNESS-1:0]next_state;

	reg [ButtWL+LayWL-1:0] counter;

	wire [ButtWL-1:0]butt_count;
	wire [LayWL-1:0]lay_count;

	assign butt_count = counter[ButtWL-1:0];
	assign lay_count = counter[ButtWL+LayWL-1:ButtWL];

	wire tmp_first;
	wire tmp_end;

	wire tmp_en;
	wire tmp_wr;

	reg tmp_add_en;

	wire tmp_lay_en;
	wire tmp_last_lay;

	assign LAY_EN	= tmp_lay_en & tmp_add_en;//& tmp_wr;
	assign ADDR_EN	= tmp_add_en;//tmp_en;
	assign Wr		= tmp_wr;
	assign FIRST	= tmp_first;

	always @(negedge CLK) begin
		if(RST) begin
			tmp_add_en <= 0;
		end else begin 
			if((state == FSM_STATE_FIRST_WR) || (state == FSM_STATE_OTHERS_WR)) begin
				tmp_add_en <= 1'b1;
			end else begin
				tmp_add_en <= 1'b0;
			end
		end
	end
	

	assign tmp_wr = ((state == FSM_STATE_FIRST_WR) || (state == FSM_STATE_OTHERS_WR))? 1 : 0;
	assign tmp_en = (state != FSM_STATE_WAIT)? !tmp_wr : 0;
	assign tmp_first = ((state == FSM_STATE_FIRST_WR) || (state == FSM_STATE_FIRST_R))? 1 : 0;//(lay_count == ({LayWL{1'b0}}))? 1 : 0;

	always @(*) begin
		case (state)
			FSM_STATE_WAIT:
				if(START == 1) begin
					next_state <= FSM_STATE_FIRST_R;
				end else begin
					next_state <= state;
				end

			FSM_STATE_FIRST_R:
				next_state <= FSM_STATE_FIRST_WR;
				
			FSM_STATE_FIRST_WR:
				if(tmp_lay_en == 1) begin
					next_state <= FSM_STATE_OTHERS_R;
				end else begin
					next_state <= FSM_STATE_FIRST_R;
				end			

			FSM_STATE_OTHERS_R:
				next_state <= FSM_STATE_OTHERS_WR;

				
			FSM_STATE_OTHERS_WR:
				if(tmp_end == 1) begin
					next_state <= FSM_STATE_WAIT;
				end else begin
					next_state <= FSM_STATE_OTHERS_R;
				end
		endcase
	end

	always @(posedge CLK) begin //posedge
		if(RST) begin 
			counter <= 0;
		end else begin 
			if (tmp_en) begin
				counter <= counter + 1;
			end
		end
	end

	assign tmp_lay_en = ((butt_count == {ButtWL{1'b0}}) && (state != FSM_STATE_WAIT) && (lay_count != {ButtWL{1'b0}}))? 1 : 0;


	assign tmp_last_lay = (lay_count == (LAYERS-1))? 1 : 0;

	assign tmp_end = (lay_count == (LAYERS) && (butt_count == {ButtWL{1'b0}}))? 1 : 0; //tmp_lay_en & tmp_last_lay;

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