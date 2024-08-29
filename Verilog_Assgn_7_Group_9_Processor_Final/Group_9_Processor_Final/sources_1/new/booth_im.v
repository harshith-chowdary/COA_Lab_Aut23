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

        //000110 00,001 00001,00000 000,00 010000 SLAI R1,R1,16
        mem[8]= 8'b00011000;
        mem[9]= 8'b00100001;
        mem[10]=8'b00000000;
        mem[11]=8'b00010000;

        //000001 00,000 00100,00000 000,00 010000 ADDI R4,R0,16

        mem[12]=8'b00000100;
        mem[13]=8'b00000100;
        mem[14]=8'b00000000;
        mem[15]=8'b00010000;

        //000001 00,000 00011,00000 000,00 000000 ADDI R3,R0,0
        mem[16]=8'b00000100;
        mem[17]=8'b00000011;
        mem[18]=8'b00000000;
        mem[19]=8'b00000000;

        //001101 00,100 00000,00000000,00110000//fill the adress//BZ R4 #48
        mem[20]=8'b00110100;
        mem[21]=8'b10000000;
        mem[22]=8'b00000000;
        mem[23]=8'b00110000;

       // 001101 00,011 00000,00000000 ,00010100//fill in the adress BZ R3 #20
        mem[24]=8'b00110100;
        mem[25]=8'b01100000;
        mem[26]=8'b00000000;
        mem[27]=8'b00010100;

        //case when Q-1 is 1

        //000011 00,010 00011,00000 000,00 000001 ANDI R3,R2,1
        mem[28]=8'b00001100;
        mem[29]=8'b01000011;
        mem[30]=8'b00000000;
        mem[31]=8'b00000001;

        //001101 00,011 00000, 00000000,00000100 checking Q0
        mem[32]=8'b00110100;
        mem[33]=8'b01100000;
        mem[34]=8'b00000000;
        mem[35]=8'b00000100;
        //case when Q0 is 1 go to shift staement ie BR 
        // 010100 00,000 00000,00000 000,00010100
        
        mem[36]=8'b01010000;
        mem[37]=8'b00000000;
        mem[38]=8'b00000000;
        mem[39]=8'b00010100;
        // A=A+M ie R2=R2+R1
        //000000 00,001 00010,00010 000,00 000000 
        mem[40]=8'b00000000;
        mem[41]=8'b00100010;
        mem[42]=8'b00010000;
        mem[43]=8'b00000000;
        //Jump to Shift statement
        // 010100 00,000 00000,00000 000,00001100
        mem[44]=8'b01010000;
        mem[45]=8'b00000000;
        mem[46]=8'b00000000;
        mem[47]=8'b00001100;
        // Case when Q0 is O begins
        //000011 00,010 00011,00000 000,00 000001 ANDI R3,R2,1
        mem[48]=8'b00001100;
        mem[49]=8'b01000011;
        mem[50]=8'b00000000;
        mem[51]=8'b00000001;
        //001101 00,011 00000, 00000000,00000100 checking Q0 0 case
        mem[52]=8'b00110100;
        mem[53]=8'b01100000;
        mem[54]=8'b00000000;
        mem[55]=8'b00000100;
        //case when Q0 is 1
        // A=A-M ie R2=R2-R1
        //000000 00,010 00001,00010 000,00 000001
        mem[56]=8'b00000000;
        mem[57]=8'b01000001;
        mem[58]=8'b00010000;
        mem[59]=8'b00000001;
        //shit right arithmetic
       // 000111 00,010 00010,00000000,00000001
        mem[60]=8'b00011100;
        mem[61]=8'b01000010;
        mem[62]=8'b00000000;
        mem[63]=8'b00000001;
        //count-- ie R4=R4-1;
        //000010 00,100 00100,00000000,00000001;
        mem[64]=8'b00001000;
        mem[65]=8'b10000100;
        mem[66]=8'b00000000;
        mem[67]=8'b00000001;
        //Branch to begining of while loop;
        //010100 11,11111111,11111111,11001100
        mem[68]=8'b01010011;
        mem[69]=8'b11111111;
        mem[70]=8'b11111111;
        mem[71]=8'b11001100;
        //NOP 
        //010110 00,00000000,00000000,00000000
        mem[72]=8'b01011000;
        mem[73]=8'b00000000;
        mem[74]=8'b00000000;
        mem[75]=8'b00000000;


    end
    assign out = {mem[src], mem[src+1], mem[src+2], mem[src+3]};

    always @(src)
        begin
            case(src)
                0: $display("Now in 0\n");
                4: $display("Now in 4\n");
                8: $display("Now in 8\n");
                12: $display("Now in 12\n");
                16: $display("Now in 16");
                20: $display("Now in 20\n");
                24: $display("Now in 24\n");
                28: $display("Now in 28\n");
                32: $display("Now in 32\n");
                36: $display("Now in 36\n");
                40: $display("Now in 42\n");
                44: $display("Now in 44\n");
                48: $display("Now in 48\n");
                52: $display("Now in 52\n");
                56: $display("Now in 56\n");
                60: $display("Now in 60\n");
                64: $display("Now in 64\n");
                68: $display("Now in 68\n");
                72: $display("Multiplication computed!! answer is in R2 !!!!!! ");
                
            endcase
        end

    always @(*)
        $display("src = %d\n", src);
endmodule