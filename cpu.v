`include "constants.h"
`timescale 1ns/1ps

module cpu (input clock,input reset);
reg [31:0] PC,D,extended,Instr;
reg [7:0]Result;

    RegFile cpu_regs(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
    Memory cpu_DMem(ren, wen, addr, din, dout);
    Instruction_Memory cpu_iMem(PC,Instr);
    ALU cpu_alu(out, zero, inA, inB, op);
    fsm cpu_FSM( op, Branch, RegWrite, RegDst,  AluSrc, MemWrite ,  MemToReg, Instr[31:26], Instr[5:0]);

    always @(*)
    begin
        if(~reset)
            PC = 32'h0; 
        
        //multix
        if (RegDst) 
        begin
            case (RegDst)
                0:wa = Instr[20:16];
                1:wa = Instr[15:11];
                default: wa = 5'hx;
            endcase    
        end
        if (ALUSrc) begin
            case (RegDst)
                0:inB = rdB;
                1:inB = extended;
                default:  inB = 8'hx;
            endcase
        end
        if (MemtoReg) begin
            case (RegDst)
                0:Result = out;
                1:Result = ReadData;
                default:  Result = 8'hx;
            endcase
        end

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
        if (opcode == LW or opcode == SW) 
        begin
            raA = Instr[25:21];
            extended[15:0] = Instr[15:0];
            extended[31:16] = {16{extended[15]}};
            if (RegWrite && LW) 
            begin
                wen = 1'b1;
                wa = Instr[20:16];
                wd = out;  
            end

            if (SW) 
            begin
                raB <= Instr[20:16];
                wd = out;  
            end    
        end

        //R format
        if (opcode == R_FORMAT) begin
            raA = Instr[25:21];
            raB <= Instr[20:16];
            inA = rdA;
        end

        //ADDI
        if(opcode == ADDI)
        begin
            raA = Instr[25:21];
            inA <= rdA;
            inB = Instr[7:0];
        end

endmodule