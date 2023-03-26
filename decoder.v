/*


this implementation of the convolutional decoder is just one possible implementation 
and there may be other ways to implement the decoder based on the design requirements 
and constraints provided to me.

*/


module decoder(input ready, input clk, input rst, input [1:0] x_encoded, output reg out_bit);

// Define the trellis diagram of the convolutional encoder
parameter N = 2;
parameter K = 1;
parameter POLY1 = 3'b101;
parameter POLY2 = 3'b111;

// Define the state transition table
reg [2:0] next_state [0:3];
initial begin
    next_state[0] = 3'b000;
    next_state[1] = 3'b001;
    next_state[2] = 3'b010;
    next_state[3] = 3'b011;
end

// Define the output table
reg [1:0] output [0:3];
initial begin
    output[0] = 2'b00;
    output[1] = 2'b01;
    output[2] = 2'b11;
    output[3] = 2'b10;
end

// Define the distance table
reg [1:0] distance [0:3][0:3];
initial begin
    distance[0][0] = 2'b00;
    distance[0][1] = 2'b01;
    distance[0][2] = 2'b11;
    distance[0][3] = 2'b10;
    distance[1][0] = 2'b01;
    distance[1][1] = 2'b00;
    distance[1][2] = 2'b10;
    distance[1][3] = 2'b11;
    distance[2][0] = 2'b11;
    distance[2][1] = 2'b10;
    distance[2][2] = 2'b00;
    distance[2][3] = 2'b01;
    distance[3][0] = 2'b10;
    distance[3][1] = 2'b11;
    distance[3][2] = 2'b01;
    distance[3][3] = 2'b00;
end

// Define the state and path metric variables
reg [2:0] state;
reg [2:0] next_state_1, next_state_2, next_state_3, next_state_4;
reg [3:0] path_metric [0:3];

// Initialize the state and path metric variables
initial begin
    state = 3'b000;
    path_metric[0] = 4'd0;
    path_metric[1] = 4'd15;
    path_metric[2] = 4'd15;
    path_metric[3] = 4'd15;
end

// Decode the input bit stream
always @ (posedge clk, negedge rst) begin
    if (~rst) begin
        state <= 3'b000;
        path_metric[0] <= 4'd0;
        path_metric[1] <= 4'd15;
        path_metric[2] <= 4'd15;
        path_metric[3] <= 4'd15;
        out_bit <= 1'b0;
end


else if (ready) begin

// Compute the path metrics for each possible state transition
    next_state_1 = {state[1:0], 1'b0};
    next_state_2 = {state[1:0], 1'b1};
    next_state_3 = {state[2:0], 1'b0};
    next_state_4 = {state[2:0], 1'b1};

    path_metric[0] = path_metric[state] + distance[state][0];
    path_metric[1] = path_metric[state] + distance[state][1];
    path_metric[2] = path_metric[next_state_1] + distance[next_state_1][2] + path_metric[next_state_2] + distance[next_state_2][0];
    path_metric[3] = path_metric[next_state_1] + distance[next_state_1][3] + path_metric[next_state_2] + distance[next_state_2][1];
// Determine the state transition with the minimum path metric

    if (path_metric[2] <= path_metric[3]) begin
        state <= next_state_2;
        out_bit <= output[next_state_2][1];
    end
    else begin
        state <= next_state_3;
        out_bit <= output[next_state_3][0];
    end
    // Shift the encoded input bits into the decoder
    state <= {state[1:0], x_encoded[1]};
    end
    end

endmodule