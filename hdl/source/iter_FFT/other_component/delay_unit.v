module delay_unit #(
	parameter BITNESS = 16,
	parameter delay = 3,
	parameter EDGE = 1,
	parameter RESET = 1,
	parameter synch_RESET = 1,
	parameter RESET_LEVEL = 1,
	parameter ENABLE = 1,
	parameter EN_LEVEL = 1
)(
	input  wire 		  		CLK,
	input  wire 		  		EN,
	input  wire 		  		RST,
	input  wire	[BITNESS-1:0]	i_DATA,
	output wire	[BITNESS-1:0]	o_DATA
);
	wire [BITNESS-1:0] conections [delay:0];

	assign conections[0] 	= i_DATA;
	assign o_DATA 			= conections[delay];

	genvar i;

	generate
		for (i = 0; i < delay; i = i + 1) begin 
			param_register #(
			.BITNESS	(BITNESS		),
			.EDGE		(EDGE			),
			.RESET		(RESET			),
			.synch_RESET(synch_RESET	),
			.RESET_LEVEL(RESET_LEVEL	),
			.ENABLE		(ENABLE			),
			.EN_LEVEL	(EN_LEVEL		))
		param (
			.CLK		(CLK			),
			.EN			(EN				),
			.RST		(RST			),
			.i_DATA		(conections[i]	),
			.o_DATA		(conections[i+1])
		);
		end
	endgenerate


endmodule