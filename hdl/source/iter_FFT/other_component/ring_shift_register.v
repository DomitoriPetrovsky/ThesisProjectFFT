module ring_shift_register #(
	parameter BITNESS = 16,
	parameter shLeft = 1,
	parameter RESET_VALUE = 1,
	parameter synch_RESET = 1
)(
	input  	wire 						CLK,
	input  	wire 						EN,
	input  	wire 						RST,
	output 	wire		[BITNESS-1:0]	o_DATA
);
	
	reg [BITNESS-1:0]	Q;

	assign o_DATA 	= Q;

	if (synch_RESET == 0) begin
		if (shLeft == 0) begin 
			always @(posedge CLK or posedge RST) begin
				if (RST) begin
					Q <= RESET_VALUE; 
				end else begin 
					if (EN)  begin
						Q <= { Q[0], Q[BITNESS-1:1]};
					end
				end
			end
		end else begin 
			always @(posedge CLK or posedge RST) begin
				if (RST) begin
					Q <= RESET_VALUE; 
				end else begin 
					if (EN)  begin
						Q <= {Q[BITNESS-2:0], Q[BITNESS-1]};
					end
				end
			end
		end
	end else begin 
		if (shLeft == 0) begin 
			always @(posedge CLK) begin
				if (RST) begin
					Q <= RESET_VALUE; 
				end else begin 
					if (EN)  begin
						Q <= { Q[0], Q[BITNESS-1:1]};
					end
				end
			end
		end else begin 
			always @(posedge CLK) begin
				if (RST) begin
					Q <= RESET_VALUE; 
				end else begin 
					if (EN)  begin
						Q <= {Q[BITNESS-2:0], Q[BITNESS-1]};
					end
				end
			end
		end
	end
endmodule