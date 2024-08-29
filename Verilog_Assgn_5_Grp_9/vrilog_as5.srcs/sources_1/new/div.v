`timescale 1ps/1ps

module adder(r1, r2, out);
    input [31:0] r1, r2;
    output [31:0] out;

    assign out = r1+r2;
endmodule

module shifter(r, b, out);
    input [31:0] r;
    input [4:0] b;
    output [31:0] out;

    assign out = r>>b;
endmodule

module Divby255(x, clk, enable, y);
    input [31:0] x;
    output reg [31:0] y;
    
    wire [31:0] yt;
    input clk, enable;

    reg [31:0] sum;
    reg [2:0] st, next;

    always @(x)
    begin
        sum = x+1;
        st = 0;
        next = 0;
    end

    wire [31:0] s1, s2, s3;

    shifter sh1 (x, 8, s1);
    shifter sh2 (x, 16, s2);
    shifter sh3 (x, 24, s3);

    shifter sh4 (sum, 8, yt);

    reg [31:0] a1, a2;
    wire [31:0] aout;
    adder add (a1, a2, aout);
 
    always @(posedge clk)
    begin
//        $monitor($time, "sum = %d, y = %d", sum, y);
        if(enable)
        begin
            case(st)
            0: 
            begin
                st = 1;
            end
            1:
            begin
                a1 = sum;
                a2 = s1;

                next = 2;
                st = 4;
            end
            2:
            begin
                a1 = sum;
                a2 = s2;
                
                next = 3;
                st = 4;
            end
            3:
            begin
                sum = aout;
                a1 = sum;
                a2 = s3;
                                
                st = 4;
                next = 4;
            end
            4:
            begin
                sum = aout;
                st = next;
                
                y = yt;
            end
            endcase
        end
    end

endmodule

// Alternate Approach (for hardware)
//module shift8(x, xt);
//    input [15:0] x;
//    output [15:0] xt;
//    reg [15:0] xt;
//    always @(*) xt = (x >> 8);
    
//endmodule

//module shift16(x, xt);
//    input [15:0] x;
//    output [15:0] xt;
//    reg [15:0] xt;
//    always @(*) xt = (x >> 16);
    
//endmodule

//module adder(x3, x, x1, x2);
//    input [15:0] x, x1, x2;
//    output [15:0] x3;
//    reg [15:0] x3;
//    always @ (*)x3 = x + x1 + x2;
    
//endmodule

//module Div255(x, y);
  
//  input [15:0] x;
//  output [15:0] y;
  
//  reg [15:0] y;
  
//  wire [15:0] x0, x1, x2, x3;

//    shift8 B0(x, x1);
//    shift16 B1(x, x2);
    

//    adder B2(x3, x, x1, x2);
        
//  always @(*) y = ((x3 + 1) >> 8);
//endmodule