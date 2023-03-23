
class Scoreboard;

mailbox drv2sb;
mailbox rcvr2sb;
Coverage cov = new();

function new(mailbox drv2sb,mailbox rcvr2sb);
  this.drv2sb = drv2sb;
  this.rcvr2sb = rcvr2sb;
endfunction


task run();
  Tranaction pkt_rcv,pkt_exp;
  forever
  begin
    rcvr2sb.get(pkt_rcv);
    drv2sb.get(pkt_exp);
    if(pkt_rcv.compare(pkt_exp)) 
    begin
       $display(" %0d : Scoreboardd :Packet Matched ",$time);
    end
    else
      error++;
  end
endtask 

endclass



