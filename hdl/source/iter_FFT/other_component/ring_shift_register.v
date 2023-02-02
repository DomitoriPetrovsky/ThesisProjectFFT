module ring_shift_register #(
	parameter BITNESS = 16,
	parameter shLeft = 1,
	parameter EDGE = 1,
	parameter synch_RESET = 1,
	parameter RESET_LEVEL = 1,
	parameter RESET_VALUE = 1,
	parameter EN_LEVEL = 1
)(
	input  	wire 						CLK,
	input  	wire 						EN,
	input  	wire 						RST,
	output 	wire		[BITNESS-1:0]	o_DATA
);
	
	reg [BITNESS-1:0]	Q;

	wire in_rst;
	wire in_en;

	assign in_en 	= (EN_LEVEL)		? EN 	: ~EN;
	assign in_rst 	= (RESET_LEVEL)		? RST 	: ~RST;

	assign o_DATA 	= Q;

	localparam settings = {|shLeft, |EDGE, |synch_RESET};

	generate
		case (settings)
			3'b000 :
				always @(negedge CLK or in_rst) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = { Q[0], Q[BITNESS-1:1]};
					end
				end
			3'b001 :
				always @(negedge CLK) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = { Q[0], Q[BITNESS-1:1]};
					end
				end
			3'b010 :
				always @(posedge CLK or in_rst) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = { Q[0], Q[BITNESS-1:1]};
					end
				end
			3'b011 :
				always @(posedge CLK) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = { Q[0], Q[BITNESS-1:1]};
					end
				end

			3'b100 :
				always @(negedge CLK or in_rst) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = {Q[BITNESS-2:0], Q[BITNESS-1]};
					end
				end
			3'b101 :
				always @(negedge CLK) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = {Q[BITNESS-2:0], Q[BITNESS-1]};
					end
				end
			3'b110 : 
				always @(posedge CLK or in_rst) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = {Q[BITNESS-2:0], Q[BITNESS-1]};
					end
				end
			3'b111 :
				always @(posedge CLK) begin
					if (in_rst) begin
						Q = RESET_VALUE; 
					end else if (in_en)  begin
						Q = {Q[BITNESS-2:0], Q[BITNESS-1]};
					end
				end
		endcase
	endgenerate
endmodule