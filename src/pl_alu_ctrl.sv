// =============================================================================
// pl_alu_ctrl.sv
// Unidade de Controle da ALU -- RV32I pipelined (P&H secao 4.4)
//
// Entradas (do estagio EX -- registrador ID/EX):
//   ALUOp[1:0] : codigo do controlador principal
//     2'b00 : Load/Store  -> forcar ADD
//     2'b01 : Branch BEQ  -> forcar SUB
//     2'b10 : R-type      -> decodificar via Funct3/Funct7
//   Funct7[6:0], Funct3[2:0] : campos da instrucao
//
// Saida Operation[3:0] -> pl_alu.sv:
//   4'd01 ADD  4'd02 SUB  4'd04 OR  4'd05 AND  4'd11 SLT
// =============================================================================

`timescale 1ns / 1ps

module pl_alu_ctrl (
    input  logic [1:0] ALUOp,
    input  logic [6:0] Funct7,
    input  logic [2:0] Funct3,
    output logic [3:0] Operation
);

/* O modulo alu ctrl e reponsavel pelo controle da ALU. Ele recebe como entrada Aluop(saida do modulo de CONTROLE que impactara
 qual intrucao a categoria de instrucao sera executada--de acesso a memoria ou de desvio), funct7 e funct 3. 
 A saida da alu_ctrl (operation) ira para ALU. Esse operarion ira dizer para alu qual intrucao que eu irei executar, 
 sendo determinada pelo modulo pl_ALU.
*/




    always_comb begin
        case (ALUOp)                    // Eu que defino o ALuop

            2'b00: Operation = 4'd01;   // se for 2'b00: categoria de acesso a memoria(alu forcada a fazer soma para o calculo do endereco)

            2'b01: Operation = 4'd02;   // categoria de desvio condicional (alu forcada a fazer subtracao para comparar os valores dos registradores)

            2'b10: begin                // categoria do tipo R-type (preciso olhar os funct agora)

                case (Funct3)
                    3'h0: Operation = Funct7[5] ? 4'd02 : 4'd01; // SUB ou ADD (verifica o quinto bit do funct7)
                    3'h6: Operation = 4'd04;  // OR
                    3'h7: Operation = 4'd05;  // AND
                    3'h2: Operation = 4'd11;  // SLT
                    3'h4: Operation = 4'd06;  //XOR (funt 3 e 100)  
                    3'h1: Operation = 4'd07;  //SLL
                    3'h5: Operation = Funct7[5] ? 4'd09 : 4'd08;   //SRL e SRA --> mesmo funct 3 e os que diferencia é o quinto bit no funct 7
                    3'h3: Operation = 4'd12; //SLTU
                    default: Operation = 4'd01;
                endcase
            end

            default: Operation = 4'd01;
        endcase
    end

endmodule
