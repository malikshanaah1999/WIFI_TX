module demapper (input clk, input rst, input symbol_in, input rate_sel, output reg [47:0] data_out);


//Here is the Gray-coded demappings for BPSK, QPSK, 16QAM, and 64QAM
//I provided in the TX part.....

// And they are the same...
parameter [1:0] BPSK_MAP[2] = '{2'b00, 2'b01, 2'b11, 2'b10};
parameter [3:0] QPSK_MAP[4] = '{4'b00, 4'b01, 4'b11, 4'b10};
parameter [5:0] QAM16_MAP[16] = '{6'h08, 6'h0c, 6'h04, 6'h00, 6'h09, 6'h0d, 6'h05, 6'h01,
                                   6'h0b, 6'h0f, 6'h07, 6'h03, 6'h0a, 6'h0e, 6'h06, 6'h02};
parameter [6:0] QAM64_MAP[64] = '{7'h28, 7'h38, 7'h18, 7'h08, 7'h2c, 7'h3c, 7'h1c, 7'h0c,
                                   7'h24, 7'h34, 7'h14, 7'h04, 7'h20, 7'h30, 7'h10, 7'h00,
                                   7'h2a, 7'h3a, 7'h1a, 7'h0a, 7'h2e, 7'h3e, 7'h1e, 7'h0e,
                                   7'h26, 7'h36, 7'h16, 7'h06, 7'h22, 7'h32, 7'h12, 7'h02,
                                   7'h2b, 7'h3b, 7'h1b, 7'h0b, 7'h2f, 7'h3f, 7'h1f, 7'h0f,
                                   7'h27, 7'h37, 7'h17, 7'h07, 7'h23, 7'h33, 7'h13, 7'h03,
                                   7'h29, 7'h39, 7'h19, 7'h09, 7'h2d, 7'h3d, 7'h1d, 7'h0d,
                                   7'h25, 7'h35, 7'h15, 7'h05, 7'h21, 7'h31, 7'h11, 7'h01};



// Define parameter for number of bits per symbol for each rate
parameter [3:0] NBPSC[8] = '{2'b0001, 2'b0010, 2'b0100, 2'b0110, 2'b1000, 2'b1011, 2'b1111, 2'b1111};

// Define parameter for number of subcarriers per OFDM symbol
parameter NSD = 48;

// Define signal for demapping
reg [5:0] symbol_real;
reg [5:0] symbol_imag;

// Define signal for rate selection
reg [2:0] rate;

always @(posedge clk) begin
    if (rst) begin  //Initial Values...
    symbol_real <= 0;
    symbol_imag <= 0;
    rate <= 0;
    data_out <= 0;
end

else begin
    // Demapping process
    // Demap complex symbols to bits
    symbol_real <= symbol_in[5:0];
    symbol_imag <= symbol_in[11:6];
    case (rate)
        0: data_out <= {data_out[NBPSC[rate_sel]-1:0], BPSK_DEMAP[symbol_imag]};
        1: data_out <= {data_out[NBPSC[rate_sel]-1:0], QPSK_DEMAP[{symbol_real, symbol_imag}]};
        2: data_out <= {data_out[NBPSC[rate_sel]-1:0], QAM16_DEMAP[{symbol_real, symbol_imag}]};
        3: data_out <= {data_out[NBPSC[rate_sel]-1:0], QAM64_DEMAP[{symbol_real, symbol_imag}]};
        default: data_out <= 0;
    endcase
    
    // Update rate parameter
    rate <= rate_sel;
end
end

endmodule