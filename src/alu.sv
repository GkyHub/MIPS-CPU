import  MIPS_DEF::*;

module alu(
    input   aluop_t     aluop,
    input               sign,       // 1: signed operator
                                    // 0: unsigned operator       

    input       [32 -1 : 0] a,
    input       [32 -1 : 0] b,
    output  reg [32 -1 : 0] c,
    output              overflow,
    output              equal
    );

    always_comb begin
        unique case (aluop)
        ALU_ADD: c = a + b;
        ALU_SUB: c = a - b;
        ALU_CMP: c = sign ? : {31'd0, (a < b)}
        ALU_AND: c = a & b;
        ALU_OR:  c = a | b;
        ALU_XOR: c = a ^ b;
        ALU_NOR: c = ~(a | b);
        ALU_SL:  c = a << b[4 : 0];
        ALU_SR:  c = {32{a[31] & sign}, a} >> b[4 : 0]; 
        endcase
    end

    assign  equal = !(|(a ^ b));

endmodule