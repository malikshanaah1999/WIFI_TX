module top_tb();

  bit clock;

  initial
  forever #10 clock = ~clock;

  intf i_intf(clock);

  WIFI_TX tx (
    .clock(clock),
    .reset(i_intf.dut.reset),
    .data_in(i_intf.dut.data_in),
    .data_out(i_intf.dut.data_out)
  );
  
endmodule

