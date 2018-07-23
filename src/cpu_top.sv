module cpu_top(
    parameter ICACHE_SIZE = 128,
    parameter DCACHE_SIZE = 128
    )(
    input   clk,
    input   rst_n
    );

    wire    [32 -1 : 0] ins;
    wire    [32 -1 : 0] pc;
    wire    [32 -1 : 0] mem_addr;
    wire    [32 -1 : 0] mem_wr_data;
    wire    [32 -1 : 0] mem_rd_data;
    wire                mem_wr_en;
    wire                mem_rd_en;

    icache #(
        .DEPTH  (ICACHE_SIZE    )
    ) icache_inst (
        .pc     (pc     ),
        .ins    (ins    )
    );

    dcache # (
        .DEPTH  (DCACHE_SIZE    )
    ) dcache_inst (
        .clk    (clk        ),
        .rst_n  (rst_n      ),
        .addr   (mem_addr   ),
        .wr_data(mem_wr_data),
        .rd_data(mem_rd_data),
        .wr_en  (mem_wr_en  ),
        .rd_en  (mem_rd_en  )
    );

    datapath datapath_inst (
        .clk        (clk        ),
        .rst_n      (rst_n      ),
        .pc         (pc         ),
        .ins        (ins        ),
        .mem_addr   (mem_addr   ),
        .mem_wr_data(mem_wr_data),
        .mem_rd_data(mem_rd_data),
        .mem_rd     (mem_rd     ),
        .mem_wr     (mem_wr     )
    );

endmodule