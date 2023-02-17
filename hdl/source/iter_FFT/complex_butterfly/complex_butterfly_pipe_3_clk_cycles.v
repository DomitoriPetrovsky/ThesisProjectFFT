module complex_butterfly_pipe_3_clk_cycles #(
	parameter IWL1 				= 16,
	parameter IWL2 				= 16,
	parameter AWL 				= 17,
	parameter OWL 				= 16,
	parameter CONSTANT_SHIFT	= 1
)(
	input 	wire 				clk,
	input 	wire 				rst,
	input 	wire 				strb_in,
	input 	wire 	[IWL1-1:0]	din1_re,
	input 	wire 	[IWL1-1:0]	din1_im,
	input 	wire 	[IWL2-1:0]	din2_re,
	input 	wire 	[IWL2-1:0]	din2_im,
	input 	wire 	[IWL1-1:0]	din3_re,
	input 	wire 	[IWL1-1:0]	din3_im,
	output 	reg  	[OWL-1:0]	dout1_re,
	output 	reg  	[OWL-1:0]	dout1_im,
	output 	reg  	[OWL-1:0]	dout2_re,
	output 	reg  	[OWL-1:0]	dout2_im,
	output 	wire				strb_out
);
	localparam PROD_WL = IWL1 + IWL2;
//-----------------------------------------------------------------\\
	wire	signed	[IWL1-1:0]			MUL_1_din1;
	wire	signed	[IWL2-1:0]			MUL_1_din2;

	wire	signed	[IWL1-1:0]			MUL_2_din1;
	wire	signed	[IWL2-1:0]			MUL_2_din2;

	wire	signed	[IWL1-1:0]			MUL_3_din1;
	wire	signed	[IWL2-1:0]			MUL_3_din2;

	wire	signed	[IWL1-1:0]			MUL_4_din1;
	wire	signed	[IWL2-1:0]			MUL_4_din2;

	reg		signed	[PROD_WL-1:0]		tmp_mult_1;
	reg		signed	[PROD_WL-1:0]		tmp_mult_2;
	reg		signed	[PROD_WL-1:0]		tmp_mult_3;
	reg		signed	[PROD_WL-1:0]		tmp_mult_4;

	reg		signed	[AWL:0]				tmp_mult_out_1;
	reg		signed	[AWL:0]				tmp_mult_out_2;
	reg		signed	[AWL:0]				tmp_mult_out_3;
	reg		signed	[AWL:0]				tmp_mult_out_4;

	wire			[AWL:0]				mult_out_1;
	wire			[AWL:0]				mult_out_2;
	wire			[AWL:0]				mult_out_3;
	wire			[AWL:0]				mult_out_4;

	reg				[AWL:0]				mult_out_reg_1;
	reg				[AWL:0]				mult_out_reg_2;
	reg				[AWL:0]				mult_out_reg_3;
	reg				[AWL:0]				mult_out_reg_4;

//-----------------------------------------------------------------\\
	wire 			[AWL:0]				pre_sum_din3_re;
	wire 			[AWL:0]				pre_sum_din3_im;

//-----------------------------------------------------------------\\
	wire	signed	[AWL:0]				ADD_0_din1;
	wire	signed	[AWL:0]				ADD_0_din2;

	wire	signed	[AWL:0]				SUB_0_din1; 
	wire	signed	[AWL:0]				SUB_0_din2;

	//reg		signed	[AWL:0]				tmp_add_0;
	//reg		signed	[AWL:0]				tmp_sub_0;

	reg				[AWL:0]				add_0_out;
	reg				[AWL:0]				sub_0_out;
//-----------------------------------------------------------------\\
	wire	signed	[AWL:0]				ADD_1_din1;
	wire	signed	[AWL:0]				ADD_1_din2;

	wire	signed	[AWL:0]				SUB_1_din1; 
	wire	signed	[AWL:0]				SUB_1_din2;

	reg		signed	[AWL:0]				tmp_add_1;
	reg		signed	[AWL:0]				tmp_sub_1;

	reg				[OWL-1:0]			add_1_out;
	reg				[OWL-1:0]			sub_1_out;
//-----------------------------------------------------------------\\
	wire	signed	[AWL:0]				ADD_2_din1;
	wire	signed	[AWL:0]				ADD_2_din2;

	wire	signed	[AWL:0]				SUB_2_din1;
	wire	signed	[AWL:0]				SUB_2_din2;

	reg		signed	[AWL:0]				tmp_add_2;
	reg		signed	[AWL:0]				tmp_sub_2;

	reg				[OWL-1:0]			add_2_out;
	reg				[OWL-1:0]			sub_2_out;

