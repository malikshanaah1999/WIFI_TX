/* 
And before going on the the encoder which is the first sub-block: 
We need to add redundancy to the transmitted signal to improve its reliability and resistance to noise and interference.
*/
// And this is where Scrambler comes in.
/*
the Scrambler takes the data bits that are to be transmitted and scrambles them using a 
pseudorandom sequence generator before procceding further.
*/
//The Scrambler adds 127-bit sequence to the actual data.
//And here is the design............
//The Scrambler is used to randomize the data before it is transmitted
module Scrambler(input clk, input rst,  input bit_in, output scramb_bit);

	reg [6:0] state;
	wire feedback;
	assign feedback = (state_out[6] ^ state_out[3]);
	assign scramb_bit =  (bit_in ^ feedback);

	always @(posedge clk)
	begin
		if (rst == 1'b1) 
			state_out <=  7'b1010000;  // The initial state.
		else
			state_out <= {state[6], state[5], state[4],state[3], state[2], state[1],feedback};
	end
endmodule