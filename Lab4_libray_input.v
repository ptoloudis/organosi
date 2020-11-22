// This file contains library modules to be used in your design. 

`include "constants.h"
`timescale 1ns/1ps

// Small ALU. 
//     Inputs: inA, inB, op. 
//     Output: out, zero
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, inA, inB, op);
  parameter N = 8;
  output reg [N-1:0] out;
  output reg zero;
  input  [N-1:0] inA, inB;
  input    [3:0] op;
  reg     [N -1:0] out1; 
  
  always @( inA, inB, op)
    begin
      
      case(op)
        4'b0000:  out1 = inA & inB;
        4'b0001:  out1 = inA | inB;
        4'b0010:  out1 = inA + inB;
        4'b0110:  out1 = inA - inB;
        4'b0111:  out1 = ((inA < inB)?1:0);
        4'b1100:  out1 = ~(inA | inB);
        default:  out1 = 8'bx;
      endcase  

      zero = 1'b0;
      if (out == 8'b0)
      begin
        zero = 1'b1;
      end
            
      if (out1 == 8'bx)
      begin
        $display("Don't care %b",op);
      end

      out = out1;
  end
endmodule



// Memory (active 1024 words, from 10 address ).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (ren, wen, addr, din, dout);
  input         ren, wen;
  input  [31:0] addr, din;
  output [31:0] dout;

  reg [31:0] data[4095:0];
  wire [31:0] dout;

  always @(ren or wen)   // It does not correspond to hardware. Just for error detection
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

  always @(posedge ren or posedge wen) begin // It does not correspond to hardware. Just for error detection
    if (addr[31:10] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;  
  
  always @(din or wen or ren or addr)
   begin
    if ((wen == 1'b1) && (ren==1'b0))
        data[addr[9:0]] = din;
   end

endmodule


// Register File. Input ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
  input clock,reset,wen;
  input [4:0]raA, raB, wa;
  input [31:0]wd;
  output [31:0] rdA, rdB;
  reg [31:0] data [31:0];
  integer i;  

  wire [31:0] rdA = data[raA];
  wire [31:0] rdB = data[raB];
      
  always @(negedge reset or negedge clock)
    begin
      if(reset == 1'b0)
        begin
          for (i = 0; i < 32; i = i+1)
          data[i] <= 0;
        end
      if (wen == 1'b1 && wa == 1'b0) 
        begin
          data[wa] = wd;
        end
    end

endmodule



// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 
module fsm(output [3:0] op,
          output [1:0] Branch,
          output RegWrite, RegDst,  AluSrc, MemWrite ,  MemToReg,
          input [5:0] opcode, 
          input [5:0] func);

	wire [1:0]ALUOp;	  

  always @( opcode)
    begin
      case (opcode)
        R_FORMAT  :
          begin
            RegWrite = 1'b1;      
            RegDst= 1'b1;       
            AluSrc = 1'b0;
            Branch = 2'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUOp = 2'b10;
          end
        LW:
          begin
            RegWrite = 1'b1;      
            RegDst= 1'b0;       
            AluSrc = 1'b1;
            Branch = 2'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUOp = 2'b0;
          end
        SW :
          begin
            RegWrite = 1'b0;      
            RegDst= 1'bx;       
            AluSrc = 1'b1;
            Branch = 2'b0;
            MemWrite = 1'b1;
            MemToReg = 1'bx;
            ALUOp = 2'b0;
          end
        BEQ:
          begin
            RegWrite = 1'b0;      
            RegDst= 1'bx;       
            AluSrc = 1'b0;
            Branch = 2'b01;
            MemWrite = 1'b0;
            MemToReg = 1'bx;
            ALUOp = 2'b01;
          end
        BNE : //allagi
          begin
            RegWrite = 1'b0;      
            RegDst= 1'bx;       
            AluSrc = 1'b0;
            Branch = 2'b10;
            MemWrite = 1'b0;
            MemToReg = 1'bx;
            ALUOp = 2'b01;
          end
        ADDI :
          begin
            RegWrite = 1'b1;      
            RegDst= 1'b0;       
            AluSrc = 1'b1;
            Branch = 2'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUOp = 2'b0;
          end
        default: 
          begin
            RegWrite = 1'bx;      
            RegDst= 1'bx;       
            AluSrc = 1'bx;
            Branch = 1'bx;
            MemWrite = 1'bx;
            MemToReg = 1'bx;
            ALUOp = 2'bx;
          end
      endcase

      case (ALUOp)
        2'b00:  op = 4'b10; 
        2'b01:  op = 4'b110;
        2'b10:  op = func;
        default: op = 4'bx;
      endcase
    end
endmodule

module Instruction_Memory (addr_i,instr_o);

  // Interface
  input   [31:0]      addr_i;
  output  [31:0]      instr_o;

  // Instruction memory
  reg     [31:0]     data  [511:0];
  assign  instr_o = data[addr_i<<2];  

endmodule