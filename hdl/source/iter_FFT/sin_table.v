//-----------------------------------------------------------------\\
// Company: 
// Engineer: Petrovsky Dmitry
// 
// Create Date: 10.01.2023
// Design Name: Iterative Fast Fourier Transform (FFT)
// Module Name: sin_table_unit
// Project Name: ThesisProjectFFT
// Target Devices: Zeadboard
//
// Description: Асинхронная таблица со значением синула или косинуса
//
// Revision:
// Revision 1.00 - Code comented
// Additional Comments:
//
// Parameters:
// DWL				- Длинна слова
// AWL				- Размерность таблицы синуса или косинуса = 2^AWL
// A				- Амплитуда синуса\косинуса -1<А<1, отрицательные значения А сдвинут фазу на PI
// table_division	- определяет какую часть периода мы хоти получть:
//						table_division = 1. получим в таблице полный период		
//						table_division = 2. получим в таблице 1/2 периода начиная с 0		
//						table_division = 3. получим в таблице 1/3 периода начиная с 0				
// COS				- Значение косинуса(1) или синуса(0) получим в таблице
// 
// Ports:
// i_ADDR			- Входной адрес 
// o_DATA_			- Выходное значение таблицы
//
//-----------------------------------------------------------------\\

module sin_table_unit #(
	parameter DWL = 8,
	parameter AWL = 4,
	parameter real A = 1.0,
	parameter table_division = 1,
	parameter COS  =  0
)(
	input  wire	[AWL-1:0]	i_ADDR,
	output reg	[DWL-1:0]	o_DATA
);
    
	//------Функция формирования N-го отсчета синуса или косинуса------\\
	function real SIN_VALUE(input integer FS, F, N, cos, input real A);
		localparam real pi =  3.14159265;
		if (cos) begin 
			SIN_VALUE =  A * $cos(2 * pi * ($itor(F) / $itor(FS)) * N);
		end else begin
			SIN_VALUE =  A * $sin(2 * pi * ($itor(F) / $itor(FS)) * N);
		end
	endfunction

	localparam FS = 2**AWL *  table_division;
	localparam F = 1;
	localparam N = 2**AWL;

	reg [DWL-1:0] tabel [N-1:0];

	//--------------Формирования таблицы синуса или косинуса-----------\\
	integer i;
	real tmp_r;
	initial begin
		for(i = 0; i < N; i = i + 1)begin
			tmp_r = SIN_VALUE(FS, F, i, COS, A);
			if (tmp_r != 1.0) begin 
				tabel[i] = $rtoi($floor(tmp_r * $pow(2, DWL-1)));
			end else begin 
				tabel[i][DWL-1] = 1'b0;
				tabel[i][DWL-2:0] = {DWL-1{1'b1}};
			end 

		end
	end

	//------------------Выборка данных из таблицы таблицы--------------\\
    always @(i_ADDR) begin
		o_DATA = tabel[i_ADDR];
	end
endmodule 		
			
	