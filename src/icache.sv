module icache#(
    parameter DEPTH = 128;
    )(
    input               pc,
    output  [32 -1 : 0] ins
    );

    function integer bw;
        input integer depth;
        
        depth = depth - 1;
        
        for (bw=0; depth>0; bw=bw+1)
            depth = depth >> 1;
    endfunction

    reg     [32 -1 : 0] cache[DEPTH];

    assign  ins = cache[pc[bw(DEPTH)-1 : 0]];

endmodule