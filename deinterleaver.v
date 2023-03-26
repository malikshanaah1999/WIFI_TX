/*
the only difference between the Interleaver and the deInterleaver is in the order 
in which the data is read and written into the memory buffer. In the Interleaver,
 data is written row by row, and then read column by column, 
while in the deInterleaver, data is read column by column, and then written row by row.
*/


module deInterleaver(Input, Reset, Clock, Output);


input wire Input;
input wire Reset;
input wire Clock;
output reg Output;

parameter N_CBPS = 48;
parameter N_COLS = 16;
parameter N_ROWS = N_CBPS / 16;

reg [3:0] j_col_IN; // Which is the 4 bits in the symbol
reg [1:0] i_row_IN; // Which is the coordinates.
reg [0:15] MEM_IN [0:2];
reg [3:0] j_col_OUT;
reg [1:0] i_row_OUT;
reg [0:15] MEM_OUT [0:2];
reg [7:0] counter;

integer k;
always @(posedge Clock, posedge Reset)
begin
    if (Reset)
    begin    // Here is the initialization process for our matrix.(Buffer)
        j_col_IN <= 4'b0000;
        i_row_IN <= 2'b00;
        for(k = 0; k < N_ROWS; k = k + 1)               
            MEM_IN[k] <= 16'h0000;
        j_col_OUT <= 4'b0000;
        i_row_OUT <= 2'b00;
        for(k = 0; k < N_ROWS; k = k + 1)               
            MEM_OUT[k] <= 16'h0000;
        counter <= 8'h01;
    end
    else
    begin
        counter <= counter + 8'h01;
        if (counter == N_CBPS)
        begin
            for(k = 0; k < N_ROWS; k = k + 1)        
            begin
                MEM_OUT[k] <= MEM_IN[k];
            end
            j_col_IN <= 4'b0000;
            i_row_IN <= 2'b00;
            j_col_OUT <= 4'b0000;
            i_row_OUT <= 2'b00;
            counter <= 8'h01;
            Output <= MEM_OUT[i_row_OUT][j_col_OUT];
        end
        else
        begin
            j_col_OUT <= j_col_OUT + 4'b0001;
            if (j_col_OUT == 4'b1111)
                i_row_OUT <= i_row_OUT + 2'b01;

            MEM_IN[i_row_IN][j_col_IN] <= Input;
            j_col_IN <= j_col_IN + 4'b0001;
            if (j_col_IN == 4'b1111)
                i_row_IN <= i_row_IN + 2'b01;
        end
    end
end


endmodule