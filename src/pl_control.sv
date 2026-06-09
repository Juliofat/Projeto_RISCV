// =============================================================================
// pl_control.sv
// Unidade de Controle Principal -- RV32I pipelined (P&H secao 4.4)
//
// Decodifica o opcode de 7 bits (estagio ID) e gera os sinais de controle
// que serao propagados pelos registradores de pipeline.
//
// Instrucoes suportadas:
//   R-type  (0110011): add, and
//   I-type  (0000011): lw
//   S-type  (0100011): sw
//   B-type  (1100011): beq
//
// Tabela de sinais de controle:
//   Sinal     | R-type | lw | sw | beq
//   ----------|--------|----|----|-----
//   ALUSrc    |   0    |  1 |  1 |  0    0=reg, 1=imm
//   MemtoReg  |   0    |  1 |  - |  -    0=ALU, 1=mem
//   RegWrite  |   1    |  1 |  0 |  0
//   MemRead   |   0    |  1 |  0 |  0
//   MemWrite  |   0    |  0 |  1 |  0
//   Branch    |   0    |  0 |  0 |  1
//   ALUOp[1]  |   1    |  0 |  0 |  0
//   ALUOp[0]  |   0    |  0 |  0 |  1
// =============================================================================

`timescale 1ns / 1ps

module pl_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic [1:0] ALUOp
);

    localparam R_TYPE = 7'b0110011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    localparam BRANCH = 7'b1100011;
    localparam I_TYPE = 7'b0010011;     //definindo o opcode das intrucoes do tipo I_type parte I (Addi, andi, ori, slli, slti, srli, srai);  

    always_comb begin
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)
            R_TYPE: begin
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            LOAD: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00;
            end
            STORE: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            I_TYPE: begin                 // implementando os sinais de controle para as intrucoes do tipo I_type 
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b11;

            end   
        /* Justificativa para os sinais para I_Type:
           
                ALUSrc   = 1'b0; -> Como o segundo operando vem do extensor de imediato, esse sinal agora é 1(diferente da R_type)
                MemtoReg = 1'b0; -> Valor que sera escrito no reg_dest e o resultado da ALU(assim como em nas R_type)
                RegWrite = 1'b1; -> Sinal de escrita no registrador de destino = 1
                MemRead  = 1'b0; -> I_type nao acessa a memoria de dados
                MemWrite = 1'b0; -> mesma justificativa da anterior
                Branch   = 1'b0; -> Como I_type nao sao instrucoes de desvio, entao esse sinal e 0. (semrpe PC + 4)
                ALUOp    = 2'b11. -> Esse sinal sendo '11', irei definir uma nova categoria para tratar as I_type em ALU control*/

            default: ; // sinais permanecem em zero (seguro)
        endcase
    end

endmodule