//-----------------------------------------------------------------\\
	reg				[AWL:0]				re_reg;
	reg				[AWL:0]				im_reg;

	assign strb_out		= 	strb_in;

	assign MUL_1_din1	=	din1_re;
	assign MUL_1_din2	=	din2_re;	
	assign MUL_2_din1	=	din1_im;
	assign MUL_2_din2	=	din2_im;	
	assign MUL_3_din1	=	din1_re;
	assign MUL_3_din2	=	din2_im;	
	assign MUL_4_din1	=	din1_im;
	assign MUL_4_din2	=	din2_re;

	always @(*) begin : mult_alw_1
		tmp_mult_1 = MUL_1_din1 * MUL_1_din2;
		tmp_mult_out_1 = tmp_mult_1[PROD_WL-1:PROD_WL-AWL-1];
	end
	always @(*) begin : mult_alw_2
		tmp_mult_2 = MUL_2_din1 * MUL_2_din2;
		tmp_mult_out_2 = tmp_mult_2[PROD_WL-1:PROD_WL-AWL-1];
	end
	always @(*) begin : mult_alw_3
		tmp_mult_3 = MUL_3_din1 * MUL_3_din2;
		tmp_mult_out_3 = tmp_mult_3[PROD_WL-1:PROD_WL-AWL-1];
	end
	always @(*) begin : mult_alw_4
		tmp_mult_4 = MUL_4_din1 * MUL_4_din2;
		tmp_mult_out_4 = tmp_mult_4[PROD_WL-1:PROD_WL-AWL-1];
	end


	assign mult_out_1 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_1 :  tmp_mult_out_1 >>> 1;
	assign mult_out_2 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_2 :  tmp_mult_out_2 >>> 1;
	assign mult_out_3 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_3 :  tmp_mult_out_3 >>> 1;
	assign mult_out_4 		= (CONSTANT_SHIFT == 0)? tmp_mult_out_4 :  tmp_mult_out_4 >>> 1;


	assign pre_sum_din3_re 	= (CONSTANT_SHIFT == 0)? {din3_re[IWL1-1], din3_re, 1'b0}: {din3_re[IWL1-1], din3_re[IWL1-1], din3_re};
	assign pre_sum_din3_im 	= (CONSTANT_SHIFT == 0)? {din3_im[IWL1-1], din3_im, 1'b0}: {din3_im[IWL1-1], din3_im[IWL1-1], din3_im};
	
	assign ADD_0_din1 =	mult_out_reg_3;
	assign ADD_0_din2 =	mult_out_reg_4;


	always @* begin : add_0_alw
		add_0_out = ADD_0_din1 + ADD_0_din2; 
	end

	assign SUB_0_din1 =	mult_out_reg_1;
	assign SUB_0_din2 =	mult_out_reg_2;


	always @* begin : sub_0_alw
		sub_0_out = SUB_0_din1 - SUB_0_din2;
	end


	assign ADD_1_din1 =	pre_sum_din3_re;
	assign ADD_1_din2 =	re_reg;


	always @* begin : add_1_alw
		tmp_add_1 = ADD_1_din1 + ADD_1_din2 + 2'b01;
		if (tmp_add_1[AWL] == tmp_add_1[AWL-1]) begin 
			add_1_out = tmp_add_1[AWL-1: AWL-OWL];
		end else begin 
			add_1_out[OWL-1] = tmp_add_1[AWL];
			add_1_out[OWL-2:0] = {OWL-1{tmp_add_1[AWL-1]}};
		end 
	end

	assign SUB_1_din1 =	pre_sum_din3_re;
	assign SUB_1_din2 =	re_reg;


	always @* begin : sub_1_alw
		tmp_sub_1 = SUB_1_din1 - SUB_1_din2 + 2'b01;
		if (tmp_sub_1[AWL] == tmp_sub_1[AWL-1]) begin 
			sub_1_out = tmp_sub_1[AWL-1: AWL-OWL];
		end else begin 
			sub_1_out[OWL-1] = tmp_sub_1[AWL];
			sub_1_out[OWL-2:0] = {OWL-1{tmp_sub_1[AWL-1]}};
		end 
	end

	assign ADD_2_din1 = pre_sum_din3_im;
	assign ADD_2_din2 = im_reg; 

	always @* begin : add_2_alw
		tmp_add_2 = ADD_2_din1 + ADD_2_din2 + 2'b01;
		if (tmp_add_2[AWL] == tmp_add_2[AWL-1]) begin 
			add_2_out = tmp_add_2[AWL-1: AWL-OWL];
		end else begin 
			add_2_out[OWL-1] = tmp_add_2[AWL];
			add_2_out[OWL-2:0] = {OWL-1{tmp_add_2[AWL-1]}};
		end 
	end

	assign SUB_2_din1 = pre_sum_din3_im; 
	assign SUB_2_din2 = im_reg; 

	always @* begin : sub_2_alw
		tmp_sub_2 = SUB_2_din1 - SUB_2_din2 + 2'b01;
		if (tmp_sub_2[AWL] == tmp_sub_2[AWL-1]) begin 
			sub_2_out = tmp_sub_2[AWL-1: AWL-OWL];
		end else begin 
			sub_2_out[OWL-1] = tmp_sub_2[AWL];
			sub_2_out[OWL-2:0] = {OWL-1{tmp_sub_2[AWL-1]}};
		end 
	end
	
	always @(posedge clk) begin : pipe
		mult_out_reg_1 <= mult_out_1;
		mult_out_reg_2 <= mult_out_2;
		mult_out_reg_3 <= mult_out_3;
		mult_out_reg_4 <= mult_out_4;
	end

	always @(posedge clk) begin
		re_reg <= sub_0_out;
		im_reg <= add_0_out;
	end

	always @(posedge clk) begin
		if(rst) begin
			dout1_re <= 0;
			dout1_im <= 0;
			dout2_re <= 0;
			dout2_im <= 0;
		end else begin 
			if(strb_in) begin
				dout1_re <= add_1_out;
				dout1_im <= add_2_out;
				dout2_re <= sub_1_out;
				dout2_im <= sub_2_out;
			end
		end
	end


endmodule 		
			
	