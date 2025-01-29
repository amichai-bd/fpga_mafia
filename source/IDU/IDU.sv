module IDU (
    input logic [31:0] instr1,       
    input logic [31:0] instr2,      
    output logic [31:0] issue_instr1, // Instruction for primary issue
    output logic [31:0] issue_instr2  // Instruction for secondary issue
);

    // Dependency Flags
    logic raw_dependency;  // Read-After-Write (RAW)
    logic waw_dependency;  // Write-After-Write (WAW)
    logic branch_instr;    // Branch detection
    logic mem_access_instr1; // Memory access detection for instr1
    logic mem_access_instr2; // Memory access detection for instr2

    

    logic [6:0] opcode1, opcode2;    // Opcode fields for instr1 and instr2
    logic [4:0] rd1, rs1_1, rs2_1;  // Fields for instr1
    logic [4:0] rd2, rs1_2, rs2_2;  // Fields for instr2

    assign opcode1 = instr1[6:0];
    assign opcode2 = instr2[6:0];

    assign rd1 = instr1[11:7];
    assign rs1_1 = instr1[19:15];
    assign rs2_1 = instr1[24:20];

    assign rd2 = instr2[11:7];
    assign rs1_2 = instr2[19:15];
    assign rs2_2 = instr2[24:20];

    
    assign raw_dependency = (rs1_2 == rd1) || (rs2_2 == rd1);

    assign waw_dependency = (rd1 == rd2) && (rd1 != 5'b0);

    // Branch Detection
    assign branch_instr = (opcode1 == 7'b1100011); 

    // Memory Access Detection
    assign mem_access_instr1 = (opcode1 == 7'b0000011) || // Load instructions
                               (opcode1 == 7'b0100011);  // Store instructions

    assign mem_access_instr2 = (opcode2 == 7'b0000011) || // Load instructions
                               (opcode2 == 7'b0100011);  // Store instructions



    
    always_comb begin
        // Default assignments
        issue_instr1 = instr1;     
        issue_instr2 = instr2;     

        // Ensure memory access in primary issue
        if (mem_access_instr2 && mem_access_instr1 == 0) begin
            issue_instr1 = instr2;
            issue_instr2 = instr1;
        end

        // Stall the second pipe if there are dependencies, branch, or memory access
        if (raw_dependency || waw_dependency || branch_instr || mem_access_instr2) begin
            issue_instr2 = 32'b0; 
        end
    end

endmodule
