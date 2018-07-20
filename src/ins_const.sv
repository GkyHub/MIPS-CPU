package MIPS_DEF;
    localparam NOP  = 32'h0000_0000;

    // opcode definition
    localparam OP_RTYPE = 6'b000000;
    localparam OP_ADDI  = 6'b001000;
    localparam OP_ADDIU = 6'b001001;
    localparam OP_ORI   = 6'b001101;
    localparam OP_XORI  = 6'b001110;
    localparam OP_LUI   = 6'b001111;
    localparam OP_LW    = 6'b100011;
    localparam OP_SW    = 6'b101011;
    localparam OP_BEQ   = 6'b000100;
    localparam OP_BNE   = 6'b000101;
    localparam OP_SLTI  = 6'b001010;
    localparam OP_SLTIU = 6'b001011;
    localparam OP_J     = 6'b000010;
    localparam OP_JAL   = 6'b000011;

    // function code definition for R type
    localparam FUNC_ADD     = 6'b100000;
    localparam FUNC_ADDU    = 6'b100001;
    localparam FUNC_SUB     = 6'b100010;
    localparam FUNC_SUBU    = 6'b100011;
    localparam FUNC_AND     = 6'b100100;
    localparam FUNC_OR      = 6'b100101;
    localparam FUNC_XOR     = 6'b100110;
    localparam FUNC_NOR     = 6'b100111;
    localparam FUNC_SLT     = 6'b101010;
    localparam FUNC_SLTU    = 6'b101011;
    localparam FUNC_SLL     = 6'b000000;
    localparam FUNC_SRL     = 6'b000010;
    localparam FUNC_SRA     = 6'b000011;
    localparam FUNC_SLLV    = 6'b000100;
    localparam FUNC_SRLV    = 6'b000110;
    localparam FUNC_SRAV    = 6'b000111;
    localparam FUNC_JR      = 6'b001000;

    // alu function code
    typedef enum {
        ALU_ADD,
        ALU_SUB,
        ALU_CMP,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_NOR,
        ALU_SL,
        ALU_SR,
    } aluop_t;
    

endpackage