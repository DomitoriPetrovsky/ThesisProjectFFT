module butterfly_address_gen_unit #(
	parameter AWL = 5
)(
	input wire 					CLK,
	input wire 					RST,
	input wire 					EN,
	input wire 					LAY_EN,
	output wire 	[AWL-1:0] 	A_ADDR,
	output wire 	[AWL-1:0]	B_ADDR
);

	reg [AWL-1:0] addr;
	reg [AWL-1:0] next_addr;

	reg [AWL-1:0] lay;
	reg [AWL-1:0] not_lay;

	reg [AWL-1:0] a;
	reg [AWL-1:0] b;

	assign A_ADDR = a;
	assign B_ADDR = b;	

	always @(posedge CLK) begin
		if (RST) begin 
			addr <= 0;
		end else begin
			if(EN) begin
				addr <= next_addr;
			end
		end
	end

	always @(*) begin
		a <= addr;
		b <= addr | lay;
	end

	always @(*) begin
		not_lay <= ~(lay);
	end

	always @(*) begin
		next_addr <= not_lay & (b + 1);
	end

	always @(posedge CLK) begin
		if (RST) begin 
			lay <= {1'b1, {(AWL-1){1'b0}}};
		end else begin
			if (LAY_EN) begin
				lay <= {lay[AWL-2:0], lay[AWL-1]};
			end
		end
	end


endmodule