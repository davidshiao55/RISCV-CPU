module Hazard_Detection (
    input MemRead_EX_i,
    input [4:0] RDaddr_EX_i,
    input [4:0] RS1addr_ID_i,
    input [4:0] RS2addr_ID_i,
    output reg Stall_o,
    output reg PCWrite_o,
    output reg NoOP_o
);
    always @(*) begin
        // Default: normal operation
        Stall_o   = 1'b0;
        PCWrite_o = 1'b1;
        NoOP_o    = 1'b0;

        // Load-use hazard detection
        if (MemRead_EX_i &&
           ((RDaddr_EX_i == RS1addr_ID_i) || (RDaddr_EX_i == RS2addr_ID_i))) begin
            Stall_o   = 1'b1;  // freeze IF/ID
            PCWrite_o = 1'b0;  // freeze PC
            NoOP_o    = 1'b1;  // inject NOP into ID stage
        end
    end
endmodule
