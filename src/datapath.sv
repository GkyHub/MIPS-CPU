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
    // EX registers

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
    wire    [5  -1 : 0] rd_addr_a, rd_addr_b;   // register read address
    wire    [5  -1 : 0] wr_addr;                // register write address
    wire    sign_ext;
    
    // decode read register address
    assign  rd_addr_a = IF_ins_r[`RS];
    assign  rd_addr_b = IF_ins_r[`RT];

    always @ (posedge clk) begin
        ID_rd_addr_a_r <= rd_addr_a;
        ID_rd_addr_b_r <= rd_addr_b;
    end

    // decode write register address
    always @ (posedge clk) begin
        if (rst) begin
            ID_wr_addr_r <= 5'd0;
        end
        else begin
            unique case (IF_ins_r[`OPCODE])
            OP_RTYPE: ID_wr_addr_r <= IF_ins_r[`RD];
            OP_ADDI:  ID_wr_addr_r <= IF_ins_r[`RT];
            OP_ADDIU: ID_wr_addr_r <= IF_ins_r[`RT];
            OP_ORI:   ID_wr_addr_r <= IF_ins_r[`RT];
            OP_XORI:  ID_wr_addr_r <= IF_ins_r[`RT];
            OP_LUI:   ID_wr_addr_r <= IF_ins_r[`RT];
            OP_LW:    ID_wr_addr_r <= IF_ins_r[`RT];
            OP_SW:    ID_wr_addr_r <= 'bx;
            OP_BEQ:   ID_wr_addr_r <= 'bx;
            OP_BNE:   ID_wr_addr_r <= 'bx;
            OP_SLTI:  ID_wr_addr_r <= IF_ins_r[`RT];
            OP_SLTIU: ID_wr_addr_r <= IF_ins_r[`RT];
            OP_J:     ID_wr_addr_r <= 'bx;
            OP_JAL:   ID_wr_addr_r <= 5'd31;
            endcase
        end
    end

    // decode register write enable signal
    always @ (posedge clk) begin
        if (rst_n) begin
            ID_wr_en_r <= 1'b0;
        end
        else begin
            unique case (IF_ins_r[`OPCODE])
            OP_RTYPE: ID_wr_en_r <= 1'b1;   // since the rd of jr is 0, wr_en can be 1
            OP_ADDI:  ID_wr_en_r <= 1'b1;
            OP_ADDIU: ID_wr_en_r <= 1'b1;
            OP_ORI:   ID_wr_en_r <= 1'b1;
            OP_XORI:  ID_wr_en_r <= 1'b1;
            OP_LUI:   ID_wr_en_r <= 1'b1;
            OP_LW:    ID_wr_en_r <= 1'b1;
            OP_SW:    ID_wr_en_r <= 1'b0;
            OP_BEQ:   ID_wr_en_r <= 1'b0;
            OP_BNE:   ID_wr_en_r <= 1'b0;
            OP_SLTI:  ID_wr_en_r <= 1'b1;
            OP_SLTIU: ID_wr_en_r <= 1'b1;
            OP_J:     ID_wr_en_r <= 1'b0;   
            OP_JAL:   ID_wr_en_r <= 1'b1;
            endcase
        end        
    end

    // decode R/W mem signal
    always @ (posedge clk) begin
        if (rst_n) begin
            ID_mem_rd_r <= 1'b0;
            ID_mem_wr_r <= 1'b0;
        end 
        else begin
            ID_mem_rd_r <= (IF_ins_r == OP_LUI) || (IF_ins_r == )
        end
    end

    // read operators from registers
    always @ (posedge clk) begin
        if (rd_addr_a == 5'd0) begin
            ID_op_a_r <= 32'd0;
        end
        else begin
            ID_op_a_r <= reg_file[rd_addr_a];
        end

        if (rd_addr_b == 5'd0) begin
            ID_op_b_r <= 32'd0;
        end
        else begin
            ID_op_b_r <= reg_file[rd_addr_b];
        end
    end
    
    

    // extend immediate number
    wire    [16 -1 : 0] imm = IF_ins_r[`IMM];
    always @ (posedge clk) begin
        ID_imm_r[15: 0] <= imm;
        ID_imm_r[31:16] <= {16{sign_ext & imm[15]}};
    end

//=============================================================================
// ID stage
//=============================================================================

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