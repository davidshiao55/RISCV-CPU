module Forwarding (
    input [4:0] RS1addr_EX_i,
    input [4:0] RS2addr_EX_i,
    input [4:0] RDaddr_MEM_i,
    input RegWrite_MEM_i,
    input [4:0] RDaddr_WB_i,
    input RegWrite_WB_i,
    output reg [1:0] ForwardA_o,
    output reg [1:0] ForwardB_o
);
    always @(*) begin
        // Default: no forwarding
        ForwardA_o = 2'b00;
        ForwardB_o = 2'b00;

        // EX hazard
        if (RegWrite_MEM_i && (RDaddr_MEM_i != 0) && (RDaddr_MEM_i == RS1addr_EX_i))
            ForwardA_o = 2'b10;
        if (RegWrite_MEM_i && (RDaddr_MEM_i != 0) && (RDaddr_MEM_i == RS2addr_EX_i))
            ForwardB_o = 2'b10;

        // MEM hazard 
        if (RegWrite_WB_i && (RDaddr_WB_i != 0) &&
            !(RegWrite_MEM_i && (RDaddr_MEM_i != 0) && (RDaddr_MEM_i == RS1addr_EX_i)) &&
            (RDaddr_WB_i == RS1addr_EX_i))
            ForwardA_o = 2'b01;

        if (RegWrite_WB_i && (RDaddr_WB_i != 0) &&
            !(RegWrite_MEM_i && (RDaddr_MEM_i != 0) && (RDaddr_MEM_i == RS2addr_EX_i)) &&
            (RDaddr_WB_i == RS2addr_EX_i))
            ForwardB_o = 2'b01;
    end
endmodule
