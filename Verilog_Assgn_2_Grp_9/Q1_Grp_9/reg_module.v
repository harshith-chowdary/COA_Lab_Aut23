`timescale 1ps/1ps

// Command to run in Icarus verilog 
// 1. % iverilog -o reg reg_module.v
// 2. % vvp reg
// 3. % gtkwave reg.vcd &

// A module to store 8 16-bit registers and execute LOAD and OUTPUT
module reg8(code,data,op,enable,clock,out);
    input [15:0] data;
    input [2:0] code;
    input [1:0] op;
    input enable,clock;

    always @(posedge clock)
        begin
        // $display($time," code = %d, data = %d, op = %d, enable = %d, out = %d",code,data,op,enable, out);
        $display("\n",$time," R0 = %d, R1 = %d, R2 = %d, R3 = %d, R4 = %d, R5 = %d, R6 = %d, R7 = %d\n",R0,R1,R2,R3,R4,R5,R6,R7);
        end

    output reg [15:0] out;
    reg [15:0] R0,R1,R2,R3,R4,R5,R6,R7;
    
    always @(posedge clock) begin
        if(op==0)
        begin
        case(code)
            3'b000: R0 <= data;
            3'b001: R1 <= data;
            3'b010: R2 <= data;
            3'b011: R3 <= data;
            3'b100: R4 <= data;
            3'b101: R5 <= data;
            3'b110: R6 <= data;
            3'b111: R7 <= data;
        endcase
        end
        #10
        if(enable)
        begin
        case(code)
            3'b000: out <= R0;
            3'b001: out <= R1;
            3'b010: out <= R2;
            3'b011: out <= R3;
            3'b100: out <= R4;
            3'b101: out <= R5;
            3'b110: out <= R6;
            3'b111: out <= R7;
        endcase
        end
        else out <= 16'bz;
    end
endmodule

// A Top-level Module to perform IN and MOVE Operations on Registers
module top_level_module(src, dst, op, enable, data, clock, out);
    input [2:0] src,dst;
    input enable,clock;
    input [15:0] data;
    input [1:0] op;

    // always @(src or dst or op or enable or data)
    //     $display ($time, " Top: src = %d, dst = %d, op = %d, enable = %d, data = %d",src,dst,op,enable,data);

    output [15:0] out;

    reg [15:0] tmp;
    reg [2:0] pcode;
    reg [15:0] pdata;
    reg [1:0] pop;
    reg penable,pclock;

    reg8 oper (pcode, pdata, pop, penable, pclock, out);
    
    always @(posedge clock or enable or data or src or dst or op) begin
        case(op)
            0: 
                begin
                pcode <= dst; 
                pdata <= data;
                pop <= 0;
                penable <= enable;
                pclock <= clock;
                end
            1:
              begin
                pcode <= src; 
                pdata <= data;
                pop <= 1;
                penable <= enable;
                pclock <= clock;

                tmp = out;
              end
            2:
              begin
                pcode <= dst; 
                pdata <= tmp;
                pop <= 0;
                penable <= enable;
                pclock <= clock;
              end
        endcase
    end
endmodule

// Test Bench to test our code ... (Please follow commented lines for what to do at each required step IN or MOVE)
module test_bench;
    reg [2:0] src, dst;
    reg [1:0] op;
    reg enable = 0,clock = 0;
    reg[15:0] data;
    wire [15:0] out;

    top_level_module test (src, dst, op, enable, data, clock, out);

    initial
        begin
            // To siulate in GTK Wave use command '% gtkwave gcd.vcd &'
            // $dumpfile("reg.vcd");
            // $dumpvars(0,test);

            $monitor($time, "   : src = %d, dst = %d, data = %d, op = %d, enable = %d, output = %d", src, dst, data, op, enable, out);
            
            // For each IN Operation : mention the destination and data along with operation = 0
            #100 dst = 3'b000; op = 2'b00; data = 77;

            // To toggle OUTPUT change enable
            #100 enable = 1;

            // For each IN Operation : mention the destination and data along with operation = 0
            #100 dst = 3'b111; op = 2'b00; data = 45;
            #100 dst = 3'b100; op = 2'b00; data = 30;

            // For each MOVE Operation : mention the source and the destination along with operation = 1 followed by a operation = 2
            #100 src = 3'b111; dst = 3'b010; op = 2'b01;
            #100 op = 2'b10;
            // Above change is made to restore a state value
            
            // To toggle OUTPUT change enable
            #100 enable = 0;
            #100 $finish;
        end
        always #10 clock = ~clock;
endmodule