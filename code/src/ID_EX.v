module ID_EX (
    input clk_i,
    input rst_i,
    input RegWrite_i,
    input MemtoReg_i,
    input MemRead_i,
    input MemWrite_i,
    input [1:0] ALUOp_i,
    input ALUSrc_i,
    input [31:0] RS1data_i,
    input [31:0] RS2data_i,
    input [31:0] imm_i,
    input [2:0] funct3_i,
    input [6:0] funct7_i,
    input [4:0] RS1addr_i,
    input [4:0] RS2addr_i,
    input [4:0] RDaddr_i,
    output reg RegWrite_o,
    output reg MemtoReg_o,
    output reg MemRead_o,
    output reg MemWrite_o,
    output reg [1:0] ALUOp_o,
    output reg ALUSrc_o,
    output reg [31:0] RS1data_o,
    output reg [31:0] RS2data_o,
    output reg [31:0] imm_o,
    output reg [2:0] funct3_o,
    output reg [6:0] funct7_o,
    output reg [4:0] RS1addr_o,
    output reg [4:0] RS2addr_o,
    output reg [4:0] RDaddr_o
);
    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) begin
            RegWrite_o <= 1'b0;
            MemtoReg_o <= 1'b0;
            MemRead_o <= 1'b0;
            MemWrite_o <= 1'b0;
            ALUOp_o <= 2'b0;
            ALUSrc_o <= 1'b0;
            RS1data_o <= 32'b0;
            RS2data_o <= 32'b0;
            imm_o <= 32'b0;
            funct3_o <= 3'b0;
            funct7_o <= 7'b0;
            RS1addr_o <= 5'b0;
            RS2addr_o <= 5'b0;
            RDaddr_o <= 5'b0;
        end
        else begin
            RegWrite_o <= RegWrite_i;
            MemtoReg_o <= MemtoReg_i;
            MemRead_o <= MemRead_i;
            MemWrite_o <= MemWrite_i;
            ALUOp_o <= ALUOp_i;
            ALUSrc_o <= ALUSrc_i;
            RS1data_o <= RS1data_i;
            RS2data_o <= RS2data_i;
            imm_o <= imm_i;
            funct3_o <= funct3_i;
            funct7_o <= funct7_i;
            RS1addr_o <= RS1addr_i;
            RS2addr_o <= RS2addr_i;
            RDaddr_o <= RDaddr_i;
        end
    end 
endmodule