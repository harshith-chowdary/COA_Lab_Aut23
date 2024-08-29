`timescale 1ns/1ps

module reg2mem(opcode, regcode, memloc, data, clk, out);
    input [1:0] opcode;
    input [2:0] regcode;
    input [3:0] memloc;
    input [3:0] data;
    input clk;
    
    reg [3:0] R [7:0];
    
    output [3:0] out;
    
    reg ena, wea;
    reg [3:0] addra, dina;
    
    //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
    mem_block your_instance_name (
      .clka(clk),    // input wire clka
      .ena(ena),      // input wire ena
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [3 : 0] addra
      .dina(dina),    // input wire [3 : 0] dina
      .douta(out)  // output wire [3 : 0] douta
    );
    // INST_TAG_END ------ End INSTANTIATION Template ---------
    
    always @(posedge clk)
    begin
        case (opcode)
            0:
                begin
                    dina <= data;
                    addra <= memloc; 
                    ena <= 1;
                    wea <= 1;
                    
                end  
            1:
                begin
                    dina <= R[regcode];
                    addra <= memloc; 
                    ena <= 1;
                    wea <= 1;
                    
                end
            2:
                begin
                    addra <= memloc;
                    ena <= 1;
                    wea <= 0;
                    
                    R[regcode] <= out;
                end
            3:
                begin
                    addra <= memloc;
                    ena <= 1;
                    wea <= 0;
         
                end
        endcase
    end

endmodule