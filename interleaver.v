// Before going to the modulation mapping......

module Interleaver(Input, Reset, Clock, Output);


//We need to make 2 permutations:
//i = (NCBPS/16) (k mod 16) + floor(k/16)  for k = 0, 1, …, NCBPS–1
//j = s × floor(i/s) + (i + NCBPS – floor(16 × i/NCBPS)) mod s   for i = 0,1,… NCBPS – 1
// where: s = max(NBPSC/2,1)

    input wire Input;
    input wire Reset;
    input wire Clock;
    output reg Output;

    parameter N_CBPS = 48;
    parameter N_COLS = 16;
    parameter N_ROWS = N_CBPS / 16;

    reg [3:0] j_col_IN; // Which is the 4 bits inthe symbol
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
                MEM_OUT[i_row_IN][j_col_IN] <= Input;
            end
            else
            begin
                
                MEM_IN[i_row_IN][j_col_IN] <= Input;
                j_col_IN <= j_col_IN + 4'b0001;
                if (j_col_IN == 4'b1111)
                    i_row_IN <= i_row_IN + 2'b01;
                
                i_row_OUT <= i_row_OUT + 2'b01;
                if (i_row_OUT + 2'b01 == N_ROWS)
                begin
                    j_col_OUT <= j_col_OUT + 4'b0001;
                    i_row_OUT <= 2'b00;
                end 
            end
        end
    end
    always @(posedge Clock, posedge Reset)
    begin
        if (Reset)
            Output <= 1'b0;
        else
            Output <= MEM_OUT[i_row_OUT][j_col_OUT];
    end
endmodule