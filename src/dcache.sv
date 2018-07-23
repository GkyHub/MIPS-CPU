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

    function integer bw;
        input integer depth;
        
        depth = depth - 1;
        
        for (bw=0; depth>0; bw=bw+1)
            depth = depth >> 1;
    endfunction

    reg     [32 -1 : 0] cache[DEPTH];

    assign  rd_data = cache[addr[bw(DEPTH)-1 : 0]];

    always @ (posedge clk) begin
        if (wr_en) begin
            cache[addr] <= wr_data;
        end
    end

endmodule