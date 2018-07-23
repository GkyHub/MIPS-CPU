package MIPS_DEF;
    localparam NOP  = 32'h0000_0000;

    // opcode definition
    localparam OP_RTYPE = 6'b000000;    // r type instruction
    localparam OP_ADDI  = 6'b001000;    // add signed immediate
    localparam OP_ADDIU = 6'b001001;    // add signed immediate without overflow
    localparam OP_ORI   = 6'b001101;    // or immediate
    localparam OP_XORI  = 6'b001110;    // exclusive or immediate
    localparam OP_LUI   = 6'b001111;    // load upper half word
    localparam OP_LW    = 6'b100011;    // load word
    localparam OP_SW    = 6'b101011;    // save word
    localparam OP_BEQ   = 6'b000100;    // branch if equal
    localparam OP_BNE   = 6'b000101;    // branch if not equal
    localparam OP_SLTI  = 6'b001010;    // set less than immediate
    localparam OP_SLTIU = 6'b001011;    // set less than unsigned immediate
    localparam OP_J     = 6'b000010;    // jump
    localparam OP_JAL   = 6'b000011;    // jump and link

    // function code definition for R type
    localparam FUNC_ADD     = 6'b100000;    // add
    localparam FUNC_ADDU    = 6'b100001;    // add without overflow
    localparam FUNC_SUB     = 6'b100010;    // sub
    localparam FUNC_SUBU    = 6'b100011;    // sub withour overflow
    localparam FUNC_AND     = 6'b100100;    // and
    localparam FUNC_OR      = 6'b100101;    // or
    localparam FUNC_XOR     = 6'b100110;    // exclusive or
    localparam FUNC_NOR     = 6'b100111;    // not or
    localparam FUNC_SLT     = 6'b101010;    // set less than
    localparam FUNC_SLTU    = 6'b101011;    // set less than unsigned
    localparam FUNC_SLL     = 6'b000000;    // logic shift left
    localparam FUNC_SRL     = 6'b000010;    // logic shift right
    localparam FUNC_SRA     = 6'b000011;    // arithmatic shift right
    localparam FUNC_SLLV    = 6'b000100;    // logic shift left with register
    localparam FUNC_SRLV    = 6'b000110;    // logic shift right with register
    localparam FUNC_SRAV    = 6'b000111;    // arithmatic shift right with register
    localparam FUNC_JR      = 6'b001000;    // jump register

    // register id definition
    localparam ZERO = 0;
    localparam AT   = 1;
    localparam V0   = 2;
    localparam V1   = 3;
    localparam A0   = 4;
    localparam A1   = 5;
    localparam A2   = 6;
    localparam A3   = 7;
    localparam T0   = 8;
    localparam T1   = 9;
    localparam T2   = 10;
    localparam T3   = 11;
    localparam T4   = 12;
    localparam T5   = 13;
    localparam T6   = 14;
    localparam T7   = 15;
    localparam T8   = 16;
    localparam T9   = 17;
    localparam S0   = 18;
    localparam S1   = 19;
    localparam S2   = 20;
    localparam S3   = 21;
    localparam S4   = 22;
    localparam S5   = 23;
    localparam S6   = 24;
    localparam S7   = 25;
    localparam K0   = 26;
    localparam K1   = 27;
    localparam GP   = 28;
    localparam SP   = 29;
    localparam FP   = 30;
    localparam RA   = 31;

    // alu function code for hardware
    // to be decided by synthesis tools
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