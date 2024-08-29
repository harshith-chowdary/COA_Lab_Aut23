`timescale 1ps/1ps

// Command to run in Icarus verilog 
// 1. % iverilog -o booth booth_module.v
// 2. % vvp booth
// 3. % gtkwave booth.vcd &

module adder(r1, r2, out);
    input [7:0] r1, r2;
    output [7:0] out;

    // always @(*)
    // begin
    //     $display($time, " Adder Called with A = %b, M = %b",r1,r2);
    // end

    assign out = r1+r2;
endmodule

module shifter(r, out);
    input [15:0] r;
    output [15:0] out;

    // always @(*)
    // begin
    //     $display($time, " SHifter Called with AQ = %b",r);
    // end

    assign out = r>>1;
endmodule

module booth(r1, r2, clk, out);
    input [7:0] r1, r2;
    input clk;

    integer i = 0;
    reg [7:0] r12s;
    always @(r1 or r2)
    begin
        r12s = ~r1 + 8'b00000001;
    end

    output reg [15:0] out;
    always @(r1 or r2)
    begin
        out = r2;
    end

    reg msb, lsb, Q_1;

    always @(r1 or r2)
    begin
        i = 0;
        msb = 0;
        lsb = out[0];
        Q_1 = 0;
    end

    parameter zo = 1, oz = 2, shift = 0, shiftt = 3, acc = 4;
    reg [2:0] state;

    always @(r1 or r2)
    begin
        state[2] = 0;
        state[1] = lsb;
        state[0] = Q_1;
    end

    reg [7:0] a1, a2;
    wire [7:0] aout;
    reg [15:0] s;
    wire [15:0] sout;

    adder doo (a1, a2, aout);

    shifter shiftr (s, sout);

    always @(posedge clk or r1 or r2)
    begin
        case (state)
            zo: 
            begin
                a1<=out[15:8];
                a2<=r1;

                #1 out[15:8] = aout;

                #1 msb = out[15];

                state<=shift;
            end
            oz:
            begin
                a1<=out[15:8];
                a2<=r12s;

                #1 out[15:8] = aout;

                #1 msb = out[15];

                state<=shift;
            end
            shift: 
                begin
                    msb <= out[15];
                    lsb <= out[0];

                    Q_1 = lsb;

                    s<=out;

                    #1 out = sout;

                    lsb = out[0];
                    out[15] = msb;
                    
                    state[1] <= lsb;
                    state[0] <= Q_1;

                    i = i+1;
                end
            shiftt:
                begin
                    msb = out[15];
                    lsb = out[0];

                    Q_1 = lsb;

                    s<=out;

                    #1 out = sout;

                    lsb = out[0];
                    out[15] = msb;
                    
                    state[1] <= lsb;
                    state[0] <= Q_1;

                    i=i+1;
                end
            acc:
                state <= acc;
        endcase     

        if(i>=8) 
        begin
            state <= 4;
        end

        // #1 $display($time, "out = %b, state = %b", out, state);
    end
endmodule

// Test Bench to test our code ... (Please follow commented lines for what to do at each required step IN or MOVE)
module test_bench;
    reg [7:0] r1, r2;
    reg clock;

    wire [15:0] out;

    booth test (r1, r2, clock, out);

    initial
        begin
            clock = 1;
        end

    initial
        begin
            // To siulate in GTK Wave use command '% gtkwave gcd.vcd &'
            // $dumpfile("booth.vcd");
            // $dumpvars(0,test);

            $monitor($time, "   : r1 = %b, r2 = %b, r1 x r2 = %b", r1, r2, out);

            r1 = 8'b00000101; r2 = 8'b00010100;
            #50 r1 = 3; r2 = 10;
            #50 r1 = -50; r2 = 5;
            #50 $finish;
        end
        always #1 clock = ~clock;
endmodule