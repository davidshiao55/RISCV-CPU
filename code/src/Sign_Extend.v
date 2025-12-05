module Sign_Extend (
    input  [31:0] instr_i,   // full instruction from ID stage
    output reg [31:0] imm_o  // sign-extended immediate
);

    wire [6:0] opcode;
    assign opcode = instr_i[6:0];

    always @(*) begin
        case (opcode)

            // ------------------------------------------------------------
            // I-type (addi, srai, lw)
            // imm[11:0] = instr[31:20]
            // ------------------------------------------------------------
            7'b0010011,   // addi / srai
            7'b0000011:   // lw
                imm_o = {{20{instr_i[31]}}, instr_i[31:20]};

            // ------------------------------------------------------------
            // S-type (sw)
            // imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            // ------------------------------------------------------------
            7'b0100011:   // sw
                imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};

            // ------------------------------------------------------------
            // B-type (beq, bne)
            // imm[12|10:5|4:1|11|0] = instr[31|30:25|11:8|7|0]
            // The result is shifted left by 1 (LSB is zero)
            // ------------------------------------------------------------
            7'b1100011:   // beq, bne
                imm_o = {{19{instr_i[31]}},
                          instr_i[31],
                          instr_i[7],
                          instr_i[30:25],
                          instr_i[11:8],
                          1'b0};

            // ------------------------------------------------------------
            // Default (R-type, nop, ecall, invalid)
            // ------------------------------------------------------------
            default:
                imm_o = 32'b0;
        endcase
    end
endmodule
