module instructionmemory (src, out);
//module instructionmemor (src, out);
    input [31:0] src;
    output [31:0] out;

    reg [7:0] mem [0:511];
    initial begin

        // Assuming actual memory has "a" in address 0 and "b" in address 4, and we have to find gcd(a, b)

        // 001001 00,000 00001, 00000 000,00 000000 <= LD R1, 0(R0) (here rs is R0, rt is R1)
        mem[0] = 8'b00100100;
        mem[1] = 8'b00000001;
        mem[2] = 8'b00000000;
        mem[3] = 8'b00000000;

        // 001001 00,000 00010, 00000 000,00 000100 <= LD R2, 4(R0) (here rs is R0, rt is R2)
        mem[4] = 8'b00100100;
        mem[5] = 8'b00000010;
        mem[6] = 8'b00000000;
        mem[7] = 8'b00000100;

        // 001100 00,001 00000, 00000 000,00 00100 <= BPL R1, #4 (here rs is R1, offset is 4)
        mem[8] = 8'b00110000;
        mem[9] = 8'b00100000;
        mem[10] = 8'b00000000;
        mem[11] = 8'b00000100;

        // 000000 00,000 00001, 00001 000,00 000001 <= SUB R1, R0, R1 (here rs is R0, rt is R1, rd is R1)
        mem[12] = 8'b00000000;
        mem[13] = 8'b00000001;
        mem[14] = 8'b00001000;
        mem[15] = 8'b00000001;

        // 001100 00,010 00000, 00000 000,00 00100 <= BPL R2, #4 (here rs is R2, offset is 4)
        mem[16] = 8'b00110000;
        mem[17] = 8'b01000000;
        mem[18] = 8'b00000000;
        mem[19] = 8'b00000100;

        // 000000 00,000 00010, 00010 000,00 000001 <= SUB R2, R0, R2 (here rs is R0, rt is R2, rd is R2)
        mem[20] = 8'b00000000;
        mem[21] = 8'b00000010;
        mem[22] = 8'b00010000;
        mem[23] = 8'b00000001;

        // 001101 00,001 00000, 00000 000,00 100100 <= BZ R1, #36 (here rs is R1, offset is 36)
        mem[24] = 8'b00110100;
        mem[25] = 8'b00100000;
        mem[26] = 8'b00000000;
        mem[27] = 8'b00100100;

        // 001101 00,010 00000, 00000 000,00 100000 <= BZ R2, #32 (here rs is R2, offset is 32)
        mem[28] = 8'b00110100;
        mem[29] = 8'b01000000;
        mem[30] = 8'b00000000;
        mem[31] = 8'b00100000;

        // 000000 00,001 00010, 00011 000,00 000001 <= SUB R3, R1, R2 (here rs is R1, rt is R2, rd is R3)
        mem[32] = 8'b00000000;
        mem[33] = 8'b00100010;
        mem[34] = 8'b00011000;
        mem[35] = 8'b00000001;

        // 001101 00,011 00000, 00000 000,00 100000 <= BZ R3, #32 (here rs is R3, offset is 32)
        mem[36] = 8'b00110100;
        mem[37] = 8'b01100000;
        mem[38] = 8'b00000000;
        mem[39] = 8'b00100000;

        // 000000 00,010 00001, 00100 000,00 000001 <= SUB R4, R2, R1 (here rs is R2, rt is R1, rd is R4)
        mem[40] = 8'b00000000;
        mem[41] = 8'b01000001;
        mem[42] = 8'b00100000;
        mem[43] = 8'b00000001;

        // 001100 00,011 00000, 00000 000,00 001000 <= BPL R3, #8 (here rs is R3, offset is 8)
        mem[44] = 8'b00110000;
        mem[45] = 8'b01100000;
        mem[46] = 8'b00000000;
        mem[47] = 8'b00001000;

        // 000000 00,100 00000, 00010 000,00 001001 <= MOVE R2, R4 (here rs is R4, rd is R2)
        mem[48] = 8'b00000000;
        mem[49] = 8'b10000000;
        mem[50] = 8'b00010000;
        mem[51] = 8'b00001001;

        // 010100 11,111 11111, 11111 111,11 100000 <= BR #-32 (here offset is -32)
        mem[52] = 8'b01010011;
        mem[53] = 8'b11111111;
        mem[54] = 8'b11111111;
        mem[55] = 8'b11100000;

        // 000000 00,011 00000, 00001 000,00 001001 <= MOVE R1, R3 (here rs is R3, rd is R1)
        mem[56] = 8'b00000000;
        mem[57] = 8'b01100000;
        mem[58] = 8'b00001000;
        mem[59] = 8'b00001001;

        // 010100 11,111 11111, 11111 111,11 011100 <= BR #-40 (here offset is -40)
        mem[60] = 8'b01010011;
        mem[61] = 8'b11111111;
        mem[62] = 8'b11111111;
        mem[63] = 8'b11011100;

        // 000000 00,001 00010, 00011 000,00 000000 <= ADD R3, R1, R2 (here rs is R1, rt is R2, rd is R3)
        mem[64] = 8'b00000000;
        mem[65] = 8'b00100010;
        mem[66] = 8'b00011000;
        mem[67] = 8'b00000000;

        // 010100 00,000 00000, 00000 000,00 000100 <= BR #4 (here offset is 4)
        mem[68] = 8'b01010000;
        mem[69] = 8'b00000000;
        mem[70] = 8'b00000000;
        mem[71] = 8'b00000100;

        // 000000 00,001 00000, 00011 000,00 001001 <= MOVE R3, R1 (here rs is R1, rd is R3)
        mem[72] = 8'b00000000;
        mem[73] = 8'b00100000;
        mem[74] = 8'b00011000;
        mem[75] = 8'b00001001;
        
        // 000000 00,011 00000, 00010 000,00 001001 <= MOVE R2, R3 (here rs is R1, rd is R3)
        mem[76] = 8'b00000000;
        mem[77] = 8'b01100000;
        mem[78] = 8'b00010000;
        mem[79] = 8'b00001001;

        // Answer => gcd(a, b) is now in R3

    end
    assign out = {mem[src], mem[src+1], mem[src+2], mem[src+3]};

    always @(src)
        begin
            case(src)
                0: $display("LD R1, 0(R0) (here rs is R0, rt is R1)\n");
                4: $display("LD R2, 4(R0) (here rs is R0, rt is R2)\n");
                8: $display("BPL R1, #4 (here rs is R1, offset is 4)\n");
                12: $display("SUB R1, R0, R1 (here rs is R0, rt is R1, rd is R1)\n");
                16: $display("BPL R2, #4 (here rs is R2, offset is 4)\n");
                20: $display("SUB R2, R0, R2 (here rs is R0, rt is R2, rd is R2)\n");
                24: $display("BZ R1, #36 (here rs is R1, offset is 36)\n");
                28: $display("BZ R2, #32 (here rs is R2, offset is 32)\n");
                32: $display("SUB R3, R1, R2 (here rs is R1, rt is R2, rd is R3)\n");
                36: $display("BZ R3, #32 (here rs is R3, offset is 32)\n");
                40: $display("SUB R4, R2, R1 (here rs is R2, rt is R1, rd is R4)\n");
                44: $display("BPL R3, #8 (here rs is R3, offset is 8)\n");
                48: $display("MOVE R2, R4 (here rs is R4, rd is R2)\n");
                52: $display("BR #-32 (here offset is -32)\n");
                56: $display("MOVE R1, R3 (here rs is R3, rd is R1)\n");
                60: $display("BR #-40 (here offset is -40)\n");
                64: $display("ADD R3, R1, R2 (here rs is R1, rt is R2, rd is R3)\n");
                68: $display("BR #4 (here offset is 4)\n");
                72: $display("MOVE R3, R1 (here rs is R1, rd is R3)\n");
                76: $display("MOVE R2, R3 (here rs is R3, rd is R2)\n");
                80: $display("GCD Computed !! Answer => gcd(a, b) is now in R2 - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! - !!! \n");
            endcase
        end

    always @(*)
        $display("src = %d\n", src);
endmodule