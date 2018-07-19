import MIPS_DEF::*;

module decoder(
    input   [32 -1 : 0] ins,

    output  [5  -1 : 0] rd_addr_a,
    output  [5  -1 : 0] rd_addr_b,
    output  [5  -1 : 0] wr_addr,
    output              reg_wr,
    output              mem_rd,
    output              mem_wr,
    output              branch,

    output  [16 -1 : 0] imm,
    output  [26 -1 : 0] addr
    );

    wire    [6  -1 : 0] opcode;
    wire    [5  -1 : 0] rs, rt, rd;
    wire    [5  -1 : 0] shamt;
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

    // branch
    assign  branch = 



endmodule