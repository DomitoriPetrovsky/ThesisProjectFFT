module tb_speed_iter_fft(

	input wire CLK,
	input wire RST,
	input wire EN,
	input wire START,

	input wire [2:0] ADDR,
	input wire [15:0] DATA,

	input wire ram_wr,

	output wire block
);

	parameter INIT_FILE = "C:/Users/user1/Documents/MATLAB/function/data.txt";
	parameter AWL = 7;

	reg [31:0] i_A_DATA, i_B_DATA;

	reg [15:0] i_A_ADDR, i_B_ADDR;

	always @(posedge CLK) begin
		if (RST) begin
			i_A_DATA[31:16] <= 0;
		end else begin
			if (ADDR == 3'b000 ) begin
				i_A_DATA[31:16] <= DATA;
			end
		end
	end

	always @(posedge CLK) begin
		if (RST) begin
			i_A_DATA[15:0] <= 0;
		end else begin
			if (ADDR == 3'b001) begin
				i_A_DATA[15:0] <= DATA;
			end
		end
	end
	always @(posedge CLK) begin
		if (RST) begin
			i_B_DATA[31:16] <= 0;
		end else begin
			if (ADDR == 3'b010 ) begin
				i_B_DATA[31:16] <= DATA;
			end
		end
	end
	always @(posedge CLK) begin
		if (RST) begin
			i_B_DATA[15:0] <= 0;
		end else begin
			if (ADDR == 3'b011 ) begin
				i_B_DATA[15:0] <= DATA;
			end
		end
	end
	always @(posedge CLK) begin
		if (RST) begin
			i_A_ADDR[15:0] <= 0;
		end else begin
			if (ADDR == 3'b100 ) begin
				i_A_ADDR <= DATA;
			end
		end
	end
	always @(posedge CLK) begin
		if (RST) begin
			i_B_ADDR[15:0] <= 0;
		end else begin
			if (ADDR == 3'b101 ) begin
				i_B_ADDR <= DATA;
			end
		end
	end

	top_fft_iter #(
		.IWL(32),
		.AWL(AWL),
		.INIT_FILE (INIT_FILE)
		//.DEBUG_RES_FILE_NAME(DEBUG_RES_FILE_NAME)
	)fft(	
		//.wr_res(wr_res),

		.CLK			(CLK),
		.RST			(RST),
		.EN				(EN),
		.START			(START),
		.i_A_DATA		(i_A_DATA),
		.i_B_DATA		(i_B_DATA),
		.i_A_ADDR		(i_A_ADDR[AWL-1:0]),
		.i_B_ADDR		(i_B_ADDR[AWL-1:0]),
		.i_RAM_Wr		(ram_wr),
		.o_RAM_BLOCK	(block)
	);
    
endmodule 		
			
	