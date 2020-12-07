`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg PCSrc,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc,  
                output reg RegWrite,
                output reg Jump,
                output reg [1:0] ALUcntrl,
                output reg bubble_idex,
                input zero,
                input [5:0] opcode);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
          begin 
            RegDst = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
            PCSrc = 1'b0; 
            Jump = 1'b0;  
            bubble_idex = 1'b0;
            ALUcntrl  = 2'b10;// R           
          end
       `LW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            PCSrc = 1'b0;
            Jump = 1'b0;
            bubble_idex = 1'b0;
            ALUcntrl  = 2'b00; // add
           end
        `SW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
            PCSrc = 1'b0;
            Jump = 1'b0;
            bubble_idex = 1'b0;
            ALUcntrl  = 2'b00; // add
           end
       `BEQ:  
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            if ( zero ) begin
              bubble_idex = 1'b1;
              PCSrc = 1'b1;
            end
            else begin
              bubble_idex = 1'b0;
              PCSrc = 1'b0;
            end
            Jump = 1'b0;
            ALUcntrl = 2'b01; // sub
           end
        `ADDI:
            begin
                RegDst = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc = 1'b1;
                PCSrc = 1'b0;
                RegWrite = 1'b1;
                Jump = 1'b0;
                bubble_idex = 1'b0;
                ALUcntrl = 2'b00; // add
            end
        `J:
          begin
                RegDst = 1'bx;
                MemRead = 1'bx;
                MemWrite = 1'b0;
                MemToReg = 1'bx;
                ALUSrc = 1'bx;
                RegWrite = 1'b0;
                PCSrc = 1'b0;
                Jump = 1'b1;
                bubble_idex = 1'b1;
                ALUcntrl = 2'bxx; 
            end
        `BNE:  
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            if ( ~zero) begin
              bubble_idex = 1'b1;
              PCSrc = 1'b1;
            end
            else begin
              bubble_idex = 1'b0;
              PCSrc = 1'b0;
            end
            Jump = 1'b0;
            ALUcntrl = 2'b01; // sub
           end
       default:
           begin
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            PCSrc = 1'b0;
            Jump = 1'b0;
            bubble_idex = 1'b0;
            ALUcntrl = 2'b00; 
         end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
module  control_bypass_ex(output reg [1:0] bypassA,
                       output reg [1:0] bypassB,
                       input [4:0] idex_rs,
                       input [4:0] idex_rt,
                       input [4:0] exmem_rd,
                       input [4:0] memwb_rd,
                       input       exmem_regwrite,
                       input       memwb_regwrite);
       
  always @(*)begin
    bypassA = 2'b0;
    bypassB = 2'b0;
    if ( exmem_regwrite == 1 & exmem_rd != 0 & exmem_rd == idex_rs)
      bypassA = 2'b10;
    if ( exmem_regwrite == 1 & exmem_rd != 0 & exmem_rd == idex_rt)
      bypassB = 2'b10;
    if (memwb_regwrite == 1 & memwb_rd != 0 & memwb_rd == idex_rs & (exmem_rd != idex_rs || exmem_regwrite == 0))
      bypassA = 2'b1;
    if (memwb_regwrite == 1 & memwb_rd != 0 & memwb_rd == idex_rt & (exmem_rd != idex_rt || exmem_regwrite == 0))
      bypassB = 2'b1;     
  end
endmodule          

module  control_bypass_branch(output reg [1:0] bypassC,
                       output reg [1:0] bypassD,
                       input [5:0]      opcode,
                       input [4:0] raA,
                       input [4:0] raB,
                       input [4:0] idex_rs,
                       input [4:0] idex_rt,
                       input [4:0] exmem_rd,
                       input [4:0] memwb_rd,
                       input       exmem_regwrite,
                       input       memwb_regwrite);

  always @(*)begin
    if (opcode == `BEQ || opcode == `BNE) begin
      if (idex_rs ==raA)
        bypassC = 2'b11;
      if (idex_rs ==raB)
        bypassD = 2'b11;
      if ( exmem_regwrite == 1 & exmem_rd != 0 & exmem_rd == raA)
        bypassC = 2'b10;
      if ( exmem_regwrite == 1 & exmem_rd != 0 & exmem_rd == raB)
        bypassD = 2'b10;
      if (memwb_regwrite == 1 & memwb_rd != 0 & memwb_rd == raA & (exmem_rd != raA || exmem_regwrite == 0))
        bypassC = 2'b1;
      if (memwb_regwrite == 1 & memwb_rd != 0 & memwb_rd == raB & (exmem_rd != raB || exmem_regwrite == 0))
        bypassD = 2'b1;     
    end
    else begin
      bypassC = 2'b00;
      bypassD = 2'b00;
    end
  end
    
                   
endmodule

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
module  control_stall_ex(output reg stall, output reg ifid_write, output reg pc_write, input index_memread, input [4:0] idex_rt, input [4:0] idex_rs,input [4:0] ifid_rs,input [4:0] ifid_rt, input bubble_idex);
  always @(*)begin
    stall = 1'b0;
    ifid_write = 1'b0;
    pc_write = 1'b0;

    if ( index_memread == 1 & (idex_rt == ifid_rs || idex_rt == ifid_rt))
    begin
      stall = 1'b1;
      ifid_write = 1'b1;
      pc_write = 1'b1;
    end 
    if (bubble_idex == 1) begin
      stall = 1'b1;
      ifid_write = 1'b1;
      pc_write = 1'b1;
    end
  end
endmodule          
                       
/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b000000: ALUOp = 4'b1000; //sll
              6'b000100: ALUOp = 4'b1001; //slv
              6'b100000: ALUOp = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
              6'b100110: ALUOp = 4'b1101; //xor
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule
