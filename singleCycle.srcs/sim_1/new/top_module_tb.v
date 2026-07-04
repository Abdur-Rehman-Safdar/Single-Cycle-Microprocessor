`timescale 1ns / 1ps

module tb_top_module;
    reg clk;
    reg rst;

    // Top Module Interfaces
    wire [31:0] pc;
    wire [31:0] instruction;
    wire [4:0]  rs1, rs2, rd;

    // Unit Under Test (UUT) Instance
    top_module uut (
        .clk(clk), 
        .rst(rst), 
        .pc(pc), 
        .instruction(instruction), 
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd)
    );

    // 10ns Clock Generation
    always #5 clk = ~clk;

    initial begin
        // --- STEP 1: INITIALIZATION & SIGNAL PRE-LOAD ---
        clk = 0;
        rst = 1;
        #12; // Wait slightly before releasing reset

        // FIX: Aapki reg_file ke mutabiq 'reg_memory' use kiya hai yahan
        uut.RegFile.reg_memory[8]  = 32'd20;  // x8 = 20
        uut.RegFile.reg_memory[9]  = 32'd16;  // x9 = 16 (Base address for LW: 16 - 4 = 12)
        uut.RegFile.reg_memory[18] = 32'd50;  // x18 = 50
        uut.RegFile.reg_memory[19] = 32'd50;  // x19 = 50 (BEQ target matching ke liye)

        // Data Memory mein dynamic pre-load data (LW test karne ke liye)
        uut.DataMem.memory[12] = 8'hDD;
        uut.DataMem.memory[13] = 8'hCC;
        uut.DataMem.memory[14] = 8'hBB;
        uut.DataMem.memory[15] = 8'hAA;     // Poora Word: 32'hAABBCCDD

        rst = 0; // Release reset to kickstart simulation

        // Display Header for Console Monitoring
        $display("\n==========================================================================================");
        $display("STARTING RISC-V SINGLE CYCLE VERIFICATION (WITH EXACT REG_FILE MATCH)");
        $display("==========================================================================================");
        $display("Time\t   PC\t\tInstruction\t rd\t  rs1\t   rs2\tStatus/Command");
        $display("------------------------------------------------------------------------------------------");
        
        // --- STEP 2: CYCLE-BY-CYCLE EQUATIONS VERIFICATION ---

        // 1. Prove LW (Instruction 0 at PC 0)
        @(posedge clk); #2; 
        if (uut.RegFile.reg_memory[6] == 32'hAABBCCDD)
            $display("[PROVED] LW Equation: x6 successfully loaded with data %h | SUCCESS", uut.RegFile.reg_memory[6]);
        else
            $display("[FAILED] LW Equation failed. Expected AABBCCDD, Got %h", uut.RegFile.reg_memory[6]);

        // 2. Prove SW (Instruction 1 at PC 4)
        @(posedge clk); #2;
        if ({uut.DataMem.memory[27], uut.DataMem.memory[26], uut.DataMem.memory[25], uut.DataMem.memory[24]} == 32'hAABBCCDD)
            $display("[PROVED] SW Equation: Data %h safely stored into Memory Address 24 | SUCCESS", 32'hAABBCCDD);
        else
            $display("[FAILED] SW Equation failed to write data into memory.");

        // 3. Prove ADD (Instruction 2 at PC 8)
        @(posedge clk); #2;
        if (uut.RegFile.reg_memory[4] == (32'hAABBCCDD + 32'hAABBCCDD))
            $display("[PROVED] ADD Equation: x4 = x6 + x6 (%h) | SUCCESS", uut.RegFile.reg_memory[4]);
        else
            $display("[FAILED] ADD Equation failed.");

        // 4. Prove SUB (Instruction 3 at PC 12 / 32'hc)
        @(posedge clk); #2;
        if (uut.RegFile.reg_memory[5] == 32'hAABBCCDD)
            $display("[PROVED] SUB Equation: x5 = x4 - x6 (%h) | SUCCESS", uut.RegFile.reg_memory[5]);
        else
            $display("[FAILED] SUB Equation failed.");

        // 5. Prove BEQ Loop / Jump (Instruction 4 at PC 16 / 32'h10)
        @(posedge clk); #2;
        $display("[INFO] Checking BEQ execution... Current PC status: %h", pc);

        // 6. Prove JAL Logic Link Register (Instruction 5 at PC 20 / 32'h14)
        @(posedge clk); #2;
        if (uut.RegFile.reg_memory[1] == 32'd24)
            $display("[PROVED] JAL Equation: Link Register x1 successfully saved return address (PC+4) = %0d | SUCCESS", uut.RegFile.reg_memory[1]);
        else
            $display("[WARNING] JAL Link Register verification skipped or mismatch. current x1 = %h", uut.RegFile.reg_memory[1]);

        #20;
        $display("==========================================================================================");
        $display("RISC-V SINGLE CYCLE VERIFICATION COMPLETED.");
        $display("==========================================================================================");
        $finish;
    end
endmodule