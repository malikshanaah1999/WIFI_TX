module top_tb();

  bit clock;

  initial
  forever #10 clock = ~clock;

  in_intf i_intf(clock);
  out_intf o_intf(clock); 

  
 //TODO inst the blocks
  
endmodule