module mapper (input clk, input rst, input data_in, input rate_sel, output symbol_out);

// Define mapping tables for each modulation scheme
// Gray-coded mappings for BPSK, QPSK, 16QAM, 64QAM
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

// Define parameter for number of bits per symbol for each rate, 
//ranging from 6 - 54 Mbps.....
parameter [3:0] NBPSC[8] = '{2'b0001, 2'b0010, 2'b0100, 2'b0110, 2'b1000, 2'b1011, 2'b1111, 2'b1111};

// Define parameter for number of subcarriers per OFDM symbol
parameter NSD = 48;

// Define signal for grouping bits
reg  data_buf;
reg [3:0] bit_count;

// Define signal for mapping
reg symbol;

// Define signal for rate selection
reg [2:0] rate;

always @(posedge clk) begin

    if (rst) begin  //Initial Values...
    data_buf <= 0;
    bit_count <= 0;
    symbol <= 0;
    rate <= 0;

end

else begin
    // Grouping Process
    // Group interleaved coded bits into NBPSC-bit groups
    if (bit_count == 0) begin
    data_buf <= data_in;
    bit_count <= NBPSC[rate_sel];
end

else begin

    data_buf <= {data_buf[NBPSC[rate_sel]-1:0], data_in};
    bit_count <= bit_count - NBPSC[rate_sel];

end
    //Mapping process(Mapping the groups into complex numbers, Frequency domain...)
    // Map bits to complex symbols
    case (rate)
        0: symbol <= {16'h0000, BPSK_MAP[data_buf[0]]};
        1: symbol <= {16'h0000, QPSK_MAP[{data_buf[0], data_buf[1]}]};
        2: symbol <= {QAM16_MAP[{data_buf[0], data_buf[1]}], QAM16_MAP[{data_buf[2], data_buf[3]}]};
        3: symbol <= {QAM64_MAP[{data_buf[0], data_buf[1], data_buf[2]}], QAM64_MAP[{data_buf[3], data_buf[4], data_buf[5]}]};
        default: symbol <= 0;
    endcase
    
    // Update rate parameter
    rate <= rate_sel;
end
end

assign symbol_out = symbol;

endmodule

/////////////////////
// After the Mapping block:

/*
 dividing the complex number string into groups of 48 complex numbers 
 and mapping them into OFDM subcarriers according to the specifications you provided:
*/
module ofdm_mapping_next (input [2*48*GROUPS-1:0] complex_numbers, output [2*52*GROUPS-1:0] subcarriers);

  parameter GROUPS = 1; // I assumed that there is ONLY one OFDM Symbol.

  // loop over each group of 48 complex numbers
  genvar g;
  generate
    for (g = 0; g < GROUPS; g++) begin : group
      // loop over each complex number in the group
      genvar i;
      for (i = 0; i < 48; i++) begin : complex
        // calculate the subcarrier index
        if (i < 22) begin
          // subcarriers -26 to -22, -20 to -8, -6 to -1, 1 to 6, 8 to 20, and 22 to 26
          case (i)
            0 : subcarriers[2*(52*g - 26) + 1] = complex_numbers[2*(48*g + i)]; // center frequency subcarrier
            1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 25, 26 : subcarriers[2*(52*g + i - 27)] = complex_numbers[2*(48*g + i)]; // non-pilot subcarriers
            default : ; // skip subcarriers -21, -7, 7, and 21
          endcase
        end else if (i == 48) begin
          // subcarrier 0 omitted and filled with zero value, based on the specif.
        end else begin // i > 22
          // subcarriers -26 to -22, -20 to -8, -6 to -1, 1 to 6, 8 to 20, and 22 to 26
          case (i)
            27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46 : subcarriers[2*(52*g + i - 23)] = complex_numbers[2*(48*g + i)]; // non-pilot subcarriers
            47 : subcarriers[2*(52*g + 26) + 1] = complex_numbers[2*(48*g + i)]; // center frequency subcarrier
            default : ; // skip subcarriers -21, -7, 7, and 21
          endcase
        end
      end
      // insert pilot subcarriers
      subcarriers[2*(52*g - 21) + 1] = subcarriers[2*(52*g - 7) + 1] = subcarriers[2*(52*g + 7) + 1] = subcarriers[2*(52*g + 21) + 1] = 0;
    end
  endgenerate

endmodule


