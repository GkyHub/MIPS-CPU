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
    reg     [32 -1 : 0] reg_file[31:1];         // register file
    // IF registers
    reg     [32 -1 : 0] IF_ins_r;
    reg     [32 -1 : 0] IF_pc_r;                // next pc
    // ID registers
    reg     [32 -1 : 0] ID_op_a_r, ID_op_b_r;
    reg     [5  -1 : 0] ID_rd_addr_a_r;
    reg     [5  -1 : 0] ID_rd_addr_b_r;
    reg     [5  -1 : 0] ID_wr_addr_r;
    reg                 ID_reg_wr_r;
    reg                 ID_mem_rd_r;
    reg                 ID_mem_wr_r;
    reg     aluop_t     ID_aluop_r;
    reg                 ID_sign_r;
    reg     [32 -1 : 0] ID_ext_imm_r;   
    reg                 ID_use_imm_r;
    reg     [2  -1 : 0] ID_branch_r;
    reg     [32 -1 : 0] ID_pc_r; 
    // EX registers
    reg     [5  -1 : 0] EX_wr_addr_r;
    reg     [32 -1 : 0] EX_alu_data_r;
    reg     [32 -1 : 0] EX_mem_data_r;
    reg                 EX_reg_wr_r;
    reg                 EX_mem_wr_r;
    reg                 EX_mem_rd_r;
    // MEM registers
    reg                 MEM_reg_wr_r;
    reg                 MEM_mem_rd_r;
    reg     [5  -1 : 0] MEM_wr_addr_r;
    reg     [32 -1 : 0] MEM_mem_data_r;
    reg     [32 -1 : 0] MEM_alu_data_r;

    // WB registers (none)

    // stall and clear signal
    wire    IF_stall, IF_clear;
    wire    ID_stall, ID_clear;
    wire    EX_stall, EX_clear;
    wire    MEM_stall, MEM_clear;

//=============================================================================
// IF stage
//=============================================================================

    always @ (posedge clk) begin
        if (~rst_n || IF_clear) begin
            IF_ins_r <= NOP;
            IF_pc_r  <= 32'h0000_0000;
        end
        else if (~IF_stall) begin
            IF_ins_r <= ins;
            IF_pc_r  <= pc_r + 4;
        end
    end

    always @ (posedge clk) begin
        if (~rst_n) begin
            pc_r <= 32'h0000_0000;
        end
        else begin
            pc_r <= pc_r + 4;
        end
    end

//=============================================================================
// ID stage
//=============================================================================

    wire    [5  -1 : 0] ID_rd_addr_a;
    wire    [5  -1 : 0] ID_rd_addr_b;
    wire    [5  -1 : 0] ID_wr_addr;
    wire                ID_reg_wr;
    wire                ID_mem_rd;
    wire                ID_mem_wr;
    wire    aluop_t     ID_aluop;
    wire                ID_sign;
    wire    [32 -1 : 0] ID_ext_imm;   
    wire                ID_use_imm;
    wire                ID_jump;       
    wire    [28 -1 : 0] ID_jump_addr;  
    wire    [2  -1 : 0] ID_branch;  

    // decode instruction
    decoder decoder_inst(
        .ins        (IF_ins_r       ),

        .rd_addr_a  (ID_rd_addr_a   ),
        .rd_addr_b  (ID_rd_addr_b   ),
        .wr_addr    (ID_wr_addr     ),
        .reg_wr     (ID_reg_wr      ),
        .mem_rd     (ID_mem_rd      ),
        .mem_wr     (ID_mem_wr      ),
        .aluop      (ID_aluop       ),
        .sign       (ID_sign        ),
        .ext_imm    (ID_ext_imm     ),                                       
        .use_imm    (ID_use_imm     ), 
        .jump       (ID_jump        ),       
        .jump_addr  (ID_jump_addr   ),  
        .branch     (ID_branch      ) 
    );

    // read operators from registers
    always @ (posedge clk) begin
        if (!ID_stall) begin
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
    end

    // write control signals to pipe stage registers
    // these should be cleared and reset
    always @ (posedge clk) begin
        if (~rst_n || ID_clear) begin
            ID_wr_addr_r <= '0;
            ID_reg_wr_r  <= '0;
            ID_mem_rd_r  <= '0;
            ID_mem_wr_r  <= '0;
            ID_branch_r  <= '0;
        end
        else (!ID_stall) begin
            ID_wr_addr_r <= ID_wr_addr;
            ID_reg_wr_r  <= ID_reg_wr;
            ID_mem_rd_r  <= ID_mem_rd;
            ID_mem_wr_r  <= ID_mem_wr;
            ID_branch_r  <= ID_branch;
        end
    end

    // these do not need reset
    always @ (posedge clk) begin
        if (!ID_stall) begin
            ID_rd_addr_a_r <= ID_rd_addr_a;
            ID_rd_addr_b_r <= ID_rd_addr_b;
            ID_aluop_r     <= ID_aluop; 
            ID_sign_r      <= ID_sign;     
            ID_ext_imm_r   <= ID_ext_imm;  
            ID_pc_r        <= IF_pc_r;   
            ID_use_imm_r   <= ID_use_imm;  
        end
    end

