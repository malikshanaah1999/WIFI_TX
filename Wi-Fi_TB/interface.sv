interface intf(input bit clock);
    logic data_in;
    logic resest;
    logic data_out;

    clocking  cb1 @(posedge clock);
        default input #1 output #1; 
        output data_in;
        input data_out;
    endclocking 

    clocking  cb2 @(posedge clock);
        default input #1 output #1; 
        output data_in;
        input data_out;
    endclocking 

    modport dut  (clocking cb1, input clock, input reset);
    modport tb (clocking cb2, input clock, output reset);
endinterface
