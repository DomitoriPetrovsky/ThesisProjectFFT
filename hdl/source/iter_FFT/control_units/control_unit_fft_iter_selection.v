module control_unit_fft_iter_selection #(
	parameter LAYERS 		= 5,
	parameter BUTTERFLYES 	= 16,
	parameter LayWL 		= 3,
	parameter ButtWL 		= 4,
	parameter BUT_CLK_CYCLE = 5
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
	generate
		if (BUT_CLK_CYCLE == 5) begin
			control_unit_fft_iter_5_cyc_but #(
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
				.RAM_EN		(RAM_EN			),
				.Wr			(Wr				),
				.FIRST		(FIRST			));	
		end
		if (BUT_CLK_CYCLE == 4) begin
			control_unit_fft_iter_4_cyc_but #(
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
				.RAM_EN		(RAM_EN			),
				.Wr			(Wr				),
				.FIRST		(FIRST			));	
		end
		if (BUT_CLK_CYCLE == 3) begin
			control_unit_fft_iter_3_cyc_but #(
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
				.RAM_EN		(RAM_EN			),
				.Wr			(Wr				),
				.FIRST		(FIRST			));	
		end
		if (BUT_CLK_CYCLE == 2) begin
			control_unit_fft_iter_2_cyc_but #(
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
				.RAM_EN		(RAM_EN			),
				.Wr			(Wr				),
				.FIRST		(FIRST			));	
		end
	endgenerate
endmodule