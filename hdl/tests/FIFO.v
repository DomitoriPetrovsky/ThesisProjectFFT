module FIFO_unit #(
	parameter DWL = 16,
	parameter AWL = 8
)(
	input  wire 		  	R_CLK,
	input  wire 		  	WR_CLK,

	input  wire 		  	R_RST,
	input  wire 		  	WR_RST,
	
	input  wire				R_INC,
	input  wire				WR_INC,

	output wire	[DWL-1:0]	R_DATA,
	input wire	[DWL-1:0]	WR_DATA,
	
	output wire 			R_EMPTY,
	output wire 			WR_FULL
);

	wire [AWL-1:0] r_addr;
	wire [AWL-1:0] wr_addr;

	wire [AWL:0] r_ptr;
	wire [AWL:0] wr_ptr;

	wire [AWL:0] r_ptr_sync;
	wire [AWL:0] wr_ptr_sync;

	wire         full;
	wire         empty;

	wire 		 we;

	assign R_EMPTY = empty;
	assign WR_FULL = full;

	assign we = WR_INC & !full;

	wptr_full #(
		.AWL		(AWL			)) 
	write_pointer_full_flag (
		.WR_CLK		(WR_CLK			),
		.WR_RST		(WR_RST			),
		.WR_INC		(WR_INC			),
		.R_PTR_2	(r_ptr_sync		),
		.WR_FULL	(full			),
		.WR_ADDR	(wr_addr		),
		.WR_PTR		(wr_ptr			)
	);

	sync #(
		.AWL		(AWL+1          )) 
	synchronized_wr_ptr_to_R_CLK (
		.CLK		(R_CLK			),
		.RST		(R_RST			),
		.i_DATA		(wr_ptr			),
		.o_DATA		(wr_ptr_sync	)
	);

	rptr_empty #(
		.AWL		(AWL			))
	read_pointer_empty_flagg(
		.R_CLK		(R_CLK			),
		.R_RST		(R_RST			),
		.R_INC		(R_INC			),
		.WR_PTR_2	(wr_ptr_sync	),
		.R_EMPTY	(empty			),
		.R_ADDR		(r_addr			),
		.R_PTR		(r_ptr			)
	);

	sync #(
		.AWL		(AWL+1			)) 
	synchronized_r_ptr_to_WR_CLK (
		.CLK		(WR_CLK			),
		.RST		(WR_RST			),
		.i_DATA		(r_ptr			),
		.o_DATA		(r_ptr_sync		)
	);

	dual_port_RAM_FIFO_MEM_unit #(
		.DWL		(DWL			),
		.AWL		(AWL			)) 
	ram_unit (
		.CLK_A		(WR_CLK			),
		.WrE_A		(we				),
		.EN_A		(WR_INC			),
		.RST_A		(WR_RST			),
		.i_DATA_A	(WR_DATA		),
		.i_ADDR_A	(wr_addr		),
		//.o_DATA_A	(),

		.CLK_B		(R_CLK			),
		.WrE_B		(1'b0			),
		.EN_B		(R_INC			),
		.RST_B		(R_RST			),
		.i_DATA_B	({DWL{1'b0}}	),
		.i_ADDR_B	(r_addr			),
		.o_DATA_B	(R_DATA			)
	);
endmodule

module wptr_full #(
	parameter AWL = 8
) (
	input 	wire 				WR_CLK,
	input 	wire 				WR_RST,
	input 	wire 				WR_INC,
	input 			[AWL:0]		R_PTR_2,
	output 	reg					WR_FULL,
	output 			[AWL-1:0]	WR_ADDR,
	output 	reg		[AWL:0]		WR_PTR
);

	reg [AWL:0] wr_bin, wr_g_next, wr_b_next;

	always @(posedge WR_CLK) begin
		if (WR_RST)begin 
			WR_PTR <= 0;
			wr_bin <= 0;
		end else begin 
			WR_PTR <= wr_g_next;
			wr_bin <= wr_b_next;
		end
	end

	always @(*) begin
		wr_b_next = (!WR_FULL)? (wr_bin + WR_INC) : wr_bin;
		wr_g_next = (wr_b_next >> 1) ^ wr_b_next; //bin to gray
	end

	//MEmory read-address pointer
	assign WR_ADDR = wr_bin[AWL-1:0];

	// FIFO empty on reset or when the next r_ptr == synchronized w_ptr
	always @(posedge WR_CLK) begin
		if (WR_RST) begin 
			WR_FULL = 1'b0;
		end else begin 
			WR_FULL <= ((wr_g_next[AWL]     != R_PTR_2[AWL]  ) &&
						(wr_g_next[AWL-1]   != R_PTR_2[AWL-1]) &&
						(wr_g_next[AWL-2:0] == R_PTR_2[AWL-2:0]));
		end
	end

endmodule



module rptr_empty #(
	parameter AWL = 8
) (
	input 	wire 				R_CLK,
	input 	wire 				R_RST,
	input 	wire 				R_INC,
	input 			[AWL:0]		WR_PTR_2,
	output 	reg					R_EMPTY,
	output 			[AWL-1:0]	R_ADDR,
	output 	reg		[AWL:0]		R_PTR
);

	reg [AWL:0] r_bin, r_g_next, r_b_next;

	always @(posedge R_CLK) begin
		if (R_RST)begin 
			R_PTR <= 0;
			r_bin <= 0;
		end else begin 
			R_PTR <= r_g_next;
			r_bin <= r_b_next;
		end
	end

	always @(*) begin
		r_b_next = (!R_EMPTY)? (r_bin + R_INC) : r_bin;
		r_g_next = (r_b_next >> 1) ^ r_b_next; //bin to gray
	end

	//MEmory read-address pointer
	assign R_ADDR = r_bin[AWL-1:0];

	// FIFO empty on reset or when the next r_ptr == synchronized w_ptr
	always @(posedge R_CLK) begin
		if (R_RST) begin 
			R_EMPTY = 1'b1;
		end else begin 
			R_EMPTY <= (r_g_next == WR_PTR_2);
		end
	end

endmodule


module sync #(
	parameter AWL = 8 
)(
	input 	wire 				CLK,
	input 	wire 				RST,
	input 	wire 	[AWL-1:0] 	i_DATA,
	output 	wire 	[AWL-1:0] 	o_DATA
);

	reg [AWL-1:0] sync_1;
	reg [AWL-1:0] sync_2;

	assign o_DATA = sync_2;

	always @(posedge CLK) begin 
		if (RST) begin
			sync_1 <= {AWL{1'b0}};
			sync_2 <= {AWL{1'b0}};
		end else begin
			sync_1 <= i_DATA;
			sync_2 <= sync_1;
		end 
	end
endmodule


module dual_port_RAM_FIFO_MEM_unit #(
	parameter DWL = 16,
	parameter AWL = 8,
	parameter INIT_FILE = "",
	parameter RAM_PERFORMANCE = "LOW_LATENCY"
)(
	//input  wire				FULL, 

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
	localparam RAM_DEPTH = $rtoi($pow(2, AWL));

	reg [DWL-1:0] RAM [RAM_DEPTH-1:0];
	reg [DWL-1:0] RAM_data_a  = {DWL{1'b0}};
	reg [DWL-1:0] RAM_data_b  = {DWL{1'b0}};

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