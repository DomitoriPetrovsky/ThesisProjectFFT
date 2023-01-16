module top_fft_iter #(
	parameter IWL = 32,
	parameter inverse = 0,
	parameter INIT_FILE = ""
)(	

	input 	wr_res,

	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,
	input 	wire					START,

	input wire 		[IWL-1:0] 		i_A_DATA,
	input wire 		[IWL-1:0] 		i_B_DATA,

	input wire 		[IWL-1:0] 		i_A_ADDR,
	input wire 		[IWL-1:0] 		i_B_ADDR,

	input wire						i_RAM_Wr,
	output wire						o_RAM_BLOCK
);

	localparam AWL = 5;
	localparam DWL = 16;
	localparam WWL = 5;

	//
	wire [IWL-1:0] a_value;
	wire [IWL-1:0] b_value;

	wire [IWL-1:0] x_value;
	wire [IWL-1:0] y_value;

	//
	wire [AWL-1:0] a_addr;
	wire [AWL-1:0] b_addr;
	
	wire [IWL-1:0] RAM_a_value;
	wire [IWL-1:0] RAM_b_value;

	//
	wire [AWL-1:0] in_RAM_a_addr;
	wire [AWL-1:0] in_RAM_b_addr;

	wire [IWL-1:0] in_RAM_a_value;
	wire [IWL-1:0] in_RAM_b_value;

	wire in_RAM_wr;
	//

	wire [DWL-1:0] cos_value;
	wire [DWL-1:0] sin_value;

	wire [DWL-1:0] w_value_i;
	wire [DWL-1:0] w_value_r;

	reg [IWL-1:0] w_value;
	wire [WWL-1:0] w_addr;

	//
	wire first;
	wire lay_en;
	wire wr;
	wire addr_en;


	assign a_value			= (first == 1)? in_RAM_a_value	: RAM_a_value;
	assign b_value			= (first == 1)? in_RAM_b_value	: RAM_b_value;

	assign in_RAM_wr 		= (first == 1)? 0 				: i_RAM_Wr;

	assign in_RAM_a_addr 	= (first == 1)? a_addr 			: i_A_ADDR;
	assign in_RAM_b_addr 	= (first == 1)? b_addr 			: i_B_ADDR;

	assign o_RAM_BLOCK		= first;
	
	dual_port_RAM_unit #(
		.DWL		(IWL			),
		.AWL		(AWL			),
		.INIT_FILE	(INIT_FILE		)) 
	input_ram_unit (
		.CLK_A		(CLK			),
		.WrE_A		(in_RAM_wr		),
		.EN_A		(EN				),
		.RST_A		(RST			),
		.i_DATA_A	(i_A_DATA		),
		.i_ADDR_A	(in_RAM_a_addr	),
		.o_DATA_A	(in_RAM_a_value	),

		.CLK_B		(CLK			),
		.WrE_B		(in_RAM_wr		),
		.EN_B		(EN				),
		.RST_B		(RST			),
		.i_DATA_B	(i_B_DATA		),
		.i_ADDR_B	(in_RAM_b_addr	),
		.o_DATA_B	(in_RAM_b_value	)
	);


	butterfly_address_gen_unit #(
		.AWL(AWL))
	butterfly_address_gen(
		.CLK		(CLK			),
		.RST		(RST			),
		.EN			(addr_en		),
		.LAY_EN		(lay_en			),
		.A_ADDR		(a_addr			),
		.B_ADDR		(b_addr			)
	);


	w_address_gen_unit #(
		.AWL 		(WWL			))
	w_address_gen(
		.CLK		(CLK			),
		.RST		(RST			),
		.EN			(addr_en		),
		.LAY_EN		(lay_en			),
		.W_ADDR		(w_addr			)
	);

	sin_table_unit #(
		.DWL		(DWL			),
		.DFL		(DWL-1			),
		.AWL		(WWL-1			),
		.table_division(2			)) 
	sin_table (
		.i_ADDR		(w_addr[WWL-2:0]),
		.o_DATA		(sin_value		)
	);


	sin_table_unit #(
		.DWL		(DWL			),
		.DFL		(DWL-1			),
		.AWL		(WWL-1			),
		.COS		(1				),
		.table_division(2			)) 
	cos_table (
		.i_ADDR		(w_addr[WWL-2:0]),
		.o_DATA		(cos_value		)
	);

	assign w_value_i = (inverse)? sin_value: -sin_value;
	assign w_value_r = cos_value;


	always @(posedge CLK) begin
		if (RST) begin
			w_value <= 0;
		end else begin
			if (~addr_en) begin
				w_value <= {w_value_r, w_value_i};
			end
		end
	end


	complex_butterfly_simple #(
		.N			(DWL			))
	butterfly(
		.i_Wre		(w_value	[IWL-1:DWL]	), 
		.i_Wim		(w_value	[DWL-1:0]	),
		.i_Bre		(b_value	[IWL-1:DWL]	), 
		.i_Bim		(b_value	[DWL-1:0]	),
		.i_Are		(a_value	[IWL-1:DWL]	), 
		.i_Aim		(a_value	[DWL-1:0]	),
		.o_X_re		(x_value	[IWL-1:DWL]	),
		.o_X_im		(x_value	[DWL-1:0]	),
		.o_Y_re		(y_value	[IWL-1:DWL]	),
		.o_Y_im		(y_value	[DWL-1:0]	)
	);

	dual_port_RAM_unit #(
		.DWL		(IWL			),
		.DEBUG_RES_FILE_NAME ("res.txt"),
		.AWL		(AWL			)) 
	workt_ram_unit (

		.debug_write_res_to_file(wr_res),

		.CLK_A		(CLK			),
		.WrE_A		(wr				),
		.EN_A		(EN				),
		.RST_A		(RST			),
		.i_DATA_A	(x_value		),
		.i_ADDR_A	(a_addr			),
		.o_DATA_A	(RAM_a_value	),

		.CLK_B		(CLK			),
		.WrE_B		(wr				),
		.EN_B		(EN				),
		.RST_B		(RST			),
		.i_DATA_B	(y_value		),
		.i_ADDR_B	(b_addr			),
		.o_DATA_B	(RAM_b_value	)
	);



	control_unit_fft_iter #(
		.LAYERS 	(5				),
		.BUTTERFLYES(16				),
		.LayWL 		(3				),
		.ButtWL 	(4				))	
	control_unit(
		.CLK		(CLK			),
		.RST		(RST			),
		.EN			(EN				),
		.START		(START			),	
		.LAY_EN		(lay_en			),
		.ADDR_EN	(addr_en		),
		.Wr			(wr				),
		.FIRST		(first			)

);


endmodule