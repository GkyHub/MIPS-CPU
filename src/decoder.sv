import MIPS_DEF::*;

module decoder(
    input   [32 -1 : 0] ins,

    output      [5  -1 : 0] rd_addr_a,
    output      [5  -1 : 0] rd_addr_b,
    output  reg [5  -1 : 0] wr_addr,
    output  reg             reg_wr,
    output  reg             mem_rd,
    output  reg             mem_wr,
    output  reg             branch,
    output  reg aluop_t     aluop,
    output  reg             sign,

    output      [5  -1 : 0] shamt,
    output      [16 -1 : 0] imm,        // immediate data
    output      [26 -1 : 0] addr        // jump address
    );

    wire    [6  -1 : 0] opcode;
    wire    [5  -1 : 0] rs, rt, rd;
    wire    [6  -1 : 0] func;

    // disassembles members of instruction
    assign  {opcode, rs, rt, rd, shamt, func} = ins;
    assign  imm  = ins[15: 0];
    assign  addr = ins[25: 0];

    // generate control signals

    // read address
    assign  rd_addr_a = rs;
    assign  rd_addr_b = rt;

    // write address and enable
    always_comb begin
        unique case(opcode)
        OP_RTYPE: begin wr_addr = rd;    reg_wr = 1'b1; end
        OP_ADDI:  begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_ADDIU: begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_ORI:   begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_XORI:  begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_LUI:   begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_LW:    begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_SW:    begin wr_addr = 'bx;   reg_wr = 1'b0; end
        OP_BEQ:   begin wr_addr = 'bx;   reg_wr = 1'b0; end
        OP_BNE:   begin wr_addr = 'bx;   reg_wr = 1'b0; end
        OP_SLTI:  begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_SLTIU: begin wr_addr = rt;    reg_wr = 1'b1; end
        OP_J:     begin wr_addr = 'bx;   reg_wr = 1'b0; end
        OP_JAL:   begin wr_addr = 5'd31; reg_wr = 1'b1; end
        endcase 
    end

    // memory read and write enable
    always_comb begin
        unique case(opcode)
        OP_RTYPE: begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_ADDI:  begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_ADDIU: begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_ORI:   begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_XORI:  begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_LUI:   begin mem_wr = 1'b0; mem_rd = 1'b1; end
        OP_LW:    begin mem_wr = 1'b0; mem_rd = 1'b1; end
        OP_SW:    begin mem_wr = 1'b1; mem_rd = 1'b0; end
        OP_BEQ:   begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_BNE:   begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_SLTI:  begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_SLTIU: begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_J:     begin mem_wr = 1'b0; mem_rd = 1'b0; end
        OP_JAL:   begin mem_wr = 1'b0; mem_rd = 1'b0; end
        endcase 
    end

    // alu control signals
    wire    aluop_t func_alu_op;

    always_comb begin
        unique case (func)
        FUNC_ADD : func_alu_op = ALU_ADD;
        FUNC_ADDU: func_alu_op = ALU_ADD;
        FUNC_SUB : func_alu_op = ALU_SUB;
        FUNC_SUBU: func_alu_op = ALU_SUB;
        FUNC_AND : func_alu_op = ALU_AND;
        FUNC_OR  : func_alu_op = ALU_OR;
        FUNC_XOR : func_alu_op = ALU_XOR;
        FUNC_NOR : func_alu_op = ALU_NOR;
        FUNC_SLT : func_alu_op = ALU_CMP;
        FUNC_SLTU: func_alu_op = ALU_CMP;
        FUNC_SLL : func_alu_op = ALU_SLL;
        FUNC_SRL : func_alu_op = ALU_SRL;
        FUNC_SRA : func_alu_op = ALU_SRA;
        FUNC_SLLV: func_alu_op = ALU_SLL;
        FUNC_SRLV: func_alu_op = ALU_SRL;
        FUNC_SRAV: func_alu_op = ALU_SRA;
        FUNC_JR  : func_alu_op = 'bx;
        endcase
    end

    always_comb begin
        unique case (opcode)
        OP_RTYPE: aluop = func_alu_op;
        OP_ADDI:  aluop = ALU_ADD;
        OP_ADDIU: aluop = ALU_ADD;
        OP_ORI:   aluop = ALU_OR;
        OP_XORI:  aluop = ALU_XOR;
        OP_LUI:   aluop = ALU_ADD;
        OP_LW:    aluop = ALU_ADD;
        OP_SW:    aluop = ALU_ADD;
        OP_BEQ:   aluop = ALU_XOR;
        OP_BNE:   aluop = ALU_XOR;
        OP_SLTI:  aluop = ALU_CMP;
        OP_SLTIU: aluop = ALU_CMP;
        OP_J:     aluop = 'bx;
        OP_JAL:   aluop = 'bx;
        endcase
    end

    // sign signal (only for compare)
    always_comb begin
        case (opcode)
        OP_RTYPE: begin
            case (func)
            FUNC_SLT:  sign = 1'b1;
            FUNC_SLTU: sign = 1'b0;
            endcase
        end
        OP_SLTI:  sign = 1'b1;
        OP_SLTIU: sign = 1'b0;
        default:  sign = 1'bx;
        endcase
    end

endmodule