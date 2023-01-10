module top_fft_iter #(
	parameter IWL = 32,
	parameter INIT_FILE = ""
)(	
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
	localparam WWL = 4;

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

	always @(posedge CLK) begin
		if (RST) begin
			w_value <= 0;
		end else begin
			if (wr) begin
				w_value <= w_value + 1;
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
		.AWL		(AWL			)) 
	workt_ram_unit (
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