
class Receiver;

virtual output_interface.OP output_intf;
mailbox rcvr2sb;

function new( output_interface.OP  output_intf_v,mailbox rcvr2sb);
   this.output_intf    = output_intf_v  ;
   this.rcvr2sb = rcvr2sb;
endfunction   

task run();

Tranaction pkt;
  forever
  begin

    @(posedge output_intf.clock);
    pkt = new();
    //pkt.display();
    rcvr2sb.put(pkt); 
    
  end
endtask 

endclass


