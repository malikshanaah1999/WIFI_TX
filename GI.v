// This file concludes the following processes:
//1- adding a Cyclic_Prefix.
//2- windowing.

module Cyclic_Prefix(
  input clk,
  input [47:0] in_real,
  input [47:0] in_imag,
  output [2111:0] out
);

  integer i;
  integer N = 48;
  integer CP_length = 16;

  // Internal signals
  reg signed [15:0] buffer_real [0:N-1];
  reg signed [15:0] buffer_imag [0:N-1];
  reg signed [15:0] time_domain [0:N-1];
  reg signed [15:0] GI [0:CP_length-1];

  always @ (posedge clk) begin
    // Convert complex output to time-domain signal
    for (i = 0; i < N; i = i + 1) begin
      time_domain[i] <= buffer_real[i];
    end

    // Generate guard interval by copying end of signal to beginning
    for (i = 0; i < N; i = i + 1) begin
        GI[i] <= time_domain[N-CP_length+i];
    end
    // Concatenate guard interval and time-domain signal to form output
    for (i = 0; i < CP_length; i = i + 1) begin
    out[i] <= GI[i];
    end

    for (i = 0; i < N; i = i + 1) begin
    out[i+CP_length] <= time_domain[i];
    end
end

endmodule
//////////////////////////////////////////////////////
//The purpose of windowing in OFDM is to reduce spectral leakage 
//and improve the signal-to-noise ratio (SNR) in the frequency domain.
module wind(
  input clk,
  input [2111:0] in,
  output [2047:0] out
);

  integer i;
  integer N = 2048;
  integer CP_length = 16;

  // Internal signals
  reg signed [15:0] time_domain [0:N-1];

  // Define window function (Hamming window)
  reg signed [15:0] window [0:N-1];
  initial begin
    for (i = 0; i < N; i = i + 1) begin
      window[i] = (32767 * (0.54 - 0.46 * $cos(2 * $pi * i / (N-1)))) >> 15;
    end
  end

  always @ (posedge clk) begin
    // Remove guard interval by shifting signal to the right
    for (i = 0; i < N-CP_length; i = i + 1) begin
      time_domain[i] <= in[i+CP_length];
    end

    // Apply window function to time-domain signal
    for (i = 0; i < N; i = i + 1) begin
      time_domain[i] <= (time_domain[i] * window[i]) >> 15;
    end

    // Output time-domain signal
    for (i = 0; i < N; i = i + 1) begin
      out[i] <= time_domain[i];
    end
  end

endmodule