//=============================================================================
// EX stage
//=============================================================================
    reg     [32 -1 : 0] EX_op_a, EX_op_b;
    reg     [32 -1 : 0] EX_reg_b;
    wire    [32 -1 : 0] EX_alu_data;
    wire    EX_overflow, EX_equal;

    // select input operator a
    always_comb begin
        if (ID_rd_addr_a != 0) begin
            if (EX_wr_addr_r == ID_rd_addr_a_r && EX_reg_wr_r) begin
                EX_op_a = EX_alu_data_r;
            end
            else if (MEM_wr_addr_r == ID_rd_addr_a_r && MEM_reg_wr_r) begin
                EX_op_a = MEM_alu_data_r;
            end
            else begin
                EX_op_a = ID_op_a_r;
            end
        end
        else begin
            EX_op_a = ID_op_a_r;
        end
    end

    // select input operator b
    always_comb begin
        if (ID_rd_addr_b != 0) begin
            if (EX_wr_addr_r == ID_rd_addr_b_r && EX_reg_wr_r) begin
                EX_reg_b = EX_alu_data_r;
            end
            else if (MEM_wr_addr_r == ID_rd_addr_b_r && MEM_reg_wr_r) begin
                EX_reg_b = MEM_alu_data_r;
            end
            else begin
                EX_reg_b = ID_op_b_r;
            end
        end
    end

    always_comb begin
        if (use_imm) begin
            EX_op_b = ID_ext_imm_r;
        end
        else begin
            EX_op_b = EX_reg_b;
        end
    end

    // ALU operation
    alu alu_inst(
        .aluop      (ID_aluop_r     ),          
        .sign       (ID_sign_r      ),
        .a          (EX_op_a        ),
        .b          (EX_op_b        ),
        .c          (EX_op_c        ),
        .overflow   (EX_overflow    ),
        .equal      (EX_equal       )
    );

    // pass the control signals
    always @ (posedge clk) begin
        if (!rst_n || !EX_clear) begin
            EX_wr_addr_r    <= '0;
            EX_wr_en_r      <= '0;
            EX_mem_rd_r     <= '0;
            EX_mem_wr_r     <= '0;
        end
        else if (!EX_stall) begin
            EX_wr_addr_r    <= ID_wr_addr_r;
            EX_wr_en_r      <= ID_wr_en_r;
            EX_mem_rd_r     <= ID_mem_rd_r;
            EX_mem_wr_r     <= ID_mem_wr_r;
        end
    end

    always @ (posedge clk) begin
        if (!EX_stall) begin
            EX_mem_data_r <= EX_reg_b;
            EX_alu_data_r <= EX_alu_data;
        end
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