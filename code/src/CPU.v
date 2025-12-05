module CPU
(
    input clk_i,
    input rst_n
);

// ---------------------------------------------------------------------
// Pipeline control signals
// ---------------------------------------------------------------------
wire ID_Stall;        // Hazard detection
wire ID_FlushIF;      // For branch flush

// ---------------------------------------------------------------------
// IF stage wires
// ---------------------------------------------------------------------
wire [31:0] pc_i, pc_o, pc_next, pc_branch;
wire [31:0] instr_IF, instr_ID;
wire [31:0] pc_ID;

// ---------------------------------------------------------------------
// ID stage wires
// ---------------------------------------------------------------------
wire [6:0] opcode_ID;
wire [2:0] funct3_ID, funct3_EX;
wire [6:0] funct7_ID, funct7_EX;
wire [4:0] RS1addr_ID, RS2addr_ID, RDaddr_ID;
wire [31:0] RS1data_ID, RS2data_ID;
wire [31:0] imm_ID;
wire [1:0] ALUOp_ID;
wire RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID, ALUSrc_ID, Branch_ID;

// ---------------------------------------------------------------------
// EX stage wires
// ---------------------------------------------------------------------
wire [4:0] RS1addr_EX, RS2addr_EX, RDaddr_EX;
wire [31:0] RS1data_EX, RS2data_EX, imm_EX;
wire [1:0] ALUOp_EX;
wire RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, ALUSrc_EX;
wire [2:0] ALUCtrl_EX;
wire [31:0] ALUin1_EX, ALUin2_EX, ALUinB_EX;
wire [31:0] ALUResult_EX;
wire [1:0] ForwardA, ForwardB;

// ---------------------------------------------------------------------
// MEM stage wires
// ---------------------------------------------------------------------
wire [4:0] RDaddr_MEM;
wire [31:0] ALUResult_MEM, ALUinB_MEM, ReadData_MEM;
wire RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM;

// ---------------------------------------------------------------------
// WB stage wires
// ---------------------------------------------------------------------
wire [4:0] RDaddr_WB;
wire [31:0] ALUResult_WB, ReadData_WB, WriteData_WB;
wire RegWrite_WB, MemtoReg_WB;

// ---------------------------------------------------------------------
// Hazard control signals
// ---------------------------------------------------------------------
wire Stall, Flush, PCWrite, NoOP;

// =====================================================================
//  IF STAGE
// =====================================================================

// Select between sequential PC or branch target
MUX32 u_MUX_PCSrc(
    .data1_i(pc_next),
    .data2_i(pc_branch),
    .select_i(Flush),
    .data_o(pc_i)
);

// Add 4 to current PC
Adder u_Add_PC(
    .a(pc_o),
    .b(32'd4),
    .c(pc_next)
);

// Program Counter
PC u_PC(
    .rst_n(rst_n),
    .clk_i(clk_i),
    .PCWrite_i(PCWrite),
    .pc_i(pc_i),
    .pc_o(pc_o)
);

// Instruction Memory
Instruction_Memory u_Instruction_Memory(
    .addr_i(pc_o),
    .instr_o(instr_IF)
);

// IF/ID Pipeline Register
IF_ID u_IF_ID(
    .clk_i(clk_i),
    .rst_i(rst_n),
    .stall_i(ID_Stall),
    .flush_i(Flush),
    .pc_i(pc_o),
    .instr_i(instr_IF),
    .pc_o(pc_ID),
    .instr_o(instr_ID)
);


// =====================================================================
//  ID STAGE
// =====================================================================
assign opcode_ID = instr_ID[6:0];
assign funct3_ID = instr_ID[14:12];
assign funct7_ID = instr_ID[31:25];
assign RS1addr_ID = instr_ID[19:15];
assign RS2addr_ID = instr_ID[24:20];
assign RDaddr_ID  = instr_ID[11:7];

// Hazard Detection Unit
Hazard_Detection u_Hazard_Detection(
    .MemRead_EX_i(MemRead_EX),
    .RDaddr_EX_i(RDaddr_EX),
    .RS1addr_ID_i(RS1addr_ID),
    .RS2addr_ID_i(RS2addr_ID),
    .Stall_o(ID_Stall),
    .PCWrite_o(PCWrite),
    .NoOP_o(NoOP)
);

// Control Unit
Control u_Control(
    .opcode_i(opcode_ID),
    .NoOP_i(NoOP),
    .RegWrite_o(RegWrite_ID),
    .MemtoReg_o(MemtoReg_ID),
    .MemRead_o(MemRead_ID),
    .MemWrite_o(MemWrite_ID),
    .ALUOp_o(ALUOp_ID),
    .ALUSrc_o(ALUSrc_ID),
    .Branch_o(Branch_ID)
);

// Register File
Registers u_Registers(
    .rst_n(rst_n),
    .clk_i(clk_i),
    .RS1addr_i(RS1addr_ID),
    .RS2addr_i(RS2addr_ID),
    .RDaddr_i(RDaddr_WB),
    .RDdata_i(WriteData_WB),
    .RegWrite_i(RegWrite_WB),
    .RS1data_o(RS1data_ID),
    .RS2data_o(RS2data_ID)
);

// Immediate Generation
Sign_Extend u_Sign_Extend(
    .instr_i(instr_ID),
    .imm_o(imm_ID)
);

// Branch Flush Condition
assign Flush = Branch_ID & (
    (funct3_ID == 3'b000 && (RS1data_ID == RS2data_ID)) || // BEQ
    (funct3_ID == 3'b001 && (RS1data_ID != RS2data_ID))    // BNE
);
assign ID_FlushIF = Flush;

// Branch Address Calculation
Adder u_Add_Branch(
    .a(pc_ID),
    .b(imm_ID),
    .c(pc_branch)
);

// ID/EX Pipeline Register
ID_EX u_ID_EX(
    .clk_i(clk_i),
    .rst_i(rst_n),
    .RegWrite_i(RegWrite_ID),
    .MemtoReg_i(MemtoReg_ID),
    .MemRead_i(MemRead_ID),
    .MemWrite_i(MemWrite_ID),
    .ALUOp_i(ALUOp_ID),
    .ALUSrc_i(ALUSrc_ID),
    .RS1data_i(RS1data_ID),
    .RS2data_i(RS2data_ID),
    .imm_i(imm_ID),
    .funct3_i(funct3_ID),
    .funct7_i(funct7_ID),
    .RS1addr_i(RS1addr_ID),
    .RS2addr_i(RS2addr_ID),
    .RDaddr_i(RDaddr_ID),
    .RegWrite_o(RegWrite_EX),
    .MemtoReg_o(MemtoReg_EX),
    .MemRead_o(MemRead_EX),
    .MemWrite_o(MemWrite_EX),
    .ALUOp_o(ALUOp_EX),
    .ALUSrc_o(ALUSrc_EX),
    .RS1data_o(RS1data_EX),
    .RS2data_o(RS2data_EX),
    .imm_o(imm_EX),
    .funct3_o(funct3_EX),
    .funct7_o(funct7_EX),
    .RS1addr_o(RS1addr_EX),
    .RS2addr_o(RS2addr_EX),
    .RDaddr_o(RDaddr_EX)
);


// =====================================================================
//  EX STAGE
// =====================================================================

// Forwarding Unit
Forwarding u_Forwarding(
    .RS1addr_EX_i(RS1addr_EX),
    .RS2addr_EX_i(RS2addr_EX),
    .RDaddr_MEM_i(RDaddr_MEM),
    .RegWrite_MEM_i(RegWrite_MEM),
    .RDaddr_WB_i(RDaddr_WB),
    .RegWrite_WB_i(RegWrite_WB),
    .ForwardA_o(ForwardA),
    .ForwardB_o(ForwardB)
);

// Forwarding MUX for ALU inputs
MUX4 u_MUX_ALUSrc1(
    .data1_i(RS1data_EX),
    .data2_i(WriteData_WB),
    .data3_i(ALUResult_MEM),
    .data4_i(32'b0),
    .select_i(ForwardA),
    .data_o(ALUin1_EX)
);

MUX4 u_MUX_ALUSrc2(
    .data1_i(RS2data_EX),
    .data2_i(WriteData_WB),
    .data3_i(ALUResult_MEM),
    .data4_i(32'b0),
    .select_i(ForwardB),
    .data_o(ALUinB_EX)
);

// Select between register and immediate
MUX32 u_MUX_ALUSrc(
    .data1_i(ALUinB_EX),
    .data2_i(imm_EX),
    .select_i(ALUSrc_EX),
    .data_o(ALUin2_EX)
);

// ALU Control
ALU_Control u_ALU_Control(
    .ALUOp_i(ALUOp_EX),
    .funct7_i(funct7_EX),
    .funct3_i(funct3_EX),
    .ALUCtrl_o(ALUCtrl_EX)
);

// ALU
ALU u_ALU(
    .ALUin1_i(ALUin1_EX),
    .ALUin2_i(ALUin2_EX),
    .ALUCtrl_i(ALUCtrl_EX),
    .ALUResult_o(ALUResult_EX)
);

// EX/MEM Pipeline Register
EX_MEM u_EX_MEM(
    .clk_i(clk_i),
    .rst_i(rst_n),
    .RegWrite_i(RegWrite_EX),
    .MemtoReg_i(MemtoReg_EX),
    .MemRead_i(MemRead_EX),
    .MemWrite_i(MemWrite_EX),
    .ALUResult_i(ALUResult_EX),
    .ALUinB_i(ALUinB_EX),
    .RDaddr_i(RDaddr_EX),
    .RegWrite_o(RegWrite_MEM),
    .MemtoReg_o(MemtoReg_MEM),
    .MemRead_o(MemRead_MEM),
    .MemWrite_o(MemWrite_MEM),
    .ALUResult_o(ALUResult_MEM),
    .ALUinB_o(ALUinB_MEM),
    .RDaddr_o(RDaddr_MEM)
);


// =====================================================================
//  MEM STAGE
// =====================================================================

Data_Memory u_Data_Memory(
    .clk_i(clk_i),
    .addr_i(ALUResult_MEM),
    .MemRead_i(MemRead_MEM),
    .MemWrite_i(MemWrite_MEM),
    .data_i(ALUinB_MEM),
    .data_o(ReadData_MEM)
);

MEM_WB u_MEM_WB(
    .clk_i(clk_i),
    .rst_i(rst_n),
    .RegWrite_i(RegWrite_MEM),
    .MemtoReg_i(MemtoReg_MEM),
    .ALUResult_i(ALUResult_MEM),
    .ReadData_i(ReadData_MEM),
    .RDaddr_i(RDaddr_MEM),
    .RegWrite_o(RegWrite_WB),
    .MemtoReg_o(MemtoReg_WB),
    .ALUResult_o(ALUResult_WB),
    .ReadData_o(ReadData_WB),
    .RDaddr_o(RDaddr_WB)
);


// =====================================================================
//  WB STAGE
// =====================================================================

MUX32 u_MUX_WBSrc(
    .data1_i(ALUResult_WB),
    .data2_i(ReadData_WB),
    .select_i(MemtoReg_WB),
    .data_o(WriteData_WB)
);

endmodule
