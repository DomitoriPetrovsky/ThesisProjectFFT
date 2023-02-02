module top_fft_iter #(
	parameter IWL 					= 32,
	parameter IDWL 					= 16,
	parameter AWL 					= 5,
	parameter LayWL 				= 4,
	parameter inverse 				= 0,
	parameter INIT_FILE 			= "",
	parameter BUT_CLK_CYCLE 		= 3,
	parameter DEBUG_RES_FILE_NAME 	= "default_res.txt"
)(	

	input 	wr_res,

	input 	wire					CLK,
	input 	wire					RST,
	input 	wire					EN,
	input 	wire					START,

	input wire 		[IWL-1:0] 		i_A_DATA,
	input wire 		[IWL-1:0] 		i_B_DATA,

	input wire 		[AWL-1:0] 		i_A_ADDR,
	input wire 		[AWL-1:0] 		i_B_ADDR,

	input wire						i_RAM_Wr,
	output wire						o_RAM_BLOCK
);

	localparam DWL = IDWL;
	localparam W_DWL = IDWL;
	localparam WWL = AWL;
	localparam BUT_NUM = 2^(AWL-1);

	localparam synch_RESET = 1;
	localparam RESET_LEVEL = 1;	

	//
	wire 	[IWL-1:0] 		a_value;
	wire 	[IWL-1:0] 		b_value;
	
	reg  	[IWL-1:0] 		reg_a_value;
	reg  	[IWL-1:0] 		reg_b_value;
	
	wire 	[IWL-1:0] 		x_value;
	wire 	[IWL-1:0] 		y_value;
	
	//	
	wire 	[AWL-1:0] 		a_addr;
	wire 	[AWL-1:0] 		b_addr;
		
	reg  	[AWL-1:0] 		wr_a_addr;
	reg  	[AWL-1:0] 		wr_b_addr;
	
	reg  	[AWL-1:0] 		wr_tmp1_a_addr;
	reg  	[AWL-1:0] 		wr_tmp1_b_addr;

	reg  	[AWL-1:0] 		wr_tmp2_a_addr;
	reg  	[AWL-1:0] 		wr_tmp2_b_addr;
	
	
	wire 	[AWL-1:0] 		r_a_addr;
	wire 	[AWL-1:0] 		r_b_addr;
	
	wire 	[IWL-1:0] 		RAM_a_value;
	wire 	[IWL-1:0] 		RAM_b_value;
	
	//	
	wire 	[AWL-1:0] 		in_RAM_a_addr;
	wire 	[AWL-1:0] 		in_RAM_b_addr;
	
	wire 	[IWL-1:0] 		in_RAM_a_value;
	wire 	[IWL-1:0] 		in_RAM_b_value;
	
	wire 					in_RAM_wr;
	//	
	
	wire 	[DWL-1:0] 		cos_value;
	wire 	[DWL-1:0] 		sin_value;
	
	wire 	[W_DWL-1:0] 	w_value_i;
	wire 	[W_DWL-1:0] 	w_value_r;
	
	reg  	[W_DWL*2-1:0] 	reg_w_value;
	reg  	[W_DWL*2-1:0] 	reg_w_tmp_value;
	wire 	[WWL-1:0] 		w_addr;
	
	//	
	wire 					first;
	wire 					lay_en;
	wire 					wr;
	wire 					addr_en;
	wire 					ram_en;
	wire 					but_strob;
	wire 					strb_out;
	
	assign a_value			= (first == 1)	? in_RAM_a_value	: RAM_a_value;
	assign b_value			= (first == 1)	? in_RAM_b_value	: RAM_b_value;

	assign a_addr			= (wr == 1)		? wr_a_addr			: r_a_addr;
	assign b_addr			= (wr == 1)		? wr_b_addr			: r_b_addr;

	assign w_value_i 		= (inverse)		? sin_value			: -sin_value;
	assign w_value_r 		= 				cos_value;

	assign in_RAM_wr 		= (first == 1)	? 0 				: i_RAM_Wr;

	assign in_RAM_a_addr 	= (first == 1)	? r_a_addr 			: i_A_ADDR;
	assign in_RAM_b_addr 	= (first == 1)	? r_b_addr 			: i_B_ADDR;

	assign o_RAM_BLOCK		= first;
	
	generate
		if ((BUT_CLK_CYCLE == 3) || (BUT_CLK_CYCLE == 2)) begin
			always @(posedge CLK) begin
				if (but_strob) begin
					wr_tmp1_a_addr <= r_a_addr;
					wr_tmp1_b_addr <= r_b_addr;

					wr_tmp2_a_addr <= wr_tmp1_a_addr;
					wr_tmp2_b_addr <= wr_tmp1_b_addr;

					wr_a_addr <= wr_tmp2_a_addr; 
					wr_b_addr <= wr_tmp2_b_addr;
				end
			end
			always @(posedge CLK) begin
				if (but_strob) begin
					reg_w_tmp_value <= {w_value_r, w_value_i};
					reg_w_value 	<= reg_w_tmp_value;
				end
			end
		end else begin
			always @(posedge CLK) begin
				if (but_strob) begin
					wr_tmp1_a_addr <= r_a_addr;
					wr_tmp1_b_addr <= r_b_addr;
		
					wr_a_addr <= wr_tmp1_a_addr; 
					wr_b_addr <= wr_tmp1_b_addr;
				end
			end
			always @(posedge CLK) begin
				if (but_strob) begin
					reg_w_value <= {w_value_r, w_value_i};
				end
			end
		end
	endgenerate
	

	always @(posedge CLK) begin
		if (RST) begin
			reg_a_value <= 0;
			reg_b_value <= 0;
		end else begin 
			if (but_strob) begin
				reg_a_value <= a_value; 
				reg_b_value <= b_value;
			end
		end
	end



	dual_port_RAM_unit #(
		.DWL		(IWL			),
		.AWL		(AWL			),
		.INIT_FILE	(INIT_FILE		),
		.RAM_PERFORMANCE("NO")) 
	input_ram_unit (
		.CLK_A		(CLK			),
		.WrE_A		(in_RAM_wr		),
		.EN_A		(EN				),
		.RST_A		(RST			),
		.i_DATA_A	(i_A_DATA		),
		.i_ADDR_A	(in_RAM_a_addr	),
		.o_DATA_A	(in_RAM_a_value	),

		.CLK_B		(CLK			),
		.WrE_B		(in_RAM_wr		),
		.EN_B		(EN				),
		.RST_B		(RST			),
		.i_DATA_B	(i_B_DATA		),
		.i_ADDR_B	(in_RAM_b_addr	),
		.o_DATA_B	(in_RAM_b_value	)
	);


	butterfly_address_gen_unit #(
		.AWL		(AWL			),
		.synch_RESET(synch_RESET	),
		.RESET_LEVEL(RESET_LEVEL	))
	butterfly_address_gen(
		.CLK		(CLK			),
		.RST		(RST			),
		.EN			(addr_en		),
		.LAY_EN		(lay_en			),
		.A_ADDR		(r_a_addr		),
		.B_ADDR		(r_b_addr		)
	);


	w_address_gen_unit #(
		.AWL 		(WWL			),
		.synch_RESET(synch_RESET	),
		.RESET_LEVEL(RESET_LEVEL	))
	w_address_gen(
		.CLK		(CLK			),
		.RST		(RST			),
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


	complex_butterfly_selection #(
		.IWL1			(DWL								),
		.IWL2			(W_DWL								),
		.AWL			(DWL+1								),
		.OWL			(DWL								),
		.CONSTANT_SHIFT	(1'b1								),
		.BUT_CLK_CYCLE	(BUT_CLK_CYCLE						)) 
		butterfly(
		.clk 			(CLK 								),	        
		.rst         	(RST         						),
		.strb_in 		(but_strob 							),	  
		// B port 
		.din1_re 		(reg_b_value	[IWL-1:DWL]			),	
		.din1_im     	(reg_b_value	[DWL-1:0]   		),
		// W port
		.din2_re     	(reg_w_value	[W_DWL*2-1:W_DWL] 	),  
		.din2_im     	(reg_w_value	[W_DWL-1:0]   		),
		//  A port
		.din3_re		(reg_a_value	[IWL-1:DWL]			),  
		.din3_im		(reg_a_value	[DWL-1:0]			),
		// X port
		.dout1_re     	(x_value		[IWL-1:DWL]			),
		.dout1_im     	(x_value		[DWL-1:0]   		),
		// Y port
		.dout2_re     	(y_value		[IWL-1:DWL] 		),
		.dout2_im     	(y_value		[DWL-1:0]   		),
		
		.strb_out    	(strb_out    						)
	);

	(* DONT_TOUCH = "yes" *) dual_port_RAM_unit #(
		.DWL		(IWL			),
		.DEBUG_RES_FILE_NAME (DEBUG_RES_FILE_NAME),
		.AWL		(AWL			),
		.RAM_PERFORMANCE("NO")) 
	workt_ram_unit (

		.debug_write_res_to_file(wr_res),

		.CLK_A		(CLK			),
		.WrE_A		(wr				),
		.EN_A		(ram_en			),
		.RST_A		(RST			),
		.i_DATA_A	(x_value		),
		.i_ADDR_A	(a_addr			),
		.o_DATA_A	(RAM_a_value	),

		.CLK_B		(CLK			),
		.WrE_B		(wr				),
		.EN_B		(ram_en			),
		.RST_B		(RST			),
		.i_DATA_B	(y_value		),
		.i_ADDR_B	(b_addr			),
		.o_DATA_B	(RAM_b_value	)
	);

	control_unit_fft_iter_selection #(
		.LAYERS 	(AWL			),
		.BUTTERFLYES(BUT_NUM		),
		.LayWL 		(LayWL			),
		.ButtWL 	(AWL-1			),
		.BUT_CLK_CYCLE(BUT_CLK_CYCLE))	
	control_unit_selection(
		.CLK		(CLK			),
		.RST		(RST			),
		.EN			(EN				),
		.START		(START			),
		.BUT_STROB	(but_strob		),
		.LAY_EN		(lay_en			),
		.ADDR_EN	(addr_en		),
		.RAM_EN		(ram_en			),
		.Wr			(wr				),
		.FIRST		(first			)
	);


endmodule