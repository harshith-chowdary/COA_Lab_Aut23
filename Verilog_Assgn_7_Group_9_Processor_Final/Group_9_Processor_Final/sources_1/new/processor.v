`timescale 1ps/1ps

// Command to run in Icarus verilog 
// 1. % iverilog -o dpcum riscvprocessor.v
// 2. % vvp dpcum
// 3. % gtkwave dpcum.vcd &

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
    input signed [31:0] r1, r2;
    output signed [31:0] out;

    wire cin = 0;
    wire c1, c2, c3, c4, c5, c6, c7, c8;
    carry_look_ahead_4bit cla1 (.a(r1[3:0]), .b(r2[3:0]), .cin(cin), .sum(out[3:0]), .cout(c1));
    carry_look_ahead_4bit cla2 (.a(r1[7:4]), .b(r2[7:4]), .cin(c1), .sum(out[7:4]), .cout(c2));
    carry_look_ahead_4bit cla3 (.a(r1[11:8]), .b(r2[11:8]), .cin(c2), .sum(out[11:8]), .cout(c3));
    carry_look_ahead_4bit cla4 (.a(r1[15:12]), .b(r2[15:12]), .cin(c3), .sum(out[15:12]), .cout(c4));
    carry_look_ahead_4bit cla5 (.a(r1[19:16]), .b(r2[19:16]), .cin(c4), .sum(out[19:16]), .cout(c5));
    carry_look_ahead_4bit cla6 (.a(r1[23:20]), .b(r2[23:20]), .cin(c5), .sum(out[23:20]), .cout(c6));
    carry_look_ahead_4bit cla7 (.a(r1[27:24]), .b(r2[27:24]), .cin(c6), .sum(out[27:24]), .cout(c7));
    carry_look_ahead_4bit cla8 (.a(r1[31:28]), .b(r2[31:28]), .cin(c7), .sum(out[31:28]), .cout(c8));
endmodule

module sub(r1, r2, out);
    input signed [31:0] r1, r2;
    output signed [31:0] out;

    wire signed [31:0] t1, t2;

    wire signed [31:0] one = 1;

    NOT donot (r2, t1);
    add addpls (t1, one, t2);

    add addfinal (r1, t2, out);
endmodule

module SLA(r1, r2, out);
    input signed [31:0] r1;
    input [31:0] r2;
    output signed [31:0] out;

    assign out = r1 << r2;
endmodule

module SRA(r1, r2, out);
    input signed [31:0] r1;
    input [31:0] r2;
    output signed [31:0] out;

    assign out = r1 >>> r2;
endmodule

module SRL(r1, r2, out);
    input signed [31:0] r1;
    input [31:0] r2;
    output signed [31:0] out;

    assign out = r1 >> r2;
endmodule

module AND(r1, r2, out);
    input signed [31:0] r1, r2;
    output signed [31:0] out;

    assign out = r1 & r2;
endmodule

module NOT(r1, out);
    input signed [31:0] r1;
    output signed [31:0] out;

    assign out = ~r1;
endmodule

module OR(r1, r2, out);
    input signed [31:0] r1, r2;
    output signed [31:0] out;

    assign out = r1 | r2;
endmodule

module XOR(r1, r2, out);
    input signed [31:0] r1, r2;
    output signed [31:0] out;

    assign out = r1 ^ r2;
endmodule

module alu(r1, r2, imm, op, clk, out, enable);
    input clk, enable;
    input signed [31:0] r1, r2;
    input signed [31:0] imm;

    wire signed [31:0] out0, out1, out2, out3, out4, out5, out6, out7, out8, out9;

    input [5:0] op;

    output reg signed [31:0] out;

    // rs <- r1 and rt <- r2
    add f0 (r1, r2, out0);
    sub f1 (r1, r2, out1);
    SRA f2 (r1, r2, out2); 
    SLA f3 (r1, r2, out3);
    SRL f4 (r1, r2, out4);
    AND f5 (r1, r2, out5);
    OR f6 (r1, r2, out6);
    XOR f7 (r1, r2, out7);

    NOT f8 (r1, out8);

    add f9 (r1, 0, out9);

    always @(posedge clk)
        begin
            if(enable)
            begin
                case (op)
                    0: out = out0;
                    1: out = out1;
                    2: out = out5;
                    3: out = out6;
                    4: out = out7;
                    5: out = out3;
                    6: out = out2;
                    7: out = out4;
                    8: out = out8;
                    9: out = out9;
                    10: out = imm;
                endcase
            end
            $display("r1 = %d, r2 = %d, aluout = %d,op =%d\n", r1, r2, out,op);
        end

endmodule

module regbank(in1, in2, ren1, ren2, wen, w1, data, clk, out1, out2, ledout);
    input [4:0] in1, in2, w1;
    input clk, ren1, ren2, wen;
    input signed [31:0] data;
    output reg signed [31:0] out1, out2, ledout;
    
    // rs <- in1, rt <- in2, rd <- w1
    // RS <- out1, RT <- out2, RD <- data
    reg signed [31:0] R [15:0];
    initial
        R[0] = 0;

    always @(posedge clk)
        begin
            if(wen)
                begin
                    R[w1]<=data;
                end
            if(ren1)
                begin
                    out1<=R[in1];
                end
            if(ren2)
                begin
                    out2<=R[in2];
                end
                
           
             ledout <= R[2];
        end

    initial 
        begin
            R[1] = 32'd0;
            R[2] = 32'd2;
            R[3] = 32'd3;
            R[4] = 32'bx;
            R[5] = 32'bx;
            R[6] = 32'bx;
            R[7] = 32'bx;
            R[8] = 32'bx;
            R[9] = 32'bx;
            R[10] = 32'bx;
            R[11] = 32'bx;
            R[12] = 32'bx;
            R[13] = 32'bx;
            R[14] = 32'bx;
            R[15] = 32'bx;
        end

    always @(posedge clk)
        begin
            $display("R[0] = %0d\tR[1] = %0d\tR[2] = %0d\tR[3] = %0d\tR[4] = %0d\tR[5] = %0d\n", R[0], R[1], R[2], R[3], R[4], R[5]);
            $monitor("in1 = %d, ren1 = %d, in2 = %d, ren2 = %d, out1 = %d, out2 = %d\n", in1, ren1, in2, ren2, out1, out2);
        end
    
endmodule

module incr (clk, in, out);
    input clk;
    input signed [31:0] in;
    output signed [31:0] out;

    assign out = in + 4;

    always @(*)
        $display("incr: in = %d, out = %d\n", in, out);
endmodule

module decr (clk, in, out);
    input clk;
    input signed [31:0] in;
    output signed [31:0] out;

    assign out = in - 4;
endmodule

module MUX4to1 (in1, in2, in3, in4, sel, out);
    input signed [31:0] in1, in2, in3, in4;
    input [1:0] sel;
    output signed [31:0] out;

    assign out = (sel == 2'b00) ? in1 : (sel == 2'b01) ? in2 : (sel == 2'b10) ? in3 : in4;
endmodule

module MUX2to1 (in1, in2, sel, out);
    input signed [31:0] in1, in2;
    input sel;
    output signed [31:0] out;

    assign out = (sel == 1'b0) ? in1 : in2;
endmodule

module allregio(in, re, we, clk, out);
    input re, we, clk;
    input [31:0] in;
    output [31:0] out;

    reg [31:0] data;
    initial
        data = 32'd0;

    always @(posedge clk)
        begin
            if(we)
                begin
                    data<=in;
                end
        end

    assign out = (re==1) ? data : 32'bz;

    always @(*)
        $display("in = %d, , re = %d, we = %d, out = %d", in, re, we, out);
endmodule

module stackpointer(immdata, memdata, out, op, clk);
    input [31:0] immdata, memdata;
    input [2:0] op;
    input clk;

    reg [31:0] SP;

    initial
        SP = 32'd1020;

    always @(posedge clk)
        begin
            case(op)
                0:
                    SP <= SP;
                1: 
                    SP <= SP + 4;
                2: 
                    SP <= SP - 4;
                3:
                    SP <= SP - immdata;
                4:
                    SP <= memdata;
            endcase
        end

    output [31:0] out;

    assign out = SP;

    always @(*) begin
        $display("SP = %d\n", SP);
    end

endmodule

module signextendimm(imm, out);
    input signed [15:0] imm;
    output signed [31:0] out;

    // assign out = imm[15] ? {16'b1111111111111111, imm} : {16'b0000000000000000, imm};
    assign out = {{16{imm[15]}}, imm};
endmodule

module signextendimm1(imm1, out);
    input signed [25:0] imm1;
    output signed [31:0] out;

    // assign out = imm1[25] ? {6'b111111, imm1} : {6'b000000,imm1};
    assign out = {{6{imm1[25]}}, imm1};
endmodule

module conditionalbranch(in, cond, flag);
    input [31:0] in;
    input [2:0] cond;

    output flag;

    assign flag = (cond == 3'b000) ? (1'b0) : (cond == 3'b001) ? (in[31]) ? (1'b1) : (1'b0) : (cond == 3'b010) ? (in[31] == 0) ? (1'b1) : (1'b0) : (cond == 3'b011) ? (in == 0 ) ? (1'b1) : (1'b0) : 1'b1;
endmodule

module datamemory(src, rw, data, out);
    // n-bit address with n = log2(Data Memory Size) and max value 32
    input signed [31:0] src;
    input rw;

    input signed [31:0] data;
    output signed [31:0] out;

    // 1024B = 1KB Data Memory
    reg [7:0] mem [1023:0];

    reg signed [31:0] a, b;

    // Uncomment this for TESTING ALL INSTRUCTIONS and comment below INITIAL BLOCK
    // initial 
    // begin
    //     mem[4] = 8'd0;
    //     mem[5] = 8'd0;
    //     mem[6] = 8'd0;
    //     mem[7] = 8'd16;
    // end

    initial
    begin

        // Enter a and b here for computing GCD(a, b)/ Booths a*b <= Answer in R2 !!!
        a = -96;
        b = 84;

        mem[0] = a[31:24];
        mem[1] = a[23:16];
        mem[2] = a[15:8];
        mem[3] = a[7:0];

        mem[4] = b[31:24];
        mem[5] = b[23:16];
        mem[6] = b[15:8];
        mem[7] = b[7:0];
    end

    always @(src or data or rw)
    begin
        if(rw)
            begin
                mem[src] <= data[31:24];
                mem[src+1] <= data[23:16];
                mem[src+2] <= data[15:8];
                mem[src+3] <= data[7:0];
            end
    end

    assign out = {{mem[src], mem[src+1]}, {mem[src+2], mem[src+3]}};

    always @(*)
        begin
            $display("mem[8] = %d\tmem[9] = %d\tmem[10] = %d\t mem[11] = %d\n", mem[8], mem[9], mem[10], mem[11]);
            $display("mem[12] = %d\tmem[13] = %d\tmem[14] = %d\t mem[15] = %d\n", mem[12], mem[13], mem[14], mem[15]);
            $display("mem[16] = %d\tmem[17] = %d\tmem[18] = %d\t mem[19] = %d\n", mem[16], mem[17], mem[18], mem[19]);
        end
endmodule

/* // Uncomment below module to TEST ALL INSTRUCTIONS and RUN THIS .v file ALONE
module instructionmemory (src, out);
    input [31:0] src;
    output [31:0] out;

    reg [7:0] mem [0:511];
    initial begin
        // 000000 00,010 00011, 00001 000,00 000000 <= ADD R1, R2, R3
        mem[0] = 8'b00000000;
        mem[1] = 8'b01000011;
        mem[2] = 8'b00001000;
        mem[3] = 8'b00000000;

        // 000001 00,001 00001, 00000 000,00 110000 <= ADDI R1, #48
        mem[4] = 8'b00000100;
        mem[5] = 8'b00100001;
        mem[6] = 8'b00000000;
        mem[7] = 8'b00110000;

        // 001001 00,000 00101, 00000 000,00 000100 <= LD R5, 4(R0) (here rs is R0, rt is R5)
        mem[8] = 8'b00100100;
        mem[9] = 8'b00000101;
        mem[10] = 8'b00000000;
        mem[11] = 8'b00000100;

        // 001010 00,101 00010, 00000 000,00 000110 <= ST R5, 6(R2) (here rs is R5, rt is R2)
        mem[12] = 8'b00101000;
        mem[13] = 8'b10100010;
        mem[14] = 8'b00000000;
        mem[15] = 8'b00000110;

        // Uncomment this for Branch, change below accordingly
        // // 001100 00,101 00000, 11111 111,11 110000 <= BPL R5, #-16
        // mem[16] = 8'b00110000;
        // mem[17] = 8'b10100000;
        // mem[18] = 8'b11111111;
        // mem[19] = 8'b11110000;

        // 001110 00,000 00000, 00000 000,00 000100 <= LDSP SP, 4(R0) (here rs is R0)
        mem[16] = 8'b00111000;
        mem[17] = 8'b00000000;
        mem[18] = 8'b00000000;
        mem[19] = 8'b00000100;

        // 001111 00,000 00000, 00000 000,00 001100 <= STSP SP, 12(R0) (here rs is R0)
        mem[20] = 8'b00111100;
        mem[21] = 8'b00000000;
        mem[22] = 8'b00000000;
        mem[23] = 8'b00001100;

        // 000000 00,011 00101, 00100 000,00 000000 <= ADD R4, R3, R5 (just to recheck SP / Bout is being taken accordingly)
        mem[24] = 8'b00000000;
        mem[25] = 8'b01100101;
        mem[26] = 8'b00100000;
        mem[27] = 8'b00000000;

        // 010000 00,001 00000, 00000 000,00 000000 <= PUSH R1 (here rs is R1)
        mem[28] = 8'b01000000;
        mem[29] = 8'b00100000;
        mem[30] = 8'b00000000;
        mem[31] = 8'b00000000;

        // 010001 00,100 00000, 00000 000,00 000000 <= POP R4 (here rd is R4)
        mem[32] = 8'b01000100;
        mem[33] = 8'b10000000;
        mem[34] = 8'b00000000;
        mem[35] = 8'b00000000;

        // // 010101 00,000 00000, 00000 000,00 000000 <= HALT (uncomment this and comment next one to halt execution)
        // mem[36] = 8'b01010100;
        // mem[37] = 8'b00000000;
        // mem[38] = 8'b00000000;
        // mem[39] = 8'b00000000;

        // 010010 11,111 11111, 11111 111,11 111000 <= CALL #8
        mem[36] = 8'b01001011;
        mem[37] = 8'b11111111;
        mem[38] = 8'b11111111;
        mem[39] = 8'b11111000;

        // 010110 00,000 00000, 00000 000,00 000000 <= NOP
        mem[40] = 8'b01011000;
        mem[41] = 8'b00000000;
        mem[42] = 8'b00000000;
        mem[43] = 8'b00000000;

        // 010110 00,000 00000, 00000 000,00 000000 <= NOP
        mem[44] = 8'b01011000;
        mem[45] = 8'b00000000;
        mem[46] = 8'b00000000;
        mem[47] = 8'b00000000;

        // 010011 00,000 00000, 00000 000,00 000000 <= RET
        mem[48] = 8'b01001100;
        mem[49] = 8'b00000000;
        mem[50] = 8'b00000000;
        mem[51] = 8'b00000000;

        // 010101 00,000 00000, 00000 000,00 000000 <= HALT
        mem[52] = 8'b01010100;
        mem[53] = 8'b00000000;
        mem[54] = 8'b00000000;
        mem[55] = 8'b00000000;
    end
    assign out = {mem[src], mem[src+1], mem[src+2], mem[src+3]};

    always @(*)
        $display("src = %b\n", src);
endmodule
*/
                
module datapath(clk,  pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, alumux1sel, alumux2sel, dmemwe, lmdre, lmdwe, reginmuxsel, aluenable, irwe, aluoutre, aluoutwe, immmuxsel, alusel, cond, dpout, rs, rt, rd, spop, boutspmuxsel, aluoutspmuxsel, pcmemsel, ledout);

    input clk;
    input pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, alumux1sel, alumux2sel, dmemwe, lmdre, lmdwe, reginmuxsel, aluenable, irwe, aluoutre, aluoutwe, aluoutspmuxsel, pcmemsel;
    input immmuxsel;
    input [5:0] alusel;
    input [4:0] rs, rt, rd;
    input [2:0] cond;
    input [2:0] spop;
    input [1:0] boutspmuxsel;
    output [31:0] dpout;

    wire flag;
    wire signed [31:0] pcdatout, npcout, pcplus4, irout, inst, regbdata_out1, regbdata_out2, regbdata_in, sg1out, sg2out, sg3out, sg4out, siexval, Aout, Bout, alumux1out, alumux2out, aluresult, aluoutout, dmemout, lmdout, pcdatin, spdatout, regbdatasp_in, aluoutspout, pcdatin1, regledout;
    output reg signed [31:0] ledout;
    // assign pcdatout = 4;
    // assign pcdatain = 0;
    
    always @(posedge clk)
        ledout <= regledout;

    always @(*)
        $display("pcdatin = %d, pcdatout = %d\n", pcdatin, pcdatout);

    allregio pc (.clk(clk), .re(pcre), .we(pcwe), .in(pcdatin), .out(pcdatout));
    incr pcp4 (.in(pcdatout), .out(pcplus4), .clk(clk));
    allregio npc (.clk(clk), .re(npcre), .we(npcwe), .in(pcplus4), .out(npcout));

    stackpointer sp (.immdata(siexval), .memdata(lmdout), .out(spdatout), .op(spop), .clk(clk));

    instructionmemory imem (.src(pcdatout), .out(inst));

    assign dpout = inst;
    // always @(posedge clk) $display("pcwe = %0d\npcre = %0d\npcdatout = %0d\n", pcwe, pcre, pcdatout);

    allregio ir (.clk(clk), .re(1'b1), .we(irwe), .in(inst), .out(irout));

    regbank regbnk (.in1(rs), .in2(rt), .w1(rd), .ren1(rsrecs), .ren2(rtrecs), .wen(rdwecs), .out1(regbdata_out1), .out2(regbdata_out2), .data(regbdata_in), .clk(clk), .ledout(regledout));
    allregio A (.clk(clk), .re(Are), .we(Awe), .in(regbdata_out1), .out(Aout));
    allregio B (.clk(clk), .re(Bre), .we(Bwe), .in(regbdata_out2), .out(Bout));

    // signextend1 sg1 (irout[13:0], sg1out);
    // signextend1 sg2 (irout[13:0], sg2out);
    // signextend1 sg3 (irout[13:0], sg3out);
    // signextend1 sg4 (irout[13:0], sg4out);
    //  --- Alernative above ----
    signextendimm sgimm (.imm(irout[15:0]), .out(sg1out));
    signextendimm1 sgimm1 (.imm1(irout[25:0]), .out(sg2out));
   
    // MUX4to1 immmux(sg1out,sg2out,sg3out,sg4out,immmuxsel,siexval);
    // --- Alternative above ---
    MUX2to1 immmux (.in1(sg1out), .in2(sg2out), .sel(immmuxsel), .out(siexval));

    MUX2to1 alumux1 (.in1(npcout), .in2(Aout), .sel(alumux1sel), .out(alumux1out));
    MUX2to1 alumux2 (.in1(Bout), .in2(siexval), .sel(alumux2sel), .out(alumux2out));

    MUX4to1 boutspmux (.in1(Bout), .in2(spdatout), .in3(aluoutout), .in4(32'd0), .sel(boutspmuxsel), .out(regbdatasp_in));
    MUX2to1 aluoutspmux (.in1(aluoutout), .in2(spdatout), .sel(aluoutspmuxsel), .out(aluoutspout));

    alu ALU (.op(alusel), .r1(alumux1out), .r2(alumux2out), .imm(alumux2out), .out(aluresult), .clk(clk), .enable(aluenable));
 
    allregio aluout (.clk(clk), .re(aluoutre), .we(aluoutwe), .in(aluresult), .out(aluoutout));

    datamemory dmem (.src(aluoutspout), .data(regbdatasp_in), .rw(dmemwe), .out(dmemout));

    allregio LMD (.clk(clk), .re(lmdre), .we(lmdwe), .in(dmemout), .out(lmdout));

    conditionalbranch cdbr (.in(Aout), .cond(cond), .flag(flag)); // flag is output

    MUX2to1 pcmux (.in1(npcout), .in2(aluoutout), .sel(flag), .out(pcdatin1));

    MUX2to1 pcmumin (.in1(pcdatin1), .in2(lmdout), .sel(pcmemsel), .out(pcdatin));

    MUX2to1 reginmux (.in1(lmdout), .in2(aluoutout), .sel(reginmuxsel), .out(regbdata_in));
endmodule

module controlunit(clk, en, ir, pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, aluenable, alumux1sel, alumux2sel, aluoutre, aluoutwe, dmemwe, lmdre, lmdwe, reginmuxsel, irwe, alusel, immmuxsel, cond, rs, rt, rd, spop, boutspmuxsel, aluoutspmuxsel, pcmemsel, continue);

    input clk, en, continue;
    input wire [31:0] ir;

    output reg pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, aluenable, alumux1sel, alumux2sel, aluoutre, aluoutwe, dmemwe, lmdre, lmdwe, reginmuxsel, irwe, aluoutspmuxsel, pcmemsel;
    output reg [5:0] alusel;
    output reg immmuxsel;
    output reg [2:0] cond;
    output reg [2:0] spop;
    output reg [1:0] boutspmuxsel;
    output reg [4:0] rs, rt, rd;

    reg [5:0]  mainstate;
    reg [4:0] substate;
    reg [31:0] irst;

    reg halt;
    
    initial 
        begin
            halt = 0;
            mainstate = 6'd0;
            substate = 5'd0;
            boutspmuxsel = 2'b0;
            aluoutspmuxsel = 1'b0;
            pcmemsel = 1'b0;
        end

    always @(posedge clk) 
        begin
            case (mainstate)
                6'd0: 
                    begin
                        if(halt)
                            mainstate <= 6'd3;
                        if(en) 
                            begin
                                pcre <= 1;
                                pcwe <= 0;
                                npcre <= 1;
                                npcwe <= 1;

                                mainstate <= 6'd1;
                            end
                    end

                6'd1: 
                    begin
                        irwe <= 1;
                        pcre <= 1;
                        pcwe <= 0;
                        npcre <= 1;
                        npcwe <= 0;

                        mainstate <= 6'd2;
                    end

                6'd2: 
                    begin
                        irwe <= 1;
                        irst <= ir;

                        mainstate <= 6'd3;
                    end

                6'd3:
                    begin
                        $display("%b\n", irst);
                        case(irst[31:26])
                            0:
                                begin
                                    // $display("R Type Entered\n");
                                    case(substate)
                                        5'd0:
                                            begin
                                            // $display("SS 0 Entered\n");
                                                rs <= irst[25:21];
                                                rt <= irst[20:16];
                                                rd <= irst[15:11];

                                                rsrecs <= 1;
                                                rtrecs <= 1;

                                                alusel <= irst[5:0];

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                            // $display("SS 1 Entered\n"); 
                                                Are <= 1;
                                                Awe <= 1;
                                                Bre <= 1;
                                                Bwe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                            // $display("SS 2 Entered\n"); 
                                                Are <= 1;
                                                Awe <= 0;
                                                Bre <= 1;
                                                Bwe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                // $display("SS 3 Entered\n"); 
                                                alumux1sel <= 1;
                                                alumux2sel <= 0;

                                                substate <= 5'd4;
                                            end

                                        5'd4:   
                                            begin
                                                // $display("SS 4 Entered\n"); 
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <=1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                cond <= 3'd0;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                reginmuxsel <= 1;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                rdwecs <= 1;

                                                substate <= 5'd9;
                                            end

                                        5'd9:
                                            begin
                                                rdwecs <= 0;

                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            1, 2, 3, 4, 5, 6, 7, 8:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                rs <= irst[25:21];
                                                rd <= irst[20:16];

                                                rsrecs <= 1;

                                                alusel <= irst[31:26]-1;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Are <= 1;
                                                Awe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Are <= 1;
                                                Awe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                immmuxsel <= 0;
                                                alumux1sel <= 1;
                                                alumux2sel <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <=1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                cond <= 3'd0;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                reginmuxsel <= 1;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                rdwecs <= 1;

                                                substate <= 5'd9;
                                            end

                                        5'd9:
                                            begin
                                                rdwecs <= 0;

                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            9:
                               begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                rs <= irst[25:21];
                                                rd <= irst[20:16];

                                                rsrecs <= 1;

                                                alusel <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Are <= 1;
                                                Awe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Are <= 1;
                                                Awe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                immmuxsel <= 0;
                                                alumux1sel <= 1;
                                                alumux2sel <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <=1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                cond <= 3'd0;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                lmdre <= 1;
                                                lmdwe <= 1;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                reginmuxsel <= 0;

                                                substate <= 5'd9;
                                            end

                                        5'd9:
                                            begin
                                                rdwecs <= 1;

                                                substate <= 5'd10;
                                            end

                                        5'd10:
                                            begin
                                                rdwecs <= 0;

                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            10:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                rt <= irst[25:21];
                                                rs <= irst[20:16];

                                                rsrecs <= 1;

                                                alusel <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Are <= 1;
                                                Awe <= 1;
                                                Bre <= 1;
                                                Bwe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Are <= 1;
                                                Awe <= 0;
                                                Bre <= 1;
                                                Bwe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                immmuxsel <= 0;
                                                alumux1sel <= 1;
                                                alumux2sel <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <= 1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                cond <= 3'd0;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                dmemwe <= 1;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            11, 12, 13:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                rs <= irst[25:21];

                                                rsrecs <= 1;

                                                alusel <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Are <= 1;
                                                Awe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Are <= 1;
                                                Awe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                immmuxsel <= 0;
                                                alumux1sel <= 0;
                                                alumux2sel <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <= 1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                case(irst[31:26])
                                                    11:
                                                        begin
                                                            cond <= 3'd1;
                                                        end

                                                    12:
                                                        begin
                                                            cond <= 3'd2;
                                                        end

                                                    13:
                                                        begin
                                                            cond <= 3'd3;
                                                        end
                                                endcase

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            20:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                alusel <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                immmuxsel <= 1;
                                                alumux1sel <= 0;
                                                alumux2sel <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                cond <= 3'd4;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            14:
                                begin
                                     case(substate)
                                        5'd0:
                                            begin
                                                rs <= irst[25:21];

                                                rsrecs <= 1;

                                                alusel <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Are <= 1;
                                                Awe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Are <= 1;
                                                Awe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                immmuxsel <= 0;
                                                alumux1sel <= 1;
                                                alumux2sel <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <= 1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                cond <= 3'd0;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                lmdre <= 1;
                                                lmdwe <= 1;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                spop <= 3'd4;

                                                substate <= 5'd9;
                                            end

                                        5'd9:
                                            begin
                                                spop <= 3'd0;

                                                substate <= 5'd10;
                                            end

                                        5'd10:
                                            begin
                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end
                            
                            15:
                                begin
                                     case(substate)
                                        5'd0:
                                            begin
                                                rs <= irst[25:21];

                                                rsrecs <= 1;

                                                alusel <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Are <= 1;
                                                Awe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Are <= 1;
                                                Awe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                immmuxsel <= 0;
                                                alumux1sel <= 1;
                                                alumux2sel <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <= 1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                cond <= 3'd0;
                                                boutspmuxsel <= 1;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                dmemwe <= 1;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                boutspmuxsel <= 0;

                                                substate <= 5'd9;
                                            end

                                        5'd9:
                                            begin
                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end
                            
                            16:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                rt <= irst[25:21];

                                                rtrecs <= 1;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Bre <= 1;
                                                Bwe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Bre <= 1;
                                                Bwe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                cond <= 3'd0;
                                                aluoutspmuxsel <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                dmemwe <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutspmuxsel <= 0;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                spop <= 3'd2;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                spop <= 3'd0;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end
                            
                            17:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                rd <= irst[25:21];
                                                aluenable <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                spop <= 3'd1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                spop <= 3'd0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                cond <= 3'd0;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluoutspmuxsel <= 1;
                                                reginmuxsel <= 0;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                lmdre <= 1;
                                                lmdwe <= 1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                rdwecs <= 1;
                                                aluoutspmuxsel <= 0;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                rdwecs <= 0;

                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            18:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                rt <= 5'd0;

                                                rtrecs <= 1;
                                                alusel <= 0;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                Bre <= 1;
                                                Bwe <= 1;

                                                substate <= 5'd2;
                                            end

                                        5'd2:
                                            begin
                                                Bre <= 1;
                                                Bwe <= 0;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                alumux1sel <= 0;
                                                alumux2sel <= 0;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <= 1;

                                                substate <= 5'd6;
                                            end

                                        5'd6:
                                            begin
                                                aluoutspmuxsel <= 1;
                                                boutspmuxsel <= 2;

                                                substate <= 5'd7;
                                            end

                                        5'd7:
                                            begin
                                                dmemwe <= 1;

                                                substate <= 5'd8;
                                            end

                                        5'd8:
                                            begin
                                                aluoutspmuxsel <= 0;
                                                boutspmuxsel <= 0;

                                                substate <= 5'd9;
                                            end

                                        5'd9:
                                            begin
                                                spop <= 3'd2;
                                                dmemwe <= 0;

                                                substate <= 5'd10;
                                            end

                                        5'd10:
                                            begin
                                                spop <= 3'd0;

                                                substate <= 5'd11;
                                            end

                                        5'd11:
                                            begin
                                                immmuxsel <= 1;
                                                alumux1sel <= 0;
                                                alumux2sel <= 1;
                                                alusel <= 0;

                                                substate <= 5'd12;
                                            end

                                        5'd12:
                                            begin
                                                aluenable <= 1;

                                                substate <= 5'd13;
                                            end
                                        
                                        5'd13:
                                            begin
                                                aluoutre <= 1;
                                                aluoutwe <= 1;

                                                substate <= 5'd14;
                                            end

                                        5'd14:
                                            begin
                                                cond = 3'd4;

                                                substate <= 5'd15;
                                            end

                                        5'd15:
                                            begin
                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end

                            19:
                                begin
                                    case(substate)
                                        5'd0:
                                            begin
                                                spop <= 3'd1;

                                                substate <= 5'd1;
                                            end

                                        5'd1:
                                            begin
                                                spop <= 3'd0;

                                                substate <= 5'd12;
                                            end

                                        5'd2:
                                            begin
                                                aluoutspmuxsel <= 1;

                                                substate <= 5'd3;
                                            end

                                        5'd3:
                                            begin
                                                lmdre <= 1;
                                                lmdwe <= 1;

                                                substate <= 5'd4;
                                            end

                                        5'd4:
                                            begin
                                                aluoutspmuxsel <= 0;
                                                pcmemsel <= 1;

                                                substate <= 5'd5;
                                            end

                                        5'd5:
                                            begin
                                                pcmemsel <= 0;

                                                mainstate <= 6'd4;
                                                substate <= 5'd0;
                                            end
                                    endcase
                                end
                            
                            21:
                                begin
                                    halt <= 1;
                                    $display(" ****************************** HALT *******************************\n");
                                    if(continue)
                                        halt <= 0;

                                    mainstate <= 6'd0;
                                end

                        endcase

                    end

                6'd4:
                    begin
                        pcre <= 1;
                        pcwe <= 1;

                        mainstate <= 6'd5;
                    end

                6'd5:
                    begin
                        mainstate <= 6'd0;
                    end
                        
            endcase

        end

endmodule



module topmodule(clk, continue, ledout);
    input clk, continue, up;

    wire pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdrecs, Are, Awe, Bre, Bwe, alumux1sel, alumux2sel, dmemwe, lmdre, lmdwe, reginmuxsel, aluenable, irwe, aluoutre, aluoutwe;
    wire [4:0] rs, rt, rd;
    
    wire en;
    assign en = 1;

    wire immmuxsel, aluoutspmuxsel, pcmemsel;
    wire [1:0] boutspmuxsel;
    wire [5:0] alusel;
    wire [2:0] cond;
    wire [2:0] spop;
    wire [31:0] ir;
    output signed [31:0] ledout;
    


    datapath data(clk, pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, alumux1sel, alumux2sel, dmemwe, lmdre, lmdwe, reginmuxsel, aluenable, irwe, aluoutre, aluoutwe, immmuxsel, alusel, cond, ir, rs, rt, rd, spop, boutspmuxsel, aluoutspmuxsel, pcmemsel, ledout);
    controlunit control(clk, en, ir, pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, aluenable, alumux1sel, alumux2sel, aluoutre, aluoutwe, dmemwe, lmdre, lmdwe, reginmuxsel, irwe, alusel, immmuxsel, cond, rs, rt, rd, spop, boutspmuxsel, aluoutspmuxsel, pcmemsel, continue);
    
        
endmodule 




module testbench();
    reg clk,continue;
    wire signed [31:0] ledout;
    topmodule test (clk,continue,ledout );

    initial begin
            clk = 1'b0;
            forever begin
                #5 clk = ~clk;
            end
        end
    
    initial begin
    

        #55000 $finish;
    end
endmodule






/* 
    module topmodule(clk, continue, led16, up);
    input clk, continue, up;

    wire pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdrecs, Are, Awe, Bre, Bwe, alumux1sel, alumux2sel, dmemwe, lmdre, lmdwe, reginmuxsel, aluenable, irwe, aluoutre, aluoutwe;
    wire [4:0] rs, rt, rd;
    
    wire en;
    assign en = 1;

    wire immmuxsel, aluoutspmuxsel, pcmemsel;
    wire [1:0] boutspmuxsel;
    wire [5:0] alusel;
    wire [2:0] cond;
    wire [2:0] spop;
    wire [31:0] ir;
    wire signed [31:0] ledout;
    output reg [15:0] led16;

    datapath data(clk, pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, alumux1sel, alumux2sel, dmemwe, lmdre, lmdwe, reginmuxsel, aluenable, irwe, aluoutre, aluoutwe, immmuxsel, alusel, cond, ir, rs, rt, rd, spop, boutspmuxsel, aluoutspmuxsel, pcmemsel, ledout);
    controlunit control(clk, en, ir, pcre, pcwe, npcre, npcwe, rsrecs, rtrecs, rdwecs, Are, Awe, Bre, Bwe, aluenable, alumux1sel, alumux2sel, aluoutre, aluoutwe, dmemwe, lmdre, lmdwe, reginmuxsel, irwe, alusel, immmuxsel, cond, rs, rt, rd, spop, boutspmuxsel, aluoutspmuxsel, pcmemsel, continue);
    
    always @(posedge clk)
    begin
        if(up)
            led16 <= ledout[31:16];
        else
            led16 <= ledout[15:0];
    end
endmodule 

*/

