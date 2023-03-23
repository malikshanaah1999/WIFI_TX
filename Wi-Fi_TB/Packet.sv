
class Packet;

    rand logic  TX_DATA;
  

    virtual function void display();
        $display("Data_TX = %h",TX_DATA );
    endfunction

    constraint ones_more{ TX_DATA dist{1 :=50 , 0 :=20};}; 

    virtual function bit compare(packet pkt);
   
    if(pkt == null)
    begin
        $display(" ** ERROR ** : pkt : received a null object ");
        
    end
    else
      begin
         if(pkt.TX_DATA !== this.TX_DATA)
         begin
            $display(" ** ERROR ** Data field did not match");
            
         end
      end
    endfunction


endclass