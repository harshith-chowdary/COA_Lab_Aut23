`timescale 1ps/1ps

// Command to run in Icarus verilog 
// 1. % iverilog -o gcd gcd_states.v gcdsim_test_bench.v
// 2. % vvp gcd
// 3. % gtkwave gcd.vcd &

module gcd(a, b, clock, c, d);
    input [7:0] a,b;
    input clock;
    output reg [7:0] c, d;
    reg [1:0] state;
    
    parameter LT=0, GT=1, COM=2;

    always #10 @(a or b)
      begin
       c<=a;
       d<=b;
      end
    
    always @(posedge clock)
        case (state)
            LT: state<=COM;
            GT: state<=COM;
            COM: 
                begin
                    if(c>d)
                        state<=GT;
                    else if(c<d) 
                        state<=LT;
                end
            default: state<=COM;
        endcase
        
    always @(state)
        case (state)
            LT: 
               begin
                d = d-c;
               end
            GT: 
                begin
                c = c-d;
               end
        endcase
endmodule

// 
module testgcd;

    reg [7:0] a,b;
    reg clock = 0;
    wire [7:0] c,d;
    gcd test (a, b, clock, c, d);

    // delay time in ps for timescale 1p/sps >= 10250

    initial
        begin
            // To siulate in GTK Wave use command '% gtkwave gcd.vcd &'
            // $dumpfile("gcd.vcd");
            // $dumpvars(0,test);

            $monitor ($time,"   : a_in = %d  b_in = %d => a_cur = %d  b_cur = %d ==> gcd = %d ",a,b,c,d,d);
            
            #100 a = 10; b = 5;
            #10500 a = 3; b = 4;
            #10500 a = 17; b = 14;
            #10500 a = 10; b = 15;
            #10500 a = 11; b = 19;
            #10500 a = 255; b = 1;
            #10500 a = 255; b = 254;
            #10500 a = 5; b = 255;
            #10500 a = 119; b = 49;

            #10500 $finish;
        end
        always #10 clock = ~clock;
endmodule