// =============================================================================
// pl_alu.sv
// Unidade Logica e Aritmetica de 32 bits -- RV32I pipelined
//
// Codificacao de operacao (Operation[3:0]):
//   4'd01 : ADD  -- adicao com sinal
//   4'd02 : SUB  -- subtracao com sinal  (BEQ usa Zero)
//   4'd04 : OR   -- OU bit a bit
//   4'd05 : AND  -- E bit a bit
//   4'd06:  XOR  -- Xor bit a bit (bits diferentes -> saida 1)
//   4'07:   SLL  -- Shift left no binario
//   4'd11 : SLT  -- set-less-than com sinal

// =============================================================================

`timescale 1ns / 1ps

module pl_alu (
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    input  logic [3:0]  Operation,
    output logic [31:0] ALUResult,
    output logic        Zero
);

    always_comb begin
        case (Operation)
            4'd01:   ALUResult = $signed(SrcA) + $signed(SrcB);
            4'd02:   ALUResult = $signed(SrcA) - $signed(SrcB);
            4'd04:   ALUResult = SrcA | SrcB;
            4'd05:   ALUResult = SrcA & SrcB;
            4'd06:   ALUResult = SrcA ^ SrcB;   // inserindo a xor 
            4'd07:   AluResult = SrcA << SrcB[4:0]; // utilizo apenas os 5 bits menos significativos de b, pois consigo representar a qtd maximo de deslocamento possivel no primeiro operando( 32 bits -- 2⁵) 
            4'd11:   ALUResult = 32'($signed(SrcA) < $signed(SrcB));
            

            default: ALUResult = 32'b0;
        endcase
    end

    assign Zero = (ALUResult == 32'b0);

endmodule
