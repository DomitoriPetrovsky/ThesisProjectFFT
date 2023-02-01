module complex_butterfly_selection #(
	parameter IWL1 				= 16,
	parameter IWL2 				= 16,
	parameter AWL 				= 17,
	parameter OWL 				= 16,
	parameter CONSTANT_SHIFT	= 1,
	parameter BUT_CLK_CYCLE 	= 5
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
	output 	wire  	[OWL-1:0]	dout1_re,
	output 	wire  	[OWL-1:0]	dout1_im,
	output 	wire  	[OWL-1:0]	dout2_re,
	output 	wire  	[OWL-1:0]	dout2_im,
	output 	wire				strb_out
);
	generate 
		if (BUT_CLK_CYCLE == 5) begin
			complex_butterfly_iter_5_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.AWL			(AWL			),
				.OWL			(OWL			),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	)) 
			cplx_but_1MUL(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 4) begin
			complex_butterfly_iter_4_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.AWL			(AWL			),
				.OWL			(OWL			),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	)) 
			cplx_but_2MUL(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 3) begin
			complex_butterfly_iter_3_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.AWL			(AWL			),
				.OWL			(OWL			),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	))
			cplx_but_4MUL(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
		if (BUT_CLK_CYCLE == 2) begin
			complex_butterfly_iter_2_clk_cycles #(
				.IWL1			(IWL1			),
				.IWL2			(IWL2			),
				.AWL			(AWL			),
				.OWL			(OWL			),
				.CONSTANT_SHIFT	(CONSTANT_SHIFT	))
			cplx_but_4MUL(
				.clk 			(clk 			),	        
				.rst         	(rst         	),
				.strb_in 		(strb_in 		),	    
				.din1_re 		(din1_re 		),	//B    
				.din1_im     	(din1_im     	),
				.din2_re     	(din2_re     	),  // W
				.din2_im     	(din2_im     	),
				.din3_re		(din3_re		),  // A
				.din3_im		(din3_im		),
				.dout1_re     	(dout1_re     	),
				.dout1_im     	(dout1_im     	),
				.dout2_re     	(dout2_re     	),
				.dout2_im     	(dout2_im     	),
				.strb_out    	(strb_out    	)
			);
		end
	endgenerate
endmodule	