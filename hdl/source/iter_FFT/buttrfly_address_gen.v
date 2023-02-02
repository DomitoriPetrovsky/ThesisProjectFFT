module butterfly_address_gen_unit #(
	parameter AWL = 5,
	parameter synch_RESET = 1,
	parameter RESET_LEVEL = 1
)(
	input wire 					CLK,
	input wire 					RST,
	input wire 					EN,
	input wire 					LAY_EN,
	output wire 	[AWL-1:0] 	A_ADDR,
	output wire 	[AWL-1:0]	B_ADDR
);
	localparam EDGE 		= 1;
	localparam RESET 		= 1;
	localparam ENABLE 		= 1;
	localparam EN_LEVEL 	= 1;

	localparam shLeft		= 1;
	localparam RESET_VALUE	= 1;


	wire 	[AWL-1:0] addr;
	reg 	[AWL-1:0] next_addr;

	wire 	[AWL-1:0] lay;

	reg 	[AWL-1:0] a;
	reg 	[AWL-1:0] b;

	assign A_ADDR = a;
	assign B_ADDR = b;	

	param_register #(
		.BITNESS	(AWL		),
		.EDGE		(EDGE		),	
		.RESET		(RESET		),
		.synch_RESET(synch_RESET),
		.RESET_LEVEL(RESET_LEVEL),
		.ENABLE		(ENABLE		),
		.EN_LEVEL	(EN_LEVEL	))
	addr_reg(
		.CLK		(CLK		),
		.EN			(EN			),
		.RST		(RST		),
		.i_DATA		(next_addr	),
		.o_DATA		(addr		)
	);

	always @(*) begin
		a <= addr;
		b <= addr | lay;
	end

	always @(*) begin
		next_addr <= ~(lay) & (b + 1);
	end

	ring_shift_register #(
	.BITNESS 		(AWL			),
	.shLeft			(shLeft			),
	.EDGE			(EDGE			),
	.synch_RESET	(synch_RESET	),
	.RESET_LEVEL	(RESET_LEVEL	),
	.RESET_VALUE	(RESET_VALUE	),
	.EN_LEVEL		(EN_LEVEL		))
	ring_reg(
		.CLK		(CLK			),
		.EN			(LAY_EN			),
		.RST		(RST			),	
		.o_DATA		(lay			)
	);
	
/*
	always @(posedge CLK) begin
		if (RST) begin 
			lay <= {{(AWL-1){1'b0}}, 1'b1};
		end else begin
			if (LAY_EN) begin
				lay <= lay << 1;
				lay[0] <= lay[AWL-1];
				//lay <= {lay[AWL-2:0], lay[AWL-1]};
			end else begin 
				lay <= lay;
			end
		end
	end
*/

endmodule