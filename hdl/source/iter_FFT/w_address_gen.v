module w_address_gen_unit #(
	parameter AWL = 5
)(
	input wire 					CLK,
	input wire 					RST,
	input wire 					EN,
	input wire 					LAY_EN,
	output wire 	[AWL-1:0] 	W_ADDR
);

	reg [AWL-1:0] addr;
	reg [AWL-1:0] next_addr;

	reg [AWL-1:0] lay;

	wire [AWL-1:0] mask = {1'b0, {(AWL-1){1'b1}}};

	assign W_ADDR = addr && mask;

	always @(posedge CLK) begin
		if (RST) begin 
			addr <= 0;
		end else begin
			if(EN) begin
				addr <= addr + lay;
			end
		end
	end

	always @(posedge CLK) begin
		if (RST) begin 
			lay <= {1'b1, {(AWL-1){1'b0}}};
		end else begin
			if (LAY_EN) begin
				lay <= {lay[0], lay[AWL-1:1]};
			end
		end
	end

endmodule