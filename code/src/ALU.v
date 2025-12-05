module ALU (
    input [31:0] ALUin1_i,
    input [31:0] ALUin2_i,
    input [2:0] ALUCtrl_i,
    output reg [31:0] ALUResult_o
);
    always @(*) begin
        case (ALUCtrl_i)
            3'b000: ALUResult_o = ALUin1_i & ALUin2_i; // and
            3'b001: ALUResult_o = ALUin1_i ^ ALUin2_i; // xor
            3'b010: ALUResult_o = ALUin1_i + ALUin2_i; // add & addi
            3'b011: ALUResult_o = ALUin1_i - ALUin2_i; // sub
            3'b100: ALUResult_o = ALUin1_i << ALUin2_i;  // sll
            3'b101: ALUResult_o = ALUin1_i * ALUin2_i; // mul
            3'b110: ALUResult_o = ALUin1_i >>> ALUin2_i[4:0]; // srai (arithmetic shift)
            default: ALUResult_o = 0;
        endcase
    end
endmodule