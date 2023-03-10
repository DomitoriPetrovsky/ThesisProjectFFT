module complex_butterfly_simple #(
	parameter N = 16
)(
	input wire signed	[N-1:0] i_Wre, i_Wim,
	input wire signed	[N-1:0] i_Bre, i_Bim,
	input wire signed 	[N-1:0] i_Are, i_Aim,
	output reg signed	[N-1:0] o_X_re, o_X_im,
	output reg signed	[N-1:0] o_Y_re, o_Y_im
);

reg signed [2*N-1:0] Wre_Bre;
reg signed [2*N-1:0] Wim_Bim;
reg signed [2*N-1:0] Wre_Bim;
reg signed [2*N-1:0] Wim_Bre;

reg signed [N-1:0] BWre, BWim;

	always@(*) begin
		Wre_Bre <= i_Wre * i_Bre;
		Wim_Bim <= i_Wim * i_Bim;
		Wre_Bim <= i_Wre * i_Bim;
		Wim_Bre <= i_Wim * i_Bre;
	end

	always@(*) begin
		BWre <= Wre_Bre[2*N-1:N] - Wim_Bim[2*N-1:N];
		BWim <= Wre_Bim[2*N-1:N] + Wim_Bre[2*N-1:N];
	end

	always@(*) begin
		o_X_re <= (i_Are >>> 1) + BWre;
		o_X_im <= (i_Aim >>> 1) + BWim;
		o_Y_re <= (i_Are >>> 1) - BWre;
		o_Y_im <= (i_Aim >>> 1) - BWim;
	end

endmodule