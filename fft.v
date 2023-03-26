
/*

there are some similarities between the IFFT and FFT code .
 In fact, the FFT module in 802.11a is derived from the IFFT module 
by simply reversing the order of the twiddle factors 
used in the computation.

*/

module fft (
input wire clk,
input wire [47:0] in_real,
input wire [47:0] in_imag,
output reg [47:0] out_real,
output reg [47:0] out_imag
);

// Constants
parameter N = 48; // FFT size
localparam LOG2N = 5; // log2(N)

// Internal signals
wire [47:0] twiddle_real [N/2-1:0];
wire [47:0] twiddle_imag [N/2-1:0];
reg [47:0] buffer_real [N-1:0];
reg [47:0] buffer_imag [N-1:0];

// Generate twiddle factors
generate
for (i = 0; i < N/2; i = i + 1) begin
assign twiddle_real[i] = $signed($cos((2.0 * $pi * i) / N) * 246);
assign twiddle_imag[i] = $signed($sin((2.0 * $pi * i) / N) * 246);
end
endgenerate

// Rearrange input data
integer stage, group, pair, index, distance;
integer stride, block_size, num_blocks;
integer input_index1, input_index2;
integer output_index1, output_index2;

always @(posedge clk) begin
// Copy input data to the buffer
buffer_real[0] <= in_real;
buffer_imag[0] <= in_imag;
for (i = 1; i < N; i = i + 1) begin
buffer_real[i] <= buffer_real[i-1];
buffer_imag[i] <= buffer_imag[i-1];
end
end

distance = N/2;
for (stage = 1; stage <= LOG2N; stage = stage + 1) begin
    block_size = 2**stage;
    num_blocks = N / block_size;
    stride = distance * 2;
end
for (group = 0; group < num_blocks; group = group + 1) begin

  for (pair = 0; pair < block_size/2; pair = pair + 1) begin
      index = pair + group * block_size;
      input_index1 = index;
      input_index2 = index + block_size/2;
      output_index1 = index;
      output_index2 = index + distance;

   // Declared previously in IFFT block   
butterfly butterfly_inst (
.clk(clk),
.in1_real(buffer_real[input_index1]),
.in1_imag(buffer_imag[input_index1]),
.in2_real(buffer_real[input_index2] * twiddle_real[pair] + buffer_imag[input_index2] * twiddle_imag[pair]),
.in2_imag(buffer_imag[input_index2] * twiddle_real[pair] - buffer_real[input_index2] * twiddle_imag[pair]),
.out1_real(buffer_real[output_index1]),
.out1_imag(buffer_imag[output_index1]),
.out2_real(buffer_real[output_index2]),
.out2_imag(buffer_imag[output_index2])
);
  end
  distance = distance / 2;
end

// Copy output data from the buffer
out_real <= buffer_real[N-1];
out_imag <= buffer_imag[N-1];
endmodule