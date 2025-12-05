module ALU_Control (
    input  [1:0] ALUOp_i,
    input  [6:0] funct7_i,
    input  [2:0] funct3_i,
    output reg [2:0] ALUCtrl_o
);
    always @(*) begin
        case (ALUOp_i)
            // ALUOp = 00 → LW, SW, ADDI, SRAI
            2'b00: begin
                case (funct3_i)
                    3'b000: ALUCtrl_o = 3'b010; // add / addi
                    3'b101: begin
                        if (funct7_i == 7'b0100000)
                            ALUCtrl_o = 3'b110; // srai
                        else
                            ALUCtrl_o = 3'b010; // default to add if funct7 doesn’t match
                    end
                    default: ALUCtrl_o = 3'b010; // default add
                endcase
            end

            // ALUOp = 01 → Branch (sub)
            2'b01: ALUCtrl_o = 3'b011;

            // ALUOp = 10 → R-type: add, sub, and, xor, sll, mul
            2'b10: begin
                case ({funct7_i, funct3_i})
                    10'b0000000_000: ALUCtrl_o = 3'b010; // add
                    10'b0100000_000: ALUCtrl_o = 3'b011; // sub
                    10'b0000000_111: ALUCtrl_o = 3'b000; // and
                    10'b0000000_100: ALUCtrl_o = 3'b001; // xor
                    10'b0000000_001: ALUCtrl_o = 3'b100; // sll
                    10'b0000001_000: ALUCtrl_o = 3'b101; // mul
                    default: ALUCtrl_o = 3'b010; // default add
                endcase
            end

            default: ALUCtrl_o = 3'b010;
        endcase
    end
endmodule
