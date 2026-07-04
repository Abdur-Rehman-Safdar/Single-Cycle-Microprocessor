`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 02:52:41 PM
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


module top_module(
    input clk, rst,
    output reg [31:0] pc,
    output reg [31:0] instruction,
    output reg [4:0]  rs1, rs2, rd
);

// PC Wires
wire [31:0] pc_next;
wire [31:0] pc_out; 
wire [31:0] inst_code; 

// Register file wires
wire        regwrite;       
wire [31:0] read_data1;     
wire [31:0] read_data2;     
wire [31:0] write_data3; 

// Main Control wires
wire [1:0]  ImmSrc;
wire        ALUSrc;
wire        MemWrite;
//wire        MemtoReg;       
wire        Branch;
wire        Jump;
//wire [1:0]  ALUOp;

// ALU and Datapath wires
wire [2:0]  alu_control;
wire [1:0]ResultSrc;
wire [31:0] alu_result;
wire        zero_flag;
wire [31:0] srcA;
wire [31:0] srcB;
wire [31:0] writeData;
wire [31:0] imm_out;
wire        s;
wire [31:0] rd2;

wire [31:0]PCPlus4;
wire [31:0]PCTarget;
wire PCSrc;
wire [31:0]data_out;
wire j; //jump wire
// =================================================================
// Module Instantiations
// =================================================================

PC_32bit PC_inst(clk, rst, pc_next, pc_out);

inst_mem instMem(pc_out, inst_code);

adder_32bit ADD1(pc_out, 32'd4, PCPlus4);


main_decoder MainDecoder(inst_code, regwrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch,Jump, alu_control);

reg_file RegFile(inst_code[19:15], inst_code[24:20], inst_code[11:7], write_data3, regwrite, clk, rst, read_data1, read_data2);

imm_ext immidiateExt(ImmSrc,inst_code, imm_out);


mux RD2mux(read_data2, imm_out, ALUSrc,srcB );

alu_logic ALU(read_data1, srcB, alu_control, alu_result, zero_flag);

adder_32bit ADD2( pc_out,imm_out, PCTarget);
and PC(j,zero_flag,Branch);
or J(PCSrc,j,Jump);
mux PCMux(PCPlus4,PCTarget,PCSrc,pc_next);


data_mem DataMem(clk, MemWrite, alu_result, read_data2, data_out); //from data memory


mux3_1 DataMux(alu_result, data_out, PCPlus4, ResultSrc,write_data3);



always @(*) begin
    pc          = pc_out;
    instruction = inst_code;
    rs1         = inst_code[19:15];
    rs2         = inst_code[24:20];
    rd          = inst_code[11:7];
end

endmodule
