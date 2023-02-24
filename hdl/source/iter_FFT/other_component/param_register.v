module param_register #(
	parameter BITNESS = 16,
	parameter synch_RESET = 1
)(
	input  wire 		  		CLK,
	input  wire 		  		EN,
	input  wire 		  		RST,
	input  wire	[BITNESS-1:0]	i_DATA,
	output reg	[BITNESS-1:0]	o_DATA
);
	if (synch_RESET == 0) begin
		always @(posedge CLK or posedge RST) begin
			if(RST) begin
				o_DATA <= 0;
			end else begin 
				if (EN) begin 
					o_DATA <= i_DATA;
				end
			end
		end
	end else begin 
		always @(posedge CLK) begin
			if(RST) begin
				o_DATA <= 0;
			end else begin 
				if (EN) begin 
					o_DATA <= i_DATA;
				end
			end
		end
	end
endmodule