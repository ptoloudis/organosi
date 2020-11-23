`include "constants.h"
`timescale 1ns/1ps

module CPU (input clock,input reset);
reg  [31:0] PC,extended,D,wd;
reg  [7:0] inB,Result,inA;
reg  [4:0] wa,raB,raA;
reg  wen;
wire [31:0] Instr,addr, din, dout ,rdA, rdB;
wire [7:0] out;
wire [5:0] opcode,func;
wire [3:0] op; 
wire [1:0] Branch;
wire zero,ren, RegWrite, RegDst,  AluSrc, MemWrite ,  MemToReg;


    RegFile cpu_regs(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
    Memory cpu_DMem(clock, reset,ren, wen, addr, din, dout);
    Instruction_Memory cpu_IMem(PC,Instr);
    ALU cpu_alu(out, zero, inA, inB, op);
    fsm cpu_FSM( op, Branch, RegWrite, RegDst,  AluSrc, MemWrite ,  MemToReg, Instr[31:26], Instr[5:0]);

    always @(*)
    begin
        if(~reset)
            PC = 32'h0; 

        // if Branch and PC
        if(Branch)
            begin
                if (Branch == 1 && ~zero) begin
                    extended[15:0] = Instr[15:0];
                    extended[31:16] = {16{extended[15]}};
                    extended = ((extended < 1) ?1:0);//mporei alagi
                    D = (PC+4) + 4*extended;
                    PC <= D;
                end
                if (Branch == 2 && zero) begin
                    extended[15:0] = Instr[15:0];
                    extended[31:16] = {16{extended[15]}};
                    extended = ((extended < 1) ?1:0);//mporei alagi
                    D = (PC+4) + 4*extended;
                    PC <= D;
                end
                
            end 
        else
            PC <= PC + 4;

        //LW or SW    
        if (opcode == `LW || opcode == `SW) 
        begin
            raA = Instr[25:21];
            extended[15:0] = Instr[15:0];
            extended[31:16] = {16{extended[15]}};
            if (RegWrite && `LW) 
            begin
                wen = 1'b1;
                wa = Instr[20:16];
                wd = out;  
            end

            if (`SW) 
            begin
                raB <= Instr[20:16];
                wd = out;  
            end    
        end

        //R format
        if (opcode == `R_FORMAT) begin
            raA = Instr[25:21];
            raB <= Instr[20:16];
            inA = rdA;
        end

        //ADDI
        if(opcode == `ADDI)
        begin
            raA = Instr[25:21];
            inA <= rdA;
            inB = Instr[7:0];
        end
        
        //multix
        if (RegDst) 
        begin
            case (RegDst)
                0:wa = Instr[20:16];
                1:wa = Instr[15:11];
                default: wa = 5'hx;
            endcase    
        end
        if (AluSrc) begin
            case (RegDst)
                0:inB = rdB;
                1:inB = extended;
                default:  inB = 8'hx;
            endcase
        end
        if (MemToReg) begin
            case (RegDst)
                0:Result = out;
                1:Result = dout;
                default:  Result = 8'hx;
            endcase
        end

        
    end
endmodule