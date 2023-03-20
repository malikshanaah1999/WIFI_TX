module preamble_gen (
  input clk,
        enable,
        reset,
  output preamble
);

  reg [15:0] shift_reg;
  reg data_out;

  assign preamble = data_out;

  initial begin
    shift_reg <= 16'haaaa; // initialize shift register which represent the preamble static value
  end

  always @(posedge clk , negedge reset) begin
    if(!reset)begin
        shift_reg <= 0;
    end else if(enable) begin // when the block is enabled it start shifting else it will hold the static value
        data_out <= {shift_reg[15:0],0}; // shift left the preamble value in serial way
    end else
        shift_reg <= 16'haaaa;
    
  end

 

endmodule
