module sin_table_unit #(
	parameter DWL = 8,
	parameter DFL = 7,
	parameter AWL = 4,
	parameter real A = 1.0,
	parameter table_division = 1,
	parameter COS  =  0
)(
	input  wire	[AWL-1:0]	i_ADDR,
	output reg	[DWL-1:0]	o_DATA
);
    
	function real SIN_VALUE(input integer FS, F, N, cos, input real A);
		localparam real pi =  3.14159265;
		if (cos) begin 
			SIN_VALUE =  A * $cos(2 * pi * ($itor(F) / $itor(FS)) * N);
		end else begin
			SIN_VALUE =  A * $sin(2 * pi * ($itor(F) / $itor(FS)) * N);
		end
	endfunction

	localparam FS = $pow(2, AWL) *  table_division;
	localparam F = 1;
	localparam N = 2**AWL;//$pow(2, AWL);

	reg [DWL-1:0] tabel [N-1:0];

	integer i;
	real tmp_r;
	initial begin
		for(i = 0; i < N; i = i + 1)begin
			tmp_r = SIN_VALUE(FS, F, i, COS, A);
			if (tmp_r != 1.0) begin 
				tabel[i] = $rtoi($floor(tmp_r * $pow(2, DFL)));
			end else begin 
				//tabel[i] = {(DWL-DFL){0}, DFL{1}};
				tabel[i][DWL-1:DFL] = 0;
				tabel[i][DFL-1:0] = {DFL{1'b1}};
			end 

		end
	end


    always @(i_ADDR) begin
		o_DATA <= tabel[i_ADDR];
	end	

endmodule 		
			
	