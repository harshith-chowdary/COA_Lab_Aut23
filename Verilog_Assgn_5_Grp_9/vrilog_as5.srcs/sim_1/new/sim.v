`timescale 1ps/1ps

module test_bench;
    reg [31:0] x;
    reg clock, enable;

    wire [31:0] y;

    Divby255 test (x, clock, enable, y);

    initial
        begin
            clock = 1;
        end

    initial
        begin
            // To siulate in GTK Wave use command '% gtkwave gcd.vcd &'
            // $dumpfile("booth.vcd");
            // $dumpvars(0,test);

            $monitor($time, "   : x = %d, y = %d", x, y);

            enable = 1;
            #50 x = 1020;
            #50 x = 80000;
            
            #1 $finish;
        end
        always #1 clock = ~clock;
endmodule