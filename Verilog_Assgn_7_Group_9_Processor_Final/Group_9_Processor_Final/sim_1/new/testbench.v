module testbench();
    reg clk,continue;
    reg signed [31:0] ledout;
    topmodule test (clk,continue,ledout );

    initial begin
            clk = 1'b0;
            forever begin
                #5 clk = ~clk;
            end
        end
    
    initial begin
        #0 en = 1;

        #55000 $finish;
    end
endmodule
