`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 02:28:58 PM
// Design Name: 
// Module Name: inst_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inst_mem(input [31:0]PC, output [31:0]inst_code);


reg [7:0] Memory [31:0]; //Memory having 32bits but 8bit depth 
initial begin
        
        // --- Instruction 0: lw = L7:lw x6, -4(x9)
        Memory[0]  = 8'h03; 
        Memory[1]  = 8'ha3; 
        Memory[2] = 8'hc4; 
        Memory[3] = 8'hff; 
        
        // --- Instruction 1: sw = sw x6, 8(x9)
        Memory[4] = 8'h23; 
        Memory[5] = 8'ha4; 
        Memory[6] = 8'h64; 
        Memory[7] = 8'h00; 

        // --- Instruction 2: add = add x4 x6 x6
        Memory[8] = 8'h33; 
        Memory[9] = 8'h02; 
        Memory[10] = 8'h63; 
        Memory[11] = 8'h00; 
        
        // --- Instruction 3: sub = sub x5 x4 x6
        Memory[12] = 8'hb3; 
        Memory[13] = 8'h02; 
        Memory[14] = 8'h62; 
        Memory[15] = 8'h40; 
        
        // --- Instruction 4: beq = beq x4, x4, L7 
        Memory[16] = 8'he3; 
        Memory[17] = 8'h08; 
        Memory[18] = 8'h42; 
        Memory[19] = 8'hfe; 
        
        
        

        // --- Instruction 5: jal x1, offset (Address 20 to 23) ---
        Memory[20] = 8'hef; 
        Memory[21] = 8'hf0; 
        Memory[22] = 8'hdf; 
        Memory[23] = 8'hfe; 
        
        // --- Instruction 6: add s4, t1, t2 (Address 24 to 27) ---
        // Hex: 00730a33 (Little-Endian format)
        Memory[24] = 8'h33; // LSB
        Memory[25] = 8'h0a; 
        Memory[26] = 8'h33; 
        Memory[27] = 8'h00; // MSB
        
    end
    assign inst_code = {Memory[PC+3],Memory[PC+2],Memory[PC+1],Memory[PC]};
    
endmodule