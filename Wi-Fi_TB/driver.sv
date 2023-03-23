

class Driver;

    virtual input_intf.IP input_intf_v;
    mailbox drv2sb;
    int num_of_pkt;

    function new(input input_intf.IP v_intf, mailbox mbx,int num_of_pkt);
        
        this.num_of_pkt = num_of_pkt;
        this.input_intf_v = v_intf;
        this.drv2sb = mbx;

    endfunction 

    task run();
        Tranaction tr;

        repeat(num_of_pkt)begin

        tr = new();

        if(tr.randomize())begin
    
            drv2sb.put(tr);

        end
        else begin
            $display (" %0d Driver : ** Randomization failed. **",$time);
            $finish;     
        end

    endtask // run
    
endclass