

class Coverage;
  
packet pkt; 

covergroup data_coverage;

    Data_to_send : coverpoint pkt.TX_DATA;
  
endgroup

function new();
  data_coverage = new();
endfunction 


endclass


