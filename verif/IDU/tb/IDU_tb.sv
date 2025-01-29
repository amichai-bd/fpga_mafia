`timescale 1ns/1ps

module IDU_tb;

    // Inputs to the IDU
    logic [31:0] instr1, instr2;
    // Outputs from the IDU
    logic [31:0] issue_instr1, issue_instr2;

    // Instantiate the IDU module
    IDU dut (
        .instr1(instr1),
        .instr2(instr2),
        .issue_instr1(issue_instr1),
        .issue_instr2(issue_instr2)
    );

    // Task to display results
    task display_results;
        input [31:0] instr1, instr2;
        input [31:0] issue_instr1, issue_instr2;
        begin
            $display("--------------------------------------------------");
            $display("Input Instructions:");
            $display("instr1 = %h", instr1);
            $display("instr2 = %h", instr2);
            $display("Output Issued Instructions:");
            $display("issue_instr1 = %h", issue_instr1);
            $display("issue_instr2 = %h", issue_instr2);
            $display("--------------------------------------------------");
        end
    endtask

    initial begin
        // Test Case 1: No Dependencies
        $display("Test Case 1: No Dependencies");
        instr1 = 32'h00200093; // addi x1, x0, 2
        instr2 = 32'h00300113; // addi x2, x0, 3
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00408093; // addi x1, x1, 4
        instr2 = 32'h00510113; // addi x2, x2, 5
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00200113; // addi x2, x0, 2
        instr2 = 32'h00300213; // addi x4, x0, 3
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00600093; // addi x1, x0, 6
        instr2 = 32'h00700113; // addi x2, x0, 7
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        // Test Case 2: RAW Dependency
        $display("Test Case 2: RAW Dependency");
        instr1 = 32'h00208093; // addi x1, x1, 2
        instr2 = 32'h00108113; // addi x2, x1, 1
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00200093; // addi x1, x0, 2
        instr2 = 32'h00100113; // addi x2, x1, 1
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00300113; // addi x2, x0, 3
        instr2 = 32'h00208113; // addi x2, x2, 2
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00408113; // addi x2, x2, 4
        instr2 = 32'h00310113; // addi x3, x2, 3
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        // Test Case 3: WAW Dependency
        $display("Test Case 3: WAW Dependency");
        instr1 = 32'h00208093; // addi x1, x1, 2
        instr2 = 32'h00308093; // addi x1, x1, 3
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00408113; // addi x2, x1, 4
        instr2 = 32'h00508113; // addi x2, x1, 5
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00610213; // addi x3, x2, 6
        instr2 = 32'h00710213; // addi x3, x2, 7
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00820293; // addi x4, x3, 8
        instr2 = 32'h00920293; // addi x4, x3, 9
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        // Test Case 4: Branch Conditions
        $display("Test Case 4: Branch Conditions");
        instr1 = 32'h00428063; // beq x4, x4, 4
        instr2 = 32'h00500113; // addi x2, x0, 5
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00428063; // beq x4, x4, 4
        instr2 = 32'h00420093; // addi x1, x4, 1
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00428063; // beq x4, x4, 4
        instr2 = 32'h00000063; // beq x0, x0, 0
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        instr1 = 32'h00428063; // beq x4, x4, 4
        instr2 = 32'h00002003; // lb x1, 0(x0)
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2);

        $finish;
    end
endmodule
