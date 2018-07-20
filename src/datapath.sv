import  MIPS_DEF::*;

module datapath (
    input   clk,
    input   rst_n,

    // PC read port
    output  [32 -1 : 0] pc,
    input   [32 -1 : 0] ins,

    // memory port
    output  [32 -1 : 0] mem_addr,
    input   [32 -1 : 0] mem_data,
    output              mem_rd,
    output              mem_wr
    );

    // register definitions
    reg     [32 -1 : 0] pc_r;
    // IF registers
    reg     [32 -1 : 0] IF_ins_r;
    // ID registers
    reg     [32 -1 : 0] ID_op_a_r, ID_op_b_r;
    reg     [5  -1 : 0] ID_rd_addr_a_r, ID_rd_addr_b_r;
    reg     [5  -1 : 0] ID_wr_addr_r;
    reg                 ID_wr_en_r;
    reg                 ID_mem_wr_r;
    reg                 ID_mem_rd_r;
    reg     [32 -1 : 0] ID_imm_r;
    reg     [2  -1 : 0] ID_func_sel_r;
    reg     [2  -1 : 0] ID_logic_ctrl_r;
    reg     [2  -1 : 0] ID_shift_ctrl_r;
    reg     [2  -1 : 0] ID_arith_ctrl_r;
    // EX registers
    reg     [5  -1 : 0] EX_rd_addr_a_r, EX_rd_addr_b_r;
    reg     [5  -1 : 0] EX_wr_addr_r;
    reg                 EX_wr_en_r;
    reg                 EX_mem_wr_r;
    reg                 EX_mem_rd_r;
    // MEM registers
    reg                 MEM_wr_en_r;
    reg     [5  -1 : 0] MEM_wr_addr_r;
    reg     [32 -1 : 0] MEM_mem_data_r;
    reg     [32 -1 : 0] MEM_alu_data_r;

    // WB registers (none)

//=============================================================================
// IF stage
//=============================================================================

    always @ (posedge clk) begin
        if (~rst) begin
            IF_ins_r <= NOP;
        end
        else begin
            IF_ins_r <= ins;
        end
    end

//=============================================================================
// ID stage
//=============================================================================

    reg     [32 -1 : 0] reg_file[31:1];         // register file
    wire    [5  -1 : 0] ID_rd_addr_a, ID_rd_addr_b;   // register read address
    wire    [5  -1 : 0] wr_addr;                // register write address
    wire    sign_ext;

    // decode instruction

    // read operators from registers
    always @ (posedge clk) begin
        if (ID_rd_addr_a == 5'd0) begin
            ID_op_a_r <= 32'd0;
        end
        else begin
            ID_op_a_r <= reg_file[ID_rd_addr_a];
        end

        if (ID_rd_addr_b == 5'd0) begin
            ID_op_b_r <= 32'd0;
        end
        else begin
            ID_op_b_r <= reg_file[ID_rd_addr_b];
        end
    end    

    // extend immediate number
    wire    [16 -1 : 0] imm = IF_ins_r[`IMM];
    always @ (posedge clk) begin
        ID_imm_r[15: 0] <= imm;
        ID_imm_r[31:16] <= {16{sign_ext & imm[15]}};
    end

//=============================================================================
// EX stage
//=============================================================================
    wire    [32 -1 : 0] EX_op_a, EX_op_b;
    wire    [32 -1 : 0] EX_c;
    wire    EX_overflow, EX_equal;

    // select input
    always_comb begin

    end

    // ALU operation
    alu alu_inst(
        .func_sel   (ID_func_sel_r  ),
        .logic_ctrl (ID_logic_ctrl_r),
        .shift_ctrl (ID_shift_ctrl_r),
        .arith_ctrl (ID_arith_ctrl_r),           

        .a          (EX_op_a        ),
        .b          (EX_op_b        ),
        .c          (EX_op_c        ),
        .overflow   (EX_overflow    ),
        .equal      (EX_equal       )
    );

    // pass the control signals
    always @ (posedge clk) begin
        EX_rd_addr_a_r  <= ID_rd_addr_a_r;
        EX_rd_addr_b_r  <= ID_rd_addr_b_r;
        EX_wr_addr_r    <= ID_wr_addr_r;
        EX_wr_en_r      <= ID_wr_en_r;
        EX_mem_rd_r     <= ID_mem_rd_r;
        EX_mem_wr_r     <= ID_mem_wr_r;
    end

//=============================================================================
// WB stage
//=============================================================================
    
    // write result back to register file
    always @ (posedge clk) begin
        if ((MEM_wr_addr_r != 0) && MEM_wr_en_r) begin
            reg_file[MEM_wr_addr_r] <= MEM_wr_data_r;
        end
    end


endmodule