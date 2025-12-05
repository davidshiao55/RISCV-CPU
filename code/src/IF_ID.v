module IF_ID (
    input clk_i,
    input rst_i,
    input stall_i,
    input flush_i,
    input [31:0] pc_i,
    input [31:0] instr_i,
    output reg [31:0] pc_o,
    output reg [31:0] instr_o
);
    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) begin
            instr_o <= 32'b0;
            pc_o <= 32'b0;
        end
        else if (flush_i) begin
            instr_o <= 32'b0;
            pc_o <= 32'b0;
        end
        else if (~stall_i) begin
            pc_o <= pc_i;
            instr_o <= instr_i;
        end
    end
endmodule