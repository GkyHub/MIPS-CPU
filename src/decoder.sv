import MIPS_DEF::*;

module decoder(
    input   [32 -1 : 0] ins,
    input   [32 -1 : 0] pc,             // we only use the high 4 bit of pc

    output      [5  -1 : 0] rd_addr_a,
    output      [5  -1 : 0] rd_addr_b,
    output  reg [5  -1 : 0] wr_addr,
    output  reg             reg_wr,
    output  reg             mem_rd,
    output  reg             mem_wr,
    output  reg aluop_t     aluop,
    output  reg             sign,       // 1: signed operator
                                        // 0: unsigned operator

    output  reg [32 -1 : 0] ext_imm,    // extended immediate data
                                        // shamt for shift operation
    output  reg             use_imm,    // if ALU use immediate data

    output                  jump,       // if unconditional jump in ID
    output      [32 -1 : 0] jump_pc,    // jump target
    output  reg [2  -1 : 0] branch      // branch type in EX stage:
                                        // 00: no branch
                                        // 01: jr
                                        // 10: beq
                                        // 11: bne
    );

    wire    [6  -1 : 0] opcode;
    wire    [5  -1 : 0] rs, rt, rd, shamt;
    wire    [6  -1 : 0] func;
    wire    [16 -1 : 0] imm;

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
        FUNC_SLL : func_alu_op = ALU_SL;
        FUNC_SRL : func_alu_op = ALU_SR;
        FUNC_SRA : func_alu_op = ALU_SR;
        FUNC_SLLV: func_alu_op = ALU_SL;
        FUNC_SRLV: func_alu_op = ALU_SR;
        FUNC_SRAV: func_alu_op = ALU_SR;
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

    // sign signal (only for compare and shift right)
    always_comb begin
        case (opcode)
        OP_RTYPE: begin
            case (func)
            FUNC_SLT:  sign = 1'b1;
            FUNC_SLTU: sign = 1'b0;
            FUNC_SRL:  sign = 1'b0;
            FUNC_SRLV: sign = 1'b0;
            FUNC_SRA:  sign = 1'b1;
            FUNC_SRAV: sign = 1'b1;
            default:   sign = 1'bx;
            endcase
        end
        OP_SLTI:  sign = 1'b1;
        OP_SLTIU: sign = 1'b0;
        default:  sign = 1'bx;
        endcase
    end

    // extend immediate data
    always_comb begin
        unique case(opcode)
        OP_RTYPE: ext_imm = {27'd0, shamt};
        OP_ADDI:  ext_imm = {{16{imm[15]}}, imm};
        OP_ADDIU: ext_imm = {{16{imm[15]}}, imm};
        OP_ORI:   ext_imm = {16'd0, imm};
        OP_XORI:  ext_imm = {16'd0, imm};
        OP_LUI:   ext_imm = {imm, 16'd0};
        OP_LW:    ext_imm = {{16{imm[15]}}, imm};
        OP_SW:    ext_imm = {{16{imm[15]}}, imm};
        OP_BEQ:   ext_imm = ALU_XOR;
        OP_BNE:   ext_imm = ALU_XOR;
        OP_SLTI:  ext_imm = {{16{imm[15]}}, imm};
        OP_SLTIU: ext_imm = {{16{imm[15]}}, imm};
        OP_J:     ext_imm = 'bx;
        OP_JAL:   ext_imm = 'bx;
        endcase
    end

    // judge if immediate data is used
    always_comb begin
        if (opcode == OP_RTYPE) begin
            use_imm = (func[5:4] == 2'b00);
        end
        else begin
            use_imm = !((opcode == OP_J) || (opcode == OP_JAL));
        end
    end

    // judge if jump
    assign jump = (opcode == OP_J) || (opcode == OP_JAL);

    // get the jump target
    assign jump_pc = {pc[31:28], addr, 2'b00};

    // judge if branch on EX stage
    always_comb begin
        case(opcode)
        OP_RTYPE: branch = (func == FUNC_JR) ? 2'b01 : 2'b00;
        OP_BEQ:   branch = 2'b10;
        OP_BNE:   branch = 2'b11;
        default:  branch = 2'b00;
        endcase
    end

endmodule