`include "FuncoesLogicas.v"
`include "FuncoesPrincipais.v"


module main;

    reg clock, reset;
    wire [31:0] programCounter, endereco;
    wire [31:0] instrucao, teste;
    wire [6:0] Opcode;
    wire [4:0] R1, R2, WriteR;
    wire ALUSrc, MemoriaMov, RegistradorEsc, MemoriaLida, MemoriaEscrita, Branch, ALUOp1, ALUOp0;
    wire [31:0] Data1, Data2, sinal_extendido;
    wire [3:0] ALUcontrol;
    wire [31:0] ALU_Out, MuxOut, DadosLidos, DadosEscritosRF;
    wire Zero;
    wire testando;
    wire [32*32 -1:0] fioSaida;
    integer i;
    
    // Execução do caminho de dados passo a passo
    Init p1(programCounter, endereco, clock, reset);
    Memoria p2(programCounter, Opcode, instrucao, reset, R1, R2, WriteR);
    Control p3(Opcode, ALUSrc, MemoriaMov, RegistradorEsc, MemoriaLida, MemoriaEscrita, Branch, ALUOp1, ALUOp0);
    Registradores p4(R1, R2, WriteR, DadosEscritosRF, RegistradorEsc, Data1, Data2, MemoriaMov, reset, clock);
    ExtenderSinalFunct p5(instrucao, sinal_extendido);
    Mux2 p6(Data2, sinal_extendido, ALUSrc, MuxOut);
    ALUControl p7(instrucao, ALUcontrol, ALUOp0, ALUOp1);
    ALU_Funct p8(ALUcontrol, Data1, MuxOut, ALU_Out, Zero);
    MemoriaArmazenada p9(ALU_Out, Data2, DadosLidos, MemoriaLida, MemoriaEscrita, reset, clock, fioSaida);
    Mux2 p10(ALU_Out, DadosLidos, MemoriaMov, DadosEscritosRF);
    ProxPC p11(programCounter, endereco, Zero, Branch, sinal_extendido);

    initial begin
      clock = 0;
      reset = 1;
      #5 reset = 0;

      $dumpfile("dump.vcd");
      $dumpvars;

      #80  
      for (i = 0; i < 32; i = i + 1) begin
          $display("Register [%d]: %d", i, fioSaida[32*i +: 32]);
      end
      $finish ;
    end
   
    always #3 clock = ~clock;
endmodule	
