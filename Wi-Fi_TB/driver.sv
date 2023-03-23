

class Driver;

    virtual input_intf.IP input_intf_v;
    mailbox drv2sb;
    int num_of_pkt;

    function new(input input_intf.IP v_intf, mailbox mbx,int num_of_pkt);
        
        this.num_of_pkt = num_of_pkt;
        this.input_intf_v = v_intf;
        drv2sb = mbx;

    endfunction 

    task run();
        Packet pkt;

        repeat(num_of_pkt)begin

        pkt = new();

        if(pkt.randomize())begin
    
            drv2sb.put(pkt);

        end
        else begin
            $display (" %0d Driver : ** Randomization failed. **",$time);
            $finish;     
        end

    endtask // run
    
endclass