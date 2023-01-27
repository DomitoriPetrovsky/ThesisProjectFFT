module dual_port_RAM_unit #(
	parameter DWL = 16,
	parameter AWL = 8,
	parameter INIT_FILE = "",
	parameter DEBUG_RES_FILE_NAME = "",
	parameter RAM_PERFORMANCE = "LOW_LATENCY"
)(

	input wire 				debug_write_res_to_file,

	input  wire 		  	CLK_A,
	input  wire 		  	WrE_A,
	input  wire 		  	EN_A,
	input  wire 		  	RST_A,
	input  wire	[DWL-1:0]	i_DATA_A,
	input  wire	[AWL-1:0]	i_ADDR_A,
	output wire	[DWL-1:0]	o_DATA_A,

	input  wire 		  	CLK_B,
	input  wire 		  	WrE_B,
	input  wire 		  	EN_B,
	input  wire 		  	RST_B,
	input  wire	[DWL-1:0]	i_DATA_B,
	input  wire	[AWL-1:0]	i_ADDR_B,
	output wire	[DWL-1:0]	o_DATA_B
);
	localparam RAM_DEPTH = 2**AWL;

	reg [DWL-1:0] RAM [RAM_DEPTH-1:0];
	reg [DWL-1:0] RAM_data_a  = {DWL{1'b0}};
	reg [DWL-1:0] RAM_data_b  = {DWL{1'b0}};


	always @(debug_write_res_to_file) begin
		if (debug_write_res_to_file) begin 
			$writememh(DEBUG_RES_FILE_NAME, RAM, 0, RAM_DEPTH-1);
		end
	end

	generate
		if (INIT_FILE != "") begin: use_init_file
		  initial
			$readmemh(INIT_FILE, RAM, 0, RAM_DEPTH-1);
		end else begin: init_bram_to_zero
		  integer ram_index;
		  initial
			for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
			  RAM[ram_index] = {DWL{1'b0}};
		end
	endgenerate

	always @(posedge CLK_A) begin
		if (EN_A) begin 
			if (WrE_A) begin
				RAM[i_ADDR_A] <=  i_DATA_A;
			end else begin 
				RAM_data_a <= RAM[i_ADDR_A];
			end
		end
	end

	always @(posedge CLK_B) begin
		if (EN_B) begin 
			if (WrE_B) begin
				RAM[i_ADDR_B] <=  i_DATA_B;
			end else begin 
				RAM_data_b <= RAM[i_ADDR_B];
			end
		end
	end

	generate 
		if (RAM_PERFORMANCE == "LOW_LATENCY") begin : no_output_register
			// The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
			assign o_DATA_A =  RAM_data_a;
			assign o_DATA_B =  RAM_data_b;

		end else begin : output_register
			// The following is a 2 clock cycle read latency with improve clock-to-out timing

			reg [DWL-1:0] dout_a_reg = {DWL{1'b0}};
			reg [DWL-1:0] dout_b_reg = {DWL{1'b0}};

			always @(posedge CLK_A) begin
				if (RST_A) begin 
					dout_a_reg <= {DWL{1'b0}};
				end else begin 
					dout_a_reg <= RAM_data_a;
				end 
			end

			always @(posedge CLK_B) begin
				if (RST_B) begin 
					dout_b_reg <= {DWL{1'b0}};
				end else begin 
					dout_b_reg <= RAM_data_b;
				end 
			end

			assign o_DATA_A =  dout_a_reg;
			assign o_DATA_B =  dout_b_reg;

		end
	endgenerate

endmodule 		
			
	