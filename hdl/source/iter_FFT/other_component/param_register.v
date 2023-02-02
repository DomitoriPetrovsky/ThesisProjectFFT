module param_register #(
	parameter BITNESS = 16,
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
	output reg	[BITNESS-1:0]	o_DATA
);
	localparam l_settings = {|EDGE, |ENABLE, |RESET, |synch_RESET, |RESET_LEVEL, |EN_LEVEL};

	generate
		case (l_settings)
			6'b100000 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b100001 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b100010 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b100011 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b100100 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b100101 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b100110 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b100111 :
				always @(posedge CLK) begin : reg_posedge_simple
					o_DATA <= i_DATA;
				end	
			6'b101000 :
				always @(posedge CLK or RST) begin : reg_posedge_ASYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b101001 :
				always @(posedge CLK or RST) begin : reg_posedge_ASYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b101010 :
				always @(posedge CLK or RST) begin : reg_posedge_ASYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b101011 :
				always @(posedge CLK or RST) begin : reg_posedge_ASYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b101100 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b101101 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b101110 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end	
			6'b101111 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b110000 :
				always @(posedge CLK) begin : reg_posedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b110010 :
				always @(posedge CLK) begin : reg_posedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b110100 :
				always @(posedge CLK) begin : reg_posedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b110110 :
				always @(posedge CLK) begin : reg_posedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b110001 :
				always @(posedge CLK) begin : reg_posedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b110011 :
				always @(posedge CLK) begin : reg_posedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b110101 :
				always @(posedge CLK) begin : reg_posedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b110111 :
				always @(posedge CLK) begin : reg_posedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b111000 :
				always @(posedge CLK or RST) begin : reg_posedge_ASYNCH_nRST_nEN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b111010 :
				always @(posedge CLK or RST) begin : reg_posedge_ASYNCH_RST_nEN
					if (RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b111100 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_nRST_nEN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b111110 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_RST_nEN
					if (RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end	
			6'b111001 :
				always @(posedge CLK or RST) begin : reg_posedge_AYNCH_nRST_EN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b111011 :
				always @(posedge CLK or RST) begin : reg_posedge_ASYNCH_RST_EN
					if (RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b111101 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_nRST_EN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b111111 :
				always @(posedge CLK) begin : reg_posedge_SYNCH_RST_EN
					if (RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

			6'b000000 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b000001 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b000010 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b000011 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b000100 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b000101 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b000110 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b000111 :
				always @(negedge CLK) begin : reg_negedge_simple
					o_DATA <= i_DATA;
				end	
			6'b001000 :
				always @(negedge CLK or RST) begin : reg_negedge_ASYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b001001 :
				always @(negedge CLK or RST) begin : reg_negedge_ASYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b001010 :
				always @(negedge CLK or RST) begin : reg_negedge_ASYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b001011 :
				always @(negedge CLK or RST) begin : reg_negedge_ASYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b001100 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b001101 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_nRST
					if (!RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b001110 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end	
			6'b001111 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_RST
					if (RST) begin
						o_DATA <= 0; 
					end else begin
						o_DATA <= i_DATA;
					end
				end
			6'b010000 :
				always @(negedge CLK) begin : reg_negedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b010010 :
				always @(negedge CLK) begin : reg_negedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b010100 :
				always @(negedge CLK) begin : reg_negedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b010110 :
				always @(negedge CLK) begin : reg_negedge_nEN
					if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b010001 :
				always @(negedge CLK) begin : reg_negedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b010011 :
				always @(negedge CLK) begin : reg_negedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b010101 :
				always @(negedge CLK) begin : reg_negedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b010111 :
				always @(negedge CLK) begin : reg_negedge_EN
					if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b011000 :
				always @(negedge CLK or RST) begin : reg_negedge_ASYNCH_nRST_nEN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b011010 :
				always @(negedge CLK or RST) begin : reg_negedge_ASYNCH_RST_nEN
					if (RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b011100 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_nRST_nEN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b011110 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_RST_nEN
					if (RST) begin
						o_DATA <= 0; 
					end else if (!EN)  begin
						o_DATA <= i_DATA;
					end
				end	
			6'b011001 :
				always @(negedge CLK or RST) begin : reg_negedge_AYNCH_nRST_EN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b011011 :
				always @(negedge CLK or RST) begin : reg_negedge_ASYNCH_RST_EN
					if (RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b011101 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_nRST_EN
					if (!RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
			6'b011111 :
				always @(negedge CLK) begin : reg_negedge_SYNCH_RST_EN
					if (RST) begin
						o_DATA <= 0; 
					end else if (EN)  begin
						o_DATA <= i_DATA;
					end
				end
		endcase
	endgenerate
endmodule