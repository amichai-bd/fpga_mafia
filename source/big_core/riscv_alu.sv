module ALU(
    input logic [31:0] command,
    input  logic [31:0] reg_file [31:0], // Register file (array of 32 registers, 32 bits each)
    output logic [31:0] result
);


// Decode instruction fields
    logic [6:0] opcode;
    logic [4:0] rs1_index, rs2_index; // Indices for rs1 and rs2 in the register file
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] rs1, rs2;           // Values of rs1 and rs2 registers


    assign opcode = command[6:0];
    assign funct3 = command[14:12];
    assign funct7 = command[31:25];
    assign rs1_index = command[19:15];
    assign rs2_index = command[24:20];

    assign rs1 = reg_file[rs1_index];
    assign rs2 = reg_file[rs2_index];

    always_comb begin

        result = 32'b0; // Default output
        
        if (opcode == 7'b0110011) begin
            case (funct3)
                3'b000:
                    if(funct7 == 7'b0000000) begin
                        result = rs1+rs2; //ADD
                    end
                    else if(funct7 == 7'b0100000) begin
                        result = rs1-rs2; //SUB
                    end
                3'b001: begin
                    result = rs1 <<rs2 [4:0]; //Shift Right Logical.
                end 
                3'b010: begin
                     result = ($signed(rs1) < $signed(rs2)) ? 32'b1 : 32'b0; //SLT
                end

                3'b011: begin
                    result = (rs1 < rs2) ? 32'b1 : 32'b0; //SLT UNSIGNED
                end
                3'b100: begin
                    result = rs1 ^ rs2; //XOR
                end
                3'b101: begin
                    if (funct7 == 7'b0000000) begin
                        result = rs1 >> rs2[4:0]; // SRL
                    end else if (funct7 == 7'b0100000) begin
                        result = $signed(rs1) >>> rs2[4:0]; // SRA
                    end
                end
                3'b110: begin
                    result = rs1 | rs2; //OR
                end
                3'b111: begin
                    result = rs1 & rs2; //AND
                end
                default: begin
                    result = 32'hDEADBEEF; // Error/undefined operation
                end
            endcase
        end
    end

endmodule