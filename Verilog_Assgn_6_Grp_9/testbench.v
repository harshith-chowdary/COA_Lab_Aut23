`timescale 1ns/1ps

module testbench;
    reg [1:0] opcode;
    reg [2:0] regcode;
    reg [3:0] memloc;
    reg [3:0] datain;
    reg clock;
    
    wire [3:0] out;
    
    reg2mem test (opcode, regcode, memloc, datain, clock, out);

    initial
        begin
            clock <= 0;
        end

    initial
        begin
            // To siulate in GTK Wave use command '% gtkwave gcd.vcd &'
            // $dumpfile("booth.vcd");
            // $dumpvars(0,test);

            $monitor($time, "   : op = %d, reg = %d, mem = %d, datain = %d, out = %d", opcode, regcode, memloc, datain, out);
            
            opcode = 0; datain = 3; memloc = 3;
            #30 opcode = 2; regcode = 0;
            #40 opcode = 1; memloc = 4;
            #40 opcode = 3;
            #40 opcode = 0; datain = 8; memloc = 4; 
            
            #50 $finish;
        end
        always #10 clock = ~clock;
endmodule