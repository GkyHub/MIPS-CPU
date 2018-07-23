module dcache#(
    parameter DEPTH = 128,
    )(
    input   clk,
    input   [32 -1 : 0] addr,
    input   [32 -1 : 0] wr_data,
    output  [32 -1 : 0] rd_data,
    input               wr_en,
    output              rd_en
    );

    reg     [32 -1 : 0] cache[DEPTH];

    assign  rd_data = cache[addr];

    always @ (posedge clk) begin
        if (wr_en) begin
            cache[addr] <= wr_data;
        end
    end

endmodule