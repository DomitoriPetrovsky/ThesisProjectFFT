module top_fft_iter #(
	//parameter IDWL 					= 16,
	parameter DWL 					= 16,
	parameter W_DWL					= 16,
	parameter AWL 					= 5,
	parameter BIT_REVERS_WRITE 		= 1,
	parameter LayWL 				= 4,
	parameter inverse 				= 0,
	parameter BUT_CLK_CYCLE 		= 3,
	parameter DEBUG_RES_FILE_NAME 	= "default_res.txt"
)(	

	input 	wr_res,

	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,

	input 	wire 		[DWL-1:0] 	i_DATA_R,
	input 	wire 		[DWL-1:0] 	i_DATA_I,
	input 	wire					i_WR_DATA,
	output 	wire					FULL,


	output 	wire 		[DWL-1:0] 	o_DATA_R,
	output 	wire 		[DWL-1:0] 	o_DATA_I,
	output 	wire					VALID
);

	localparam WWL 		= AWL;
	localparam BUT_NUM 	= 2^(AWL-1);

	localparam address_delay_edge 			= 1;
	localparam address_delay_reset 			= 0;
	localparam address_delay_reset_level 	= 1;
	localparam address_delay_synch_reset 	= 0;
	localparam address_delay_enable 		= 1;
	localparam address_delay_enable_level 	= 1;

	localparam w_value_delay_edge 			= 1;
	localparam w_value_delay_reset 			= 0;
	localparam w_value_delay_reset_level 	= 1;
	localparam w_value_delay_synch_reset 	= 0;
	localparam w_value_delay_enable 		= 1;
	localparam w_value_delay_enable_level 	= 1;
	
	localparam a_b_address_delay 	= (BUT_CLK_CYCLE == 3) || (BUT_CLK_CYCLE == 2) ? 3	: 2;
	localparam w_value_delay 		= (BUT_CLK_CYCLE == 3) || (BUT_CLK_CYCLE == 2) ? 2	: 1;

	localparam butterfly_constant_shift = 1'b1;

	localparam synch_RESET 	= 1;
	localparam RESET_LEVEL 	= 1;	
	localparam ENABLE_LEVEL = 1;	

	//
	wire 	[DWL-1:0] 		a_value_r;//
	wire 	[DWL-1:0] 		b_value_r;//

	wire 	[DWL-1:0] 		a_value_i;//
	wire 	[DWL-1:0] 		b_value_i;//

	wire  	[DWL-1:0] 		reg_a_value_r;
	wire  	[DWL-1:0] 		reg_b_value_r;

	wire  	[DWL-1:0] 		reg_a_value_i;
	wire  	[DWL-1:0] 		reg_b_value_i;

	wire 	[DWL-1:0] 		x_value_r;
	wire 	[DWL-1:0] 		y_value_r;
	wire 	[DWL-1:0] 		x_value_i;
	wire 	[DWL-1:0] 		y_value_i;
	
	//	
	wire 	[AWL-1:0] 		a_addr;
	wire 	[AWL-1:0] 		b_addr;

	wire  	[AWL-1:0] 		wr_a_addr;
	wire  	[AWL-1:0] 		wr_b_addr;

	
	wire 	[AWL-1:0] 		r_a_addr;
	wire 	[AWL-1:0] 		r_b_addr;

/////////////////////////////
	wire 	[DWL-1:0] 		RAM_a_value_r;//
	wire 	[DWL-1:0] 		RAM_b_value_r;//
	wire 	[DWL-1:0] 		RAM_a_value_i;//
	wire 	[DWL-1:0] 		RAM_b_value_i;//

	wire 					ram_en;
	wire 					ram_en_r;
	wire 					ram_en_wr;
////////////////

	wire 	[DWL-1:0] 		in_FIFO_a_value_r;//
	wire 	[DWL-1:0] 		in_FIFO_b_value_r;//
	wire 	[DWL-1:0] 		in_FIFO_a_value_i;//
	wire 	[DWL-1:0] 		in_FIFO_b_value_i;//

	wire 					tmp_in_fifo_empty;
	wire 					tmp_in_fifo_full;

	wire					in_fifo_r_en;
////////////////

	wire 					tmp_out_fifo_empty;
	wire 					tmp_out_fifo_full;
	wire 					tmp_out_fifo_block;
	wire					out_fifo_wr_en;

////////////////
	wire 					tmp_block;
	wire 					tmp_block_reg;
	wire 					tmp_block_rst;


	wire 					in_RAM_wr;
	//	
	
	wire 	[W_DWL-1:0] 	cos_value;
	wire 	[W_DWL-1:0] 	sin_value;
	
	wire 	[W_DWL-1:0] 	w_value_i;
	wire 	[W_DWL-1:0] 	w_value_r;

	wire 	[W_DWL-1:0] 	reg_w_value_i;
	wire 	[W_DWL-1:0] 	reg_w_value_r;

	wire 	[WWL-1:0] 		w_addr;
	
	//	
	wire 					busy;

	wire					tmp_full;
	wire					tmp_start;

	wire 					first;
	wire					first_reg;
	wire 					lay_en;
	wire 					wr;
	wire 					addr_en;
	wire 					addr_rst;
	wire 					but_strob;
	wire 					strb_out;
	wire 					last_lay;


	assign a_value_r		= (first 	)	? in_FIFO_a_value_r	: RAM_a_value_r;
	assign a_value_i		= (first 	)	? in_FIFO_a_value_i	: RAM_a_value_i;
	assign b_value_r		= (first 	)	? in_FIFO_b_value_r	: RAM_b_value_r;
	assign b_value_i		= (first 	)	? in_FIFO_b_value_i	: RAM_b_value_i;


	assign a_addr			= (wr		)	? wr_a_addr			: r_a_addr;
	assign b_addr			= (wr		)	? wr_b_addr			: r_b_addr;

	assign w_value_i 		= (inverse	)	? sin_value			: -sin_value;
	assign w_value_r 		= 				cos_value;

	assign ram_en 			= (last_lay )	? ram_en_r			: ram_en_r | ram_en_wr;

	assign in_fifo_r_en		= (first	)	? ram_en_r			:	0;
	assign out_fifo_wr_en	= (last_lay	)	? ram_en_wr			:	0;

	assign tmp_start		= tmp_in_fifo_full & (~busy);

	assign tmp_block_rst	= RST | (tmp_in_fifo_empty & but_strob);
	//assign tmp_block		= tmp_block_reg || tmp_in_fifo_full;

	assign first			= first_reg || tmp_block_reg;

	//assign FULL				= tmp_in_fifo_empty || first ;

	//assign first			= first_reg || tmp_block;

	assign tmp_full			= first || tmp_in_fifo_full;
	
	assign FULL				= tmp_full;
	assign VALID			= tmp_out_fifo_block;
 
	
	in_fft_FIFO_unit #(
		.DWL			(DWL				),
		.AWL			(AWL				),
		.BIT_REVERS_WRITE(BIT_REVERS_WRITE	))
	in_fifo(
		.CLK			(CLK				),
		.RST			(RST				),
		.BLOCK			(tmp_full			),//
		.R_INC			(in_fifo_r_en		),
		.WR_INC			(i_WR_DATA			),
		.R_DATA_1_R		(in_FIFO_a_value_r	),
		.R_DATA_1_I		(in_FIFO_a_value_i	),
		.R_DATA_2_R		(in_FIFO_b_value_r	),
		.R_DATA_2_I		(in_FIFO_b_value_i	),
		.WR_DATA_R		(i_DATA_R			),
		.WR_DATA_I		(i_DATA_I			),
		.R_EMPTY		(tmp_in_fifo_empty	),
		.WR_FULL		(tmp_in_fifo_full	)
	);

	param_register #(
		.BITNESS	(1				),
		.synch_RESET(synch_RESET	))
	block_reg(
		.CLK		(CLK				),
		.EN			(tmp_start			),
		.RST		(tmp_block_rst		),
		.i_DATA		(1'b1				),
		.o_DATA		(tmp_block_reg		)
	);

	param_register #(
		.BITNESS	(1				),
		.synch_RESET(synch_RESET	))
	firstss_reg(
		.CLK		(CLK			),
		.EN			(but_strob		),
		.RST		(RST			),
		.i_DATA		(tmp_block_reg	),
		.o_DATA		(first_reg		)
	);

	butterfly_address_gen_unit #(
		.AWL		(AWL			),
		.synch_RESET(synch_RESET	),
		.RESET_LEVEL(RESET_LEVEL	))
	butterfly_address_gen(
		.CLK		(CLK			),
		.RST		(addr_rst		),
		.EN			(addr_en		),
		.LAY_EN		(lay_en			),
		.A_ADDR		(r_a_addr		),
		.B_ADDR		(r_b_addr		)
	);

	delay_unit #(
		.BITNESS		(AWL						),
		.delay			(a_b_address_delay			),
		.EDGE			(address_delay_edge			),
		.RESET			(address_delay_reset		),
		.synch_RESET	(address_delay_synch_reset	),
		.RESET_LEVEL	(address_delay_reset_level	),
		.ENABLE			(address_delay_enable 		),
		.EN_LEVEL		(address_delay_enable_level	))
	delay_address_A(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(r_a_addr					),
		.o_DATA			(wr_a_addr					)
	);

	delay_unit #(
		.BITNESS		(AWL						),
		.delay			(a_b_address_delay			),
		.EDGE			(address_delay_edge			),
		.RESET			(address_delay_reset		),
		.synch_RESET	(address_delay_synch_reset	),
		.RESET_LEVEL	(address_delay_reset_level	),
		.ENABLE			(address_delay_enable 		),
		.EN_LEVEL		(address_delay_enable_level	))
	delay_address_B(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(r_b_addr					),
		.o_DATA			(wr_b_addr					)
	);


	w_address_gen_unit #(
		.AWL 		(WWL			),
		.synch_RESET(synch_RESET	),
		.RESET_LEVEL(RESET_LEVEL	))
	w_address_gen(
		.CLK		(CLK			),
		.RST		(addr_rst		),
		.EN			(addr_en		),
		.LAY_EN		(lay_en			),
		.W_ADDR		(w_addr			)
	);

	sin_table_unit #(
		.DWL		(DWL			),
		//.DFL		(DWL-1			),
		.AWL		(WWL-1			),
		.table_division(2			)) 
	sin_table (
		.i_ADDR		(w_addr[WWL-2:0]),
		.o_DATA		(sin_value		)
	);


	sin_table_unit #(
		.DWL		(DWL			),
		//.DFL		(DWL-1			),
		.AWL		(WWL-1			),
		.COS		(1				),
		.table_division(2			)) 
	cos_table (
		.i_ADDR		(w_addr[WWL-2:0]),
		.o_DATA		(cos_value		)
	);

	delay_unit #(
		.BITNESS		(W_DWL						),
		.delay			(w_value_delay				),
		.EDGE			(w_value_delay_edge			),
		.RESET			(w_value_delay_reset		),
		.synch_RESET	(w_value_delay_synch_reset	),
		.RESET_LEVEL	(w_value_delay_reset_level	),
		.ENABLE			(w_value_delay_enable 		),
		.EN_LEVEL		(w_value_delay_enable_level	))
	delay_value_w_r(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(w_value_r					),
		.o_DATA			(reg_w_value_r				)
	);

	delay_unit #(
		.BITNESS		(W_DWL						),
		.delay			(w_value_delay				),
		.EDGE			(w_value_delay_edge			),
		.RESET			(w_value_delay_reset		),
		.synch_RESET	(w_value_delay_synch_reset	),
		.RESET_LEVEL	(w_value_delay_reset_level	),
		.ENABLE			(w_value_delay_enable 		),
		.EN_LEVEL		(w_value_delay_enable_level	))
	delay_value_w_i(
		.CLK			(CLK						),
		.EN				(but_strob					),
		.RST			(RST						),
		.i_DATA			(w_value_i					),
		.o_DATA			(reg_w_value_i				)
	);

	param_register #(
		.BITNESS	(DWL			),
		.synch_RESET(synch_RESET	))
	a_r_reg(
		.CLK		(CLK			),
		.EN			(but_strob		),
		.RST		(RST			),
		.i_DATA		(a_value_r		),
		.o_DATA		(reg_a_value_r	)
	);

	param_register #(
		.BITNESS	(DWL			),
		.synch_RESET(synch_RESET	))
	a_i_reg(
		.CLK		(CLK			),
		.EN			(but_strob		),
		.RST		(RST			),
		.i_DATA		(a_value_i		),
		.o_DATA		(reg_a_value_i	)
	);

	param_register #(
		.BITNESS	(DWL			),
		.synch_RESET(synch_RESET	))
	b_r_reg(
		.CLK		(CLK			),
		.EN			(but_strob		),
		.RST		(RST			),
		.i_DATA		(b_value_r		),
		.o_DATA		(reg_b_value_r	)
	);

	param_register #(
		.BITNESS	(DWL			),
		.synch_RESET(synch_RESET	))
	b_i_reg(
		.CLK		(CLK			),
		.EN			(but_strob		),
		.RST		(RST			),
		.i_DATA		(b_value_i		),
		.o_DATA		(reg_b_value_i	)
	);



	(* use_dsp = "yes" *) complex_butterfly_selection #(
		.IWL1			(DWL						),
		.IWL2			(W_DWL						),
		.AWL			(DWL+1						),
		.OWL			(DWL						),
		.CONSTANT_SHIFT	(butterfly_constant_shift	),
		.BUT_CLK_CYCLE	(BUT_CLK_CYCLE				)) 
		butterfly(
		.clk 			(CLK 						),	        
		.rst         	(RST         				),
		.strb_in 		(but_strob 					),	  
		// B port 
		.din1_re 		(reg_b_value_r				),	
		.din1_im     	(reg_b_value_i	   			),
		// W port
		.din2_re     	(reg_w_value_r				),  
		.din2_im     	(reg_w_value_i				),
		//  A port
		.din3_re		(reg_a_value_r				),  
		.din3_im		(reg_a_value_i				),
		// X port
		.dout1_re     	(x_value_r					),
		.dout1_im     	(x_value_i		   			),
		// Y port
		.dout2_re     	(y_value_r		 			),
		.dout2_im     	(y_value_i		   			),
		
		.strb_out    	(strb_out    				)
	);

	(* DONT_TOUCH = "yes" *) dual_port_RAM_unit #(
		.DWL		(DWL			),
		.DEBUG_RES_FILE_NAME (DEBUG_RES_FILE_NAME),
		.AWL		(AWL			),
		.RAM_PERFORMANCE("NO")) 
	workt_ram_unit_r (

		.debug_write_res_to_file(wr_res),

		.CLK_A		(CLK			),
		.WrE_A		(wr				),
		.EN_A		(ram_en			),
		.RST_A		(RST			),
		.i_DATA_A	(x_value_r		),
		.i_ADDR_A	(a_addr			),
		.o_DATA_A	(RAM_a_value_r	),

		.CLK_B		(CLK			),
		.WrE_B		(wr				),
		.EN_B		(ram_en			),
		.RST_B		(RST			),
		.i_DATA_B	(y_value_r		),
		.i_ADDR_B	(b_addr			),
		.o_DATA_B	(RAM_b_value_r	)
	);

	(* DONT_TOUCH = "yes" *) dual_port_RAM_unit #(
		.DWL		(DWL			),
		.DEBUG_RES_FILE_NAME (DEBUG_RES_FILE_NAME),
		.AWL		(AWL			),
		.RAM_PERFORMANCE("NO")) 
	workt_ram_unit_i (

		.debug_write_res_to_file(wr_res),

		.CLK_A		(CLK			),
		.WrE_A		(wr				),
		.EN_A		(ram_en			),
		.RST_A		(RST			),
		.i_DATA_A	(x_value_i		),
		.i_ADDR_A	(a_addr			),
		.o_DATA_A	(RAM_a_value_i	),

		.CLK_B		(CLK			),
		.WrE_B		(wr				),
		.EN_B		(ram_en			),
		.RST_B		(RST			),
		.i_DATA_B	(y_value_i		),
		.i_ADDR_B	(b_addr			),
		.o_DATA_B	(RAM_b_value_i	)
	);

	out_fft_FIFO_unit #(
		.DWL			(DWL			),
		.AWL			(AWL			),
		.BIT_REVERS_RIDE(0				))
	out_fifo(
		.CLK			(CLK				),
		.RST			(RST				),
		.BLOCK			(tmp_out_fifo_block	),
		.R_INC			(tmp_out_fifo_block	),
		.WR_INC			(out_fifo_wr_en		),
		.R_DATA_R		(o_DATA_R			),
		.R_DATA_I		(o_DATA_I			),
		.WR_DATA_1_R	(x_value_r			),
		.WR_DATA_1_I	(x_value_i			),
		.WR_DATA_2_R	(y_value_r			),
		.WR_DATA_2_I	(y_value_i			),
		.R_EMPTY		(tmp_out_fifo_empty	),
		.WR_FULL		(tmp_out_fifo_full	)
	);

	param_register #(
		.BITNESS	(1				),
		.synch_RESET(synch_RESET	))
	out_fifo_block_reg(
		.CLK		(CLK				),
		.EN			(tmp_out_fifo_full	),
		.RST		(tmp_out_fifo_empty	),
		.i_DATA		(1'b1				),
		.o_DATA		(tmp_out_fifo_block	)
	);


	control_unit_fft_iter_selection #(
		.LAYERS 	(AWL			),
		.BUTTERFLYES(BUT_NUM		),
		.LayWL 		(LayWL			),
		.ButtWL 	(AWL-1			),
		.BUT_CLK_CYCLE(BUT_CLK_CYCLE))	
	control_unit_selection(
		.CLK		(CLK				),
		.RST		(RST				),
		.EN			(EN					),
		.START		(first	),
		.BUSY		(busy				),
		.BUT_STROB	(but_strob			),
		.LAY_EN		(lay_en				),
		.ADDR_EN	(addr_en			),
		.ADDR_RST	(addr_rst			),
		.RAM_EN_R	(ram_en_r			),
		.RAM_EN_WR	(ram_en_wr			),
		.Wr			(wr					),
		.LAST_LAY	(last_lay			)
	);

endmodule