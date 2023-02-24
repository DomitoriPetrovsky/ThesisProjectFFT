module tb_speed_iter_fft(

	input wire CLK,
	input wire RST,
	input wire EN,

	input wire [2:0] ADDR,
	input wire [15:0] DATA,
	output reg [15:0] DATA1,

	input wire ram_wr,

	output wire block
);

	parameter BIT_REVERS_WRITE = 1;
	parameter DWL = 15;
	parameter AWL = 10;

	reg [15:0] i_DATA_R, i_DATA_I;
	
	reg [15:0] DATA_R, DATA_I;
	wire [15:0] o_DATA_R, o_DATA_I;
	
	wire valid;
	always @(posedge CLK) begin
		if (RST) begin
			DATA_R <= 0;
			DATA_I <= 0;
		end else begin
			if (valid) begin
				DATA_R <= o_DATA_R;
			    DATA_I <= o_DATA_I;
			end
		end
	end
	
    always @(posedge CLK) begin
        if(RST) begin
            DATA1 <= 0;
        end else begin 
            if(ADDR == 3'b010) begin 
                DATA1 <= DATA_R;
            end else begin
                if (ADDR == 3'b011) begin
                    DATA1 <= DATA_I;
                end 
            end
        end
    end


	always @(posedge CLK) begin
		if (RST) begin
			i_DATA_R <= 0;
			i_DATA_I <= 0;
		end else begin
			if (ADDR == 3'b000 ) begin
				i_DATA_R <= DATA;
			end else begin 
				if (ADDR == 3'b001 ) begin
					i_DATA_I <= DATA;
				end
			end
		end
	end

	top_fft_iter #(
		.DWL(DWL),
		.AWL(AWL),
		.BUT_CLK_CYCLE(2),
		.BIT_REVERS_WRITE(BIT_REVERS_WRITE))
	fft(	
		.CLK			(CLK),
		.RST			(RST),
		.EN				(EN),

		.i_DATA_R		(i_DATA_R),
		.i_DATA_I		(i_DATA_I),
		.i_WR_DATA		(ram_wr),
		
		.o_DATA_R(o_DATA_R),
		.o_DATA_I(o_DATA_I),
		.FULL			(block),
		.VALID(valid)
	);


endmodule 		
			
	