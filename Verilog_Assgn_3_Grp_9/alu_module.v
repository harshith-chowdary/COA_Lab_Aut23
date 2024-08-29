`timescale 1ps/1ps

// Command to run in Icarus verilog 
// 1. % iverilog -o alu alu_module.v
// 2. % vvp alu
// 3. % gtkwave alu.vcd &

module carry_look_ahead_4bit(a, b, cin, sum, cout);
    input [3:0] a,b;
    input cin;
    output [3:0] sum;
    output cout;

    wire [3:0] p,g,c;

    assign p=a^b;
    assign g=a&b;

    assign c[0]=cin;
    assign c[1]= g[0]|(p[0]&c[0]);
    assign c[2]= g[1] | (p[1]&g[0]) | p[1]&p[0]&c[0];
    assign c[3]= g[2] | (p[2]&g[1]) | p[2]&p[1]&g[0] | p[2]&p[1]&p[0]&c[0];
    assign cout= g[3] | (p[3]&g[2]) | p[3]&p[2]&g[1] | p[3]&p[2]&p[1]&g[0] | p[3]&p[2]&p[1]&p[0]&c[0];
    assign sum=p^c;
endmodule

module add(r1, r2, out);
    input [7:0] r1, r2;
    output [7:0] out;

    wire cin = 0;
    wire c1, c2;
    carry_look_ahead_4bit cla1 (.a(r1[3:0]), .b(r2[3:0]), .cin(cin), .sum(out[3:0]), .cout(c1));
    carry_look_ahead_4bit cla2 (.a(r1[7:4]), .b(r2[7:4]), .cin(c1), .sum(out[7:4]), .cout(c2));
endmodule

module sub(r1, r2, out);
    input [7:0] r1, r2;
    output [7:0] out;

    wire [7:0] t1, t2;

    wire [7:0] one = 1;

    NOT donot (r2, t1);
    add addpls (t1, one, t2);

    add addfinal (r1, t2, out);
endmodule

module init(r1, out);
    input [7:0] r1;
    output [7:0] out;

    assign out = r1;
endmodule

module lshift(r1, out);
    input [7:0] r1;
    output [7:0] out;

    assign out[0] = 0;
    assign out[1] = r1[0];
    assign out[2] = r1[1];
    assign out[3] = r1[2];
    assign out[4] = r1[3];
    assign out[5] = r1[4];
    assign out[6] = r1[5];
    assign out[7] = r1[6];
endmodule

module rshift(r1, out);
    input [7:0] r1;
    output [7:0] out;

    assign out[0] = r1[1];
    assign out[1] = r1[2];
    assign out[2] = r1[3];
    assign out[3] = r1[4];
    assign out[4] = r1[5];
    assign out[5] = r1[6];
    assign out[6] = r1[7];
    assign out[7] = 0;
endmodule

module AND(r1, r2, out);
    input [7:0] r1, r2;
    output [7:0] out;

    assign out[0] = r1[0]&r2[0];
    assign out[1] = r1[1]&r2[1];
    assign out[2] = r1[2]&r2[2];
    assign out[3] = r1[3]&r2[3];
    assign out[4] = r1[4]&r2[4];
    assign out[5] = r1[5]&r2[5];
    assign out[6] = r1[6]&r2[6];
    assign out[7] = r1[7]&r2[7];
endmodule

module NOT(r1, out);
    input [7:0] r1;
    output [7:0] out;

    assign out[0] = ~r1[0];
    assign out[1] = ~r1[1];
    assign out[2] = ~r1[2];
    assign out[3] = ~r1[3];
    assign out[4] = ~r1[4];
    assign out[5] = ~r1[5];
    assign out[6] = ~r1[6];
    assign out[7] = ~r1[7];

    // assign out = ~r1;
endmodule

module OR(r1, r2, out);
    input [7:0] r1, r2;
    output [7:0] out;

    assign out[0] = r1[0]|r2[0];
    assign out[1] = r1[1]|r2[1];
    assign out[2] = r1[2]|r2[2];
    assign out[3] = r1[3]|r2[3];
    assign out[4] = r1[4]|r2[4];
    assign out[5] = r1[5]|r2[5];
    assign out[6] = r1[6]|r2[6];
    assign out[7] = r1[7]|r2[7];
endmodule

module alu(r1, r2, op, out);
    input [7:0] r1, r2;
    output [7:0] out0, out1, out2, out3, out4, out5, out6, out7;
    input [2:0] op;

    output reg [7:0] out;

    add f0 (r1, r2, out0);
    sub f1 (r1, r2, out1);
    init f2 (r1, out2);
    lshift f3 (r1, out3);
    rshift f4 (r1, out4);
    AND f5 (r1, r2, out5);
    NOT f6 (r1, out6);
    OR f7 (r1, r2, out7);

    always @(*)
        begin
            case (op)
                0: out = out0;
                1: out = out1;
                2: out = out2;
                3: out = out3;
                4: out = out4;
                5: out = out5;
                6: out = out6;
                7: out = out7;
            endcase
        end

endmodule

// Test Bench to test our code ... (Please follow commented lines for what to do at each required step IN or MOVE)
module test_bench;
    reg [7:0] r1, r2;
    reg [2:0] op;
    reg clock;

    wire [7:0] out;

    alu test (r1, r2, op, out);

    initial
        begin
            clock = 1;
        end

    initial
        begin
            // To siulate in GTK Wave use command '% gtkwave gcd.vcd &'
            // $dumpfile("alu.vcd");
            // $dumpvars(0,test);

            $monitor($time, "   : r1 = %d, r2 = %d, op = %d, output = %d", r1, r2, op, out);

            r1 = 5; r2 = 20; op = 0;
            #5 r1 = 8'b10101010; op = 6;
            #5 r1 = 96; r2 = 69; op = 1;
            #5 r1 = 33; op = 2;
            #5 r1 = 255; op = 3;
            #5 op = 4;
            #5 r1 = 8; r2 = 7; op = 5;
            #5 op = 7;
            // #100 op = 5;
            
            #100 $finish;
        end
        always #1 clock = ~clock;
endmodule