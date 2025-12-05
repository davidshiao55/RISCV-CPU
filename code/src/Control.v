module Control (
    input  [6:0] opcode_i,
    input        NoOP_i,          // from hazard detection
    output reg   RegWrite_o,
    output reg   MemtoReg_o,
    output reg   MemRead_o,
    output reg   MemWrite_o,
    output reg [1:0] ALUOp_o,
    output reg   ALUSrc_o,
    output reg   Branch_o
);
    always @(*) begin
        if (NoOP_i) begin
            // Pipeline bubble: disable all side effects
            RegWrite_o = 1'b0;
            MemtoReg_o = 1'b0;
            MemRead_o  = 1'b0;
            MemWrite_o = 1'b0;
            ALUOp_o    = 2'b00;
            ALUSrc_o   = 1'b0;
            Branch_o   = 1'b0;
        end
        else begin
            case (opcode_i)

                // ----------------------------
                // R-type: and, xor, sll, add, sub, mul
                // ----------------------------
                7'b0110011: begin
                    ALUSrc_o   = 1'b0;   // operand from register
                    MemtoReg_o = 1'b0;
                    RegWrite_o = 1'b1;
                    MemRead_o  = 1'b0;
                    MemWrite_o = 1'b0;
                    Branch_o   = 1'b0;
                    ALUOp_o    = 2'b10;  // R-type
                end

                // ----------------------------
                // I-type: addi, srai
                // ----------------------------
                7'b0010011: begin
                    ALUSrc_o   = 1'b1;   // immediate operand
                    MemtoReg_o = 1'b0;
                    RegWrite_o = 1'b1;
                    MemRead_o  = 1'b0;
                    MemWrite_o = 1'b0;
                    Branch_o   = 1'b0;
                    ALUOp_o    = 2'b00;  // let ALU_Control pick addi vs srai by funct3/funct7
                end

                // ----------------------------
                // Load: lw
                // ----------------------------
                7'b0000011: begin
                    ALUSrc_o   = 1'b1;
                    MemtoReg_o = 1'b1;
                    RegWrite_o = 1'b1;
                    MemRead_o  = 1'b1;
                    MemWrite_o = 1'b0;
                    Branch_o   = 1'b0;
                    ALUOp_o    = 2'b00;  // address calc (add)
                end

                // ----------------------------
                // Store: sw
                // ----------------------------
                7'b0100011: begin
                    ALUSrc_o   = 1'b1;
                    MemtoReg_o = 1'b0;
                    RegWrite_o = 1'b0;
                    MemRead_o  = 1'b0;
                    MemWrite_o = 1'b1;
                    Branch_o   = 1'b0;
                    ALUOp_o    = 2'b00;  // address calc (add)
                end

                // ----------------------------
                // Branches: beq / bne
                // ----------------------------
                7'b1100011: begin
                    ALUSrc_o   = 1'b0;
                    MemtoReg_o = 1'b0;
                    RegWrite_o = 1'b0;
                    MemRead_o  = 1'b0;
                    MemWrite_o = 1'b0;
                    Branch_o   = 1'b1;
                    ALUOp_o    = 2'b01;  // branch compare
                end

                // ----------------------------
                // nop
                // ----------------------------
                7'b0000000: begin
                    ALUSrc_o   = 1'b0;
                    MemtoReg_o = 1'b0;
                    RegWrite_o = 1'b0;
                    MemRead_o  = 1'b0;
                    MemWrite_o = 1'b0;
                    Branch_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                end

                // ----------------------------
                // ecall (end of program)
                // ----------------------------
                7'b1110011: begin
                    ALUSrc_o   = 1'b0;
                    MemtoReg_o = 1'b0;
                    RegWrite_o = 1'b0;
                    MemRead_o  = 1'b0;
                    MemWrite_o = 1'b0;
                    Branch_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                end

                // ----------------------------
                // Default / illegal opcode
                // ----------------------------
                default: begin
                    ALUSrc_o   = 1'b0;
                    MemtoReg_o = 1'b0;
                    RegWrite_o = 1'b0;
                    MemRead_o  = 1'b0;
                    MemWrite_o = 1'b0;
                    Branch_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                end
            endcase
        end
    end
endmodule
