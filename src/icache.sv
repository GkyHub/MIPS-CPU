module icache#(
    parameter DEPTH = 128;
    )(
    input               pc,
    output  [32 -1 : 0] ins
    );

    reg     [32 -1 : 0] cache[DEPTH];

    assign  ins = cache[pc];

endmodule