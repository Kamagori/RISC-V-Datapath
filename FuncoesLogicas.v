module LogicRightShift(Extensor, Out);
    
    output reg [31:0] Out;

    input wire [31:0] Extensor;

    always @ (Extensor) begin

        if(Extensor[31]) begin	

            Out = Extensor>>1;
            Out[31]=1'b1;

        end

        else begin 

            Out=Extensor>>1;

        end
    end
endmodule

module Init (PC, Endereco, clock, reset);

    output reg [31:0] PC;
    
    input wire [31:0] Endereco;

    input wire clock, reset;

    always @ (posedge clock) begin

        if (reset) begin

            PC=32'b0;

        end

        else begin 

            PC=Endereco;

        end
    end
endmodule

module ProxPC (PC, Endereco, Zero, Branch, sinal_extendido);
    
    
    input wire Zero, Branch, clock;

    input wire [31:0] sinal_extendido, PC;

    wire [31:0] novo_sinal;

    wire sinal;

    output reg [31:0] Endereco;

    LogicRightShift Division_by_4(sinal_extendido, novo_sinal);
    
    assign sinal = Zero & Branch;
    
    always @* begin

        case (sinal)

         	0: Endereco <= PC + 1;
        	default: Endereco <= PC + novo_sinal;

    	endcase

    end

endmodule

module Memoria (Endereco, Opcode, instrucao, reset, R1, R2, WriteR);

    input wire reset;
    input wire [31:0] Endereco;
    
    output reg [31:0] instrucao;
    output reg [4:0] R1, R2, WriteR;

    reg [31:0] MemoriaInstrucao [31:0];
    output reg [6:0] Opcode;

    always @ (reset) begin
        if (reset) begin 
	    $readmemb("instrucoes.txt", MemoriaInstrucao, 0, 31);
	end
    end 

    always @ (Endereco) begin

	instrucao=MemoriaInstrucao[Endereco];

        Opcode<=instrucao[6:0];

        R1<=instrucao[19:15];

        R2<=instrucao[24:20];

        WriteR<=instrucao[11:7];
    end
endmodule

module MemoriaArmazenada (Endereco, DadosEscritos, DadosLidos, MemoriaLida, MemoriaEscrita, InicializarMem, clock, fioSaida);

    integer i, j;
    output reg [32*32 -1:0] fioSaida;

    input wire [31:0] DadosEscritos, Endereco;
    reg [31:0] MemoryD [31:0];

    input wire MemoriaLida, MemoriaEscrita, InicializarMem, clock;
    output [31:0] DadosLidos;
    
    assign DadosLidos = MemoryD[Endereco];
    
    always @ (posedge clock) begin
        if(InicializarMem)

            for (i=0;i<32;i=i+1)
                MemoryD[i]=32'b0;

        else if (MemoriaEscrita)

            MemoryD[Endereco] = DadosEscritos;
    end

    always @ (negedge clock) begin 
        for (j = 0; j < 32; j = j + 1)
            fioSaida[32*j +: 32] = MemoryD[j];  
    end
endmodule

module ALU_Funct (ALUcontrol, A, B, ALU_Out, Zero);
    
    input wire [31:0] A, B;

    input wire [3:0] ALUcontrol;

    output reg Zero;

    output reg [31:0] ALU_Out;

    always @ (ALU_Out) begin

        Zero=(ALU_Out==0);
    end
    
    always @(ALUcontrol, A, B) begin

	    case (ALUcontrol)

	        0: ALU_Out<= A&B;     
	        1: ALU_Out<= A|B;

	        2: ALU_Out<= A+B;
	        6: ALU_Out<= A-B;

	        default: ALU_Out<=0;

	    endcase
    end
endmodule