module control_unit_fft_iter_selection #(
	parameter LAYERS 		= 5,
	parameter BUTTERFLYES 	= 16,
	parameter LayWL 		= 3,
	parameter ButtWL 		= 4,
	parameter BUT_MUL_COUNT = 1
)(
	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,

	input 	wire					START,	

	output 	wire					BUT_STROB,
	output 	wire					LAY_EN,
	output 	wire					ADDR_EN,
	output 	wire					Wr,
	output 	wire					FIRST
);
	generate
		if (BUT_MUL_COUNT == 1) begin
			control_unit_fft_iter_but1 #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.Wr			(Wr				),
				.FIRST		(FIRST			));	
		end
		if (BUT_MUL_COUNT == 2) begin
			control_unit_fft_iter_but2 #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.Wr			(Wr				),
				.FIRST		(FIRST			));	
		end
		if (BUT_MUL_COUNT == 4) begin
			control_unit_fft_iter_but4 #(
				.LAYERS 	(LAYERS			),
				.BUTTERFLYES(BUTTERFLYES	),
				.LayWL 		(LayWL			),
				.ButtWL 	(ButtWL			))	
			control_unit(
				.CLK		(CLK			),
				.RST		(RST			),
				.EN			(EN				),
				.START		(START			),
				.BUT_STROB	(BUT_STROB		),
				.LAY_EN		(LAY_EN			),
				.ADDR_EN	(ADDR_EN		),
				.Wr			(Wr				),
				.FIRST		(FIRST			));	
		end
		//if (BUT_MUL_COUNT == 0) begin
		//end
	endgenerate




endmodule