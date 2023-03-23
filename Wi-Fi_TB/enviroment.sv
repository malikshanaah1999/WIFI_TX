
class Environment ;

  virtual input_interface.IP  input_intf;
  virtual output_interface.OP output_intf;
  
  Driver drvr;
  Receiver rcvr;
  Scoreboard sb;
  mailbox drvr2sb ;
  mailbox rcvr2sb ;

  parameter NUM_OF_PKT =100;

function new(
             virtual input_interface.IP  input_intf_new,
             virtual output_interface.OP output_intf_new);

  this.input_intf    = input_intf_new  ;
  this.output_intf   = output_intf_new ;

endfunction 

function void build();
   
   drvr2sb = new();
   rcvr2sb = new();
   sb = new(drvr2sb,rcvr2sb);
   drvr = new(input_intf,drvr2sb,NUM_OF_PKT);
   rcvr = new(output_interface , rcvr2sb);
   
endfunction 

// task reset();
  
//   input_intf.cb.cs1_l <= 1;
//   input_intf.cb.CRC_16 <= 0;
//   input_intf.cb.SYN_GEN_LD <= 0;
//   input_intf.cb.TX_LOAD <= 0;
//   input_intf.cb.TX_DATA <= 0;
//   input_intf.cb.TX_LAST_BYTE <= 0;
//   input_intf.cb.RX_LOAD <= 0;
  
//   // Reset the DUT
//   input_intf.reset       <= 0;
//   repeat (4) @ (posedge input_intf.clock);
//   input_intf.reset       <= 1;
  
// endtask 

task start();
  $display(" %0d : Environemnt : start of start() method",$time);
  fork
    drvr.run();
    rcvr.run();
    sb.start();
  join_any
  $display(" %0d : Environemnt : end of start() method",$time);
endtask 

  task run();
   $display(" %0d : Environemnt : start of run() method",$time);
   build();
   reset();
   cfg_dut();
   start();
   report();
   $display(" %0d : Environemnt : end of run() method",$time);
endtask 

task report();
   $display("\n\n*************************************************");
  if(error == 0)
       $display("********            TEST PASSED         *********");
   else
       $display("********    TEST Failed with %0d errors *********",error);
   
   $display("*************************************************\n\n");
endtask

endclass


