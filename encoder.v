//We work with 1/2 Code rate. 

module encoder(input ready, input clk, input rst, input in_bit, output [1:0] x_encoded);

reg [6:0] state;

if (ready) begin
    //Odd bit
    assign x_encoded[1] = in_bit ^ state[6] ^ state[5] ^ state[3] ^ state[1];
    //Even bit
    assign x_encoded[0] = in_bit ^ state[1] ^ state[4] ^ state[3] ^ state[2];
end
always @ (posedge clk, negedge rst) begin
	if(~rst) begin
		state <= 7'd0;
	end
	else begin
			state[5:0] <= state[6:1];
			state[0] <= in_bit;
		end
	end
endmodule