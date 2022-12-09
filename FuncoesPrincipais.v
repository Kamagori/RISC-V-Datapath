module Registradores (R1, R2, WriteR, DadosEscritos, RegistradorEsc, Data1, Data2, MemoriaMov, reset, clock);

    reg [31:0] RF [31:0];
    integer i;

    input RegistradorEsc, MemoriaMov, reset, clock;
    output [31:0] Data1, Data2;


    input [4:0] R1, R2, WriteR;
    input [31:0] DadosEscritos;

    //definição dos valores padrão dos registradores
    always @ (reset) begin 
        RF[0] <= 0;
        RF[1] <= 32'd1; 
        RF[2] <= 32'd2; 
        RF[3] <= 32'd3; 
        RF[4] <= 32'd4; 
        RF[5] <= 32'd5; 
        RF[6] <= 32'd6; 
        RF[7] <= 32'd7; 
        RF[8] <= 32'd8; 
        RF[9] <= 32'd9; 
        RF[10] <= 32'd10; 
        RF[11] <= 32'd11; 
        RF[12] <= 32'd12; 
        RF[13] <= 32'd13; 
        RF[14] <= 32'd14; 
        RF[15] <= 32'd15; 
        RF[16] <= 32'd16; 
        RF[17] <= 32'd17; 
        RF[18] <= 32'd18; 
        RF[19] <= 32'd19; 
        RF[20] <= 32'd20; 
        RF[21] <= 32'd21; 
        RF[22] <= 32'd22; 
        RF[23] <= 32'd23; 
        RF[24] <= 32'd24; 
        RF[25] <= 32'd25; 
        RF[26] <= 32'd26; 
        RF[27] <= 32'd27; 
        RF[28] <= 32'd28; 
        RF[29] <= 32'd29; 
        RF[30] <= 32'd30; 
        RF[31] <= 32'd31; 

    end

    assign Data1 = RF[R1];
    assign Data2 = RF[R2];
    
    always  @(posedge clock) begin 
        if (RegistradorEsc) begin
	    RF[WriteR] <= DadosEscritos;
        end
    end    
endmodule

module Control (Opcode, ALUSrc, MemoriaMov, RegistradorEsc, MemoriaLida, MemoriaEscrita, Branch, ALUOp1, ALUOp0);
    input wire [6:0] Opcode;
    output reg ALUSrc, MemoriaMov, RegistradorEsc, MemoriaLida, MemoriaEscrita, Branch, ALUOp1, ALUOp0;

    //definição dos tipos de operação
    parameter TipoR = 7'b0110011;
    parameter TipoI = 7'b0000011;
    parameter TipoS = 7'b0100011;
    parameter TipoSB = 7'b1100011;
    
    always @ (Opcode) begin

        case (Opcode)
            TipoR: begin
                ALUSrc <= 0;
                MemoriaMov <= 0;
                RegistradorEsc <= 1;
                MemoriaLida <= 0;
                MemoriaEscrita <= 0;
                Branch <= 0;
                ALUOp1 <= 1;
                ALUOp0 <= 0;
            end

            TipoI: begin
                ALUSrc <= 1;
                MemoriaMov <= 1;
                RegistradorEsc <= 1;
                MemoriaLida <= 1;
                MemoriaEscrita <= 0;
                Branch <= 0;
                ALUOp1 <= 0;
                ALUOp0 <= 0;
            end

            TipoS: begin
                ALUSrc <= 1;
                MemoriaMov <= 0;
                RegistradorEsc <= 0;
                MemoriaLida <= 0;
                MemoriaEscrita <= 1;
                Branch <= 0;
                ALUOp1 <= 0;
                ALUOp0 <= 0;
            end
            TipoSB: begin
                ALUSrc <= 0;
                MemoriaMov <= 0;
                RegistradorEsc <= 0;
                MemoriaLida <= 0;
                MemoriaEscrita <= 0;
                Branch <= 1;
                ALUOp1 <= 0;
                ALUOp0 <= 1;
            end
            default: begin
                ALUSrc <= 0;
                MemoriaMov <= 0;
                RegistradorEsc <= 0;
                MemoriaLida <= 0;
                MemoriaEscrita <= 0;
                Branch <= 0;
                ALUOp1 <= 0;
                ALUOp0 <= 0;
	    end
        endcase
    end
endmodule


module ExtenderSinalFunct (instrucao, sinal_extendido);
    input wire [31:0] instrucao;
    output reg [31:0] sinal_extendido;


    parameter TipoI = 7'b0000011;
    parameter TipoS = 7'b0100011;
    parameter TipoSB = 7'b1100011;
   
    always @ (instrucao) begin

        case (instrucao[6:0])
            TipoI: sinal_extendido <= {{52{instrucao[31]}}, instrucao[31:20]};
            TipoS: sinal_extendido <= {{52{instrucao[31]}}, instrucao[31:25], instrucao[11:7]};
            TipoSB: sinal_extendido <= {{52{instrucao[31]}}, instrucao[31], instrucao[7], instrucao[30:25], instrucao[11:8]};
            default: sinal_extendido <= 1'b1;
        endcase
    end    
endmodule

module Mux2 (In1, In2, Escolha, Out);

    input [31:0] In1, In2;
    input Escolha;
    output reg [31:0] Out;

    always @(In1, In2, Escolha) begin 
        case (Escolha)
            1: Out <= In2;
            default: Out <= In1;
        endcase 
    end

endmodule

module ALUControl (instrucao, ALUcontrol, ALUOp0, ALUOp1);

    input ALUOp0, ALUOp1;
    input wire [31:0] instrucao;
    output reg [3:0] ALUcontrol;
    wire [3:0] possibilidades;

    assign possibilidades = {instrucao[30], instrucao[14:12]};
    
    always @(ALUOp1 or ALUOp0 or possibilidades) begin

        if(ALUOp0 == 0 & ALUOp1 == 0) begin
            ALUcontrol <= 4'b0010;
        end 
        
        else if(ALUOp0==1) begin
            ALUcontrol<=4'b0110;
        end 

        else begin

            case (possibilidades)

                0: ALUcontrol<=4'b0010; 
                8: ALUcontrol<=4'b0110; 
                7: ALUcontrol<=4'b0000; 
                6: ALUcontrol<=4'b0001; 
                default: ALUcontrol<=4'b1111;
            endcase

        end

    end
endmodule
