module w_address_gen_unit #(
	parameter AWL = 5,
	parameter synch_RESET = 1,
	parameter RESET_LEVEL = 1
)(
	input wire 					CLK,
	input wire 					RST,
	input wire 					EN,
	input wire 					LAY_EN,
	output wire 	[AWL-1:0] 	W_ADDR
);

	localparam EDGE 		= 1;
	localparam RESET 		= 1;
	localparam ENABLE 		= 1;
	localparam EN_LEVEL 	= 1;

	localparam shLeft		= 0;
	localparam RESET_VALUE	= {1'b1, {(AWL-1){1'b0}}};


	wire [AWL-1:0] addr;
	wire [AWL-1:0] next_addr;
	wire [AWL-1:0] lay;
	wire [AWL-1:0] mask = {1'b0, {(AWL-1){1'b1}}};

	assign W_ADDR = addr & mask;

	assign next_addr = addr + lay;

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
/*
	always @(posedge CLK) begin
		if (RST) begin 
			addr <= 0;
		end else begin
			if(EN) begin
				addr <= addr + lay;
			end
		end
	end
*/

	ring_shift_register #(
		.BITNESS 		(AWL			),
		.shLeft			(shLeft			),
		.EDGE			(EDGE			),
		.synch_RESET	(synch_RESET	),
		.RESET_LEVEL	(RESET_LEVEL	),
		.RESET_VALUE	(RESET_VALUE	),
		.EN_LEVEL		(EN_LEVEL		))
	ring_reg(
		.CLK			(CLK			),
		.EN				(LAY_EN			),
		.RST			(RST			),	
		.o_DATA			(lay			)
	);
	
/*
	always @(posedge CLK) begin
		if (RST) begin 
			lay <= {1'b1, {(AWL-1){1'b0}}};
		end else begin
			if (LAY_EN) begin
				lay <= {lay[0], lay[AWL-1:1]};
			end
		end
	end
*/
endmodule