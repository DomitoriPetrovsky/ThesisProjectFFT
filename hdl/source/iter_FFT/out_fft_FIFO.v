module out_fft_FIFO_unit #(
	parameter DWL 					= 16,
	parameter AWL 					= 8,
	parameter BIT_REVERS_RIDE 		= 1
)(
	input  wire 		  	CLK,
	input  wire 		  	RST,
	input  wire 		  	BLOCK,
	
	input  wire				R_INC,
	input  wire				WR_INC,

	output wire	[DWL-1:0]	R_DATA_R,
	output wire	[DWL-1:0]	R_DATA_I,

	input wire	[DWL-1:0]	WR_DATA_1_R,
	input wire	[DWL-1:0]	WR_DATA_1_I,

	input wire	[DWL-1:0]	WR_DATA_2_R,
	input wire	[DWL-1:0]	WR_DATA_2_I,
	
	output wire 			R_EMPTY,
	output wire 			WR_FULL
);

	wire 				WrE_A;	
	wire 				EN_A;
	wire 				EN_B;
	wire 	[AWL-1:0]	i_ADDR_B;


	reg [AWL-1:0] r_addr;
	wire [AWL-1:0] normal_r_addr;


	wire [AWL-1:0] wr_addr;
	wire [AWL-1:0] wr_addr_2;	

	wire [AWL:0] r_ptr;
	wire [AWL:0] wr_ptr;

	wire         full;
	wire         empty;

	wire 		 en_r;
	wire 		 en_wr;

	assign en_r = R_INC & !empty;
	assign en_wr = WR_INC & !full;

	assign WrE_B 	= (BLOCK)?	1'b0 		: 1'b1;
	assign EN_B 	= (BLOCK)? 	en_r 		: en_wr;
	assign i_ADDR_B = (BLOCK)? 	r_addr 		: wr_addr_2;

	assign R_EMPTY = empty;
	assign WR_FULL = full;

	assign EN_A 	= en_wr;

	generate
		if (BIT_REVERS_RIDE) begin 
			always @(normal_r_addr) 
				r_addr = BIT_REV(normal_r_addr);
		end else begin 
			always @(normal_r_addr) 
				r_addr = normal_r_addr;
		end
	endgenerate
	
	out_fft_FIFO_wptr_full #(
		.AWL		(AWL			)) 
	write_pointer_full_flag (
		.WR_CLK		(CLK			),
		.WR_RST		(RST			),
		.WR_INC		(WR_INC			),
		.BLOCK		(BLOCK			),
		.R_PTR_2	(r_ptr			),
		.WR_FULL	(full			),
		.WR_ADDR	(wr_addr		),
		.WR_ADDR_2	(wr_addr_2		),
		.WR_PTR		(wr_ptr			)
	);


	out_fft_FIFO_rptr_empty #(
		.AWL		(AWL			))
	read_pointer_empty_flagg(
		.R_CLK		(CLK			),
		.R_RST		(RST			),
		.R_INC		(R_INC			),
		.BLOCK		(BLOCK			),
		.WR_PTR_2	(wr_ptr			),
		.R_EMPTY	(empty			),
		.R_ADDR		(normal_r_addr	),
		.R_PTR		(r_ptr			)
	);


	out_fft_FIFO_dual_port_RAM_MEM_unit #(
		.DWL		(DWL			),
		.AWL		(AWL			)) 
	ram_unit_r (
		.CLK_A		(CLK			),
		.WrE_A		(1'b1			),
		.EN_A		(EN_A			),
		.RST_A		(RST			),
		.i_DATA_A	(WR_DATA_1_R	),
		.i_ADDR_A	(wr_addr		),
		//.o_DATA_A	(R_DATA_R		),

		.CLK_B		(CLK			),
		.WrE_B		(WrE_B			),
		.EN_B		(EN_B			),
		.RST_B		(RST			),
		.i_DATA_B	(WR_DATA_2_R	),
		.i_ADDR_B	(i_ADDR_B		),
		.o_DATA_B	(R_DATA_R		)
	);

	out_fft_FIFO_dual_port_RAM_MEM_unit #(
		.DWL		(DWL			),
		.AWL		(AWL			)) 
	ram_unit_i (
		.CLK_A		(CLK			),
		.WrE_A		(1'b1			),
		.EN_A		(EN_A			),
		.RST_A		(RST			),
		.i_DATA_A	(WR_DATA_1_I	),
		.i_ADDR_A	(wr_addr		),
		//.o_DATA_A	(R_DATA_2_I		),

		.CLK_B		(CLK			),
		.WrE_B		(WrE_B			),
		.EN_B		(EN_B			),
		.RST_B		(RST			),
		.i_DATA_B	(WR_DATA_2_I	),
		.i_ADDR_B	(i_ADDR_B		),
		.o_DATA_B	(R_DATA_I		)
	);

	function [AWL-1:0] BIT_REV(input [AWL-1:0] A);
		integer i;
		for (i = 0; i < AWL; i = i + 1) begin
			BIT_REV[i] = A[AWL-i-1];
		end 
	endfunction

endmodule

module out_fft_FIFO_wptr_full #(
	parameter AWL = 8
) (
	input 	wire 				WR_CLK,
	input 	wire 				WR_RST,
	input 	wire 				WR_INC,
	input 	wire 				BLOCK,
	input 	wire	[AWL:0]		R_PTR_2,
	output 	reg					WR_FULL,
	output 	wire	[AWL-1:0]	WR_ADDR,
	output 	wire	[AWL-1:0]	WR_ADDR_2,
	output 	wire	[AWL:0]		WR_PTR
);

	reg [AWL-1:0] wr_bin, wr_b_next;

	always @(posedge WR_CLK) begin
		if (WR_RST)begin 
			wr_bin <= 0;
		end else begin 
			wr_bin <= wr_b_next;
		end
	end

	always @(*) begin
		wr_b_next = (!WR_FULL & !BLOCK)? (wr_bin + WR_INC) : wr_bin;
	end

	//MEmory read-address pointer
	assign WR_ADDR = { 1'b0 , wr_bin[AWL-2:0]};
	assign WR_ADDR_2 = { 1'b1 ,wr_bin[AWL-2:0]};
	assign WR_PTR = {wr_b_next[AWL-1], 1'b0, wr_b_next[AWL-2:0]};

	

	// FIFO empty on reset or when the next r_ptr == synchronized w_ptr
	always @(posedge WR_CLK) begin
		if (WR_RST) begin 
			WR_FULL = 1'b0;
		end else begin 
			WR_FULL <= ((WR_PTR[AWL]     != R_PTR_2[AWL]  ) &&
						(WR_PTR[AWL-1:0] == R_PTR_2[AWL-1:0]));
		end
	end

endmodule



module out_fft_FIFO_rptr_empty #(
	parameter AWL = 8
) (
	input 	wire 				R_CLK,
	input 	wire 				R_RST,
	input 	wire 				BLOCK,
	input 	wire 				R_INC,
	input 	wire	[AWL:0]		WR_PTR_2,

	output 	reg					R_EMPTY,

	output 	wire	[AWL-1:0]	R_ADDR,
	output 	wire	[AWL:0]		R_PTR
);

	reg [AWL:0] r_bin, r_b_next;

	always @(posedge R_CLK) begin
		if (R_RST)begin 
			r_bin <= 0;
		end else begin 
			if (R_INC) begin 
				r_bin <= r_b_next;
			end
		end
	end

	always @(*) begin
		r_b_next = (!R_EMPTY & BLOCK)? (r_bin + R_INC) : r_bin;
	end

	//MEmory read-address pointer
	assign R_ADDR = r_bin[AWL-1:0];
	assign R_PTR = r_bin;

	// FIFO empty on reset or when the next r_ptr == synchronized w_ptr
	always @(posedge R_CLK) begin
		if (R_RST) begin 
			R_EMPTY = 1'b1;
		end else begin 
			R_EMPTY <= (r_b_next == WR_PTR_2);
		end
	end

endmodule

module out_fft_FIFO_dual_port_RAM_MEM_unit #(
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