module ALU_tb;

    // Inputs
    logic [31:0] command;
    logic [31:0] reg_file [31:0];

    // Output
    logic [31:0] result;

    // Instantiate the ALU
    ALU uut (
        .command(command),
        .reg_file(reg_file),
        .result(result)
    );

    // Testbench logic
    initial begin
        // Initialize the register file with some test values
        reg_file[0] = 32'd0;      // Zero register
        reg_file[1] = 32'd10;     // Example values
        reg_file[2] = 32'd20;
        reg_file[3] = 32'd5;
        reg_file[4] = 32'd15;
        reg_file[5] = -32'd8;     // Signed negative value

        // Test ADD (rs1=1, rs2=2, rd=3)
        command = 32'b0000000_00010_00001_000_00011_0110011; // ADD: reg[1] + reg[2]
        #10; // Wait for the ALU to compute

        // Test SUB (rs1=2, rs2=1, rd=3)
        command = 32'b0100000_00001_00010_000_00011_0110011; // SUB: reg[2] - reg[1]
        #10;
        

        // Test SLL (Shift Left Logical, rs1=1, rs2=3, rd=4)
        command = 32'b0000000_00011_00001_001_00100_0110011; // SLL: reg[1] << reg[3]
        #10;
        

        // Test SLT (Set Less Than, rs1=1, rs2=2, rd=5)
        command = 32'b0000000_00010_00001_010_00101_0110011; // SLT: reg[1] < reg[2]
        #10;
        

        // Test SLTU (Unsigned SLT, rs1=5, rs2=4, rd=6)
        command = 32'b0000000_00100_00101_011_00110_0110011; // SLTU: reg[5] < reg[4]
        #10;
        

        // Test XOR (rs1=1, rs2=4, rd=7)
        command = 32'b0000000_00100_00001_100_00111_0110011; // XOR: reg[1] ^ reg[4]
        #10;
        

        // Test SRL (Shift Right Logical, rs1=2, rs2=3, rd=8)
        command = 32'b0000000_00011_00010_101_01000_0110011; // SRL: reg[2] >> reg[3]
        #10;
        
        // Test SRA (Shift Right Arithmetic, rs1=5, rs2=3, rd=9)
        command = 32'b0100000_00011_00101_101_01001_0110011; // SRA: reg[5] >>> reg[3]
        #10;
        

        // Test OR (rs1=1, rs2=2, rd=10)
        command = 32'b0000000_00010_00001_110_01010_0110011; // OR: reg[1] | reg[2]
        #10;
        

        // Test AND (rs1=1, rs2=2, rd=11)
        command = 32'b0000000_00010_00001_111_01011_0110011; // AND: reg[1] & reg[2]
        #10;
        

        
        $finish;
    end

endmodule
