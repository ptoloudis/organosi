/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/

module cpu(input clock, input reset);
 reg [31:0] PC; 
 reg [31:0] IFID_PCplus4;
 reg [31:0] IFID_instr;
 reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend;
 reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd;                            
 reg        IDEX_RegDst, IDEX_ALUSrc;
 reg [1:0]  IDEX_ALUcntrl;
 reg        IDEX_Branch, IDEX_MemRead, IDEX_MemWrite; 
 reg        IDEX_MemToReg, IDEX_RegWrite;                
 reg [4:0]  EXMEM_RegWriteAddr, EXMEM_instr_rd; 
 reg [31:0] EXMEM_ALUOut;
 reg        EXMEM_Zero;
 reg [31:0] EXMEM_MemWriteData;
 reg        EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg;
 reg [31:0] MEMWB_DMemOut;
 reg [4:0]  MEMWB_RegWriteAddr, MEMWB_instr_rd; 
 reg [31:0] MEMWB_ALUOut;
 reg        MEMWB_MemToReg, MEMWB_RegWrite;               
 wire [31:0] instr, ALUInA, ALUInB, ALUOut, rdA, rdB, signExtend, DMemOut, wRegData, PCIncr;
 wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Branch;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_rt, instr_rd, RegWriteAddr;
 wire [3:0] ALUOp;
 wire [1:0] ALUcntrl;
 wire [15:0] imm;

//dikes mas
  wire [1:0] bypassA, bypassB, bypassC, bypassD;
  wire stall, ifid_write, pc_write; 
  wire [4:0] instr_sh;
  reg  [4:0] IDEX_Shamt;
  reg  Jump, bubble_idex ,PCSrc , Zero_b;
  reg   [31:0] RDA ,RDB;
  wire  [31:0]D , J;

/***************** Instruction Fetch Unit (IF)  ****************/
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
       PC <= -1;     
    else if (PC == -1)
       PC <= 0;
    else if (pc_write == 1'b1)
       PC <= PC;
    else if (PCSrc == 1'b1) begin
       PC <= D + PC;
    end
    else if (Jump == 1'b1) begin
      PC <= J;
    end
    else 
       PC <= PC + 4;
  end
  
  // IFID pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       IFID_PCplus4 <= 32'b0;    
       IFID_instr <= 32'b0;
    end 
    else if(ifid_write == 1'b1)begin
      IFID_PCplus4 <=  IFID_PCplus4;
      IFID_instr <= IFID_instr;
    end
    else if(bubble_idex == 1'b1)begin
      IFID_PCplus4 <= 32'b0;    
      IFID_instr <= 32'b0;
    end
    else 
      begin
       IFID_PCplus4 <= PC + 32'd4;
       IFID_instr <= instr;
    end
  end
  
// Instruction memory 1KB
Memory cpu_IMem(clock, reset, 1'b1, 1'b0, PC>>2, 32'b0, instr);
  
  
  
  
  
/***************** Instruction Decode Unit (ID)  ****************/
assign opcode = IFID_instr[31:26];
assign func = IFID_instr[5:0];
assign instr_rs = IFID_instr[25:21];
assign instr_rt = IFID_instr[20:16];
assign instr_rd = IFID_instr[15:11];
assign instr_sh = IFID_instr[10:6];
assign imm = IFID_instr[15:0];
assign signExtend = {{16{imm[15]}}, imm};


assign D = signExtend * 4;
assign J = IFID_instr[25:0] * 4;
// Register file
RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

control_bypass_branch bypass_branch(bypassC, bypassD, instr_rs, instr_rt, IDEX_instr_rs, IDEX_instr_rt,  EXMEM_RegWriteAddr, MEMWB_RegWriteAddr , EXMEM_RegWrite, MEMWB_RegWrite);

always @( negedge clock)
begin
  case (bypassC)
    2'b00: RDA = rdA;
    2'b01:  RDA = wRegData;
    2'b10:  RDA = EXMEM_ALUOut; 
    2'b11:  RDA = ALUOut;
    default:  RDA= 32'bx;
  endcase
  case (bypassD)
    2'b00:  RDB = rdB;
    2'b01:  RDB = wRegData;
    2'b10:  RDB = EXMEM_ALUOut; 
    2'b11:  RDB = ALUOut;
    default:  RDB = 32'bx;
  endcase
end 

always @(*)begin
  if (RDA == RDB)
    Zero_b = 1;
  else
    Zero_b= 0;
end

// IDEX pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)
      begin
       IDEX_rdA <= 32'b0;    
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                  
       IDEX_RegWrite <= 1'b0;
       IDEX_Shamt <= 5'b0;
    end 
    else 
      begin
       IDEX_rdA <= RDA;
       IDEX_rdB <= RDB;
       IDEX_signExtend <= signExtend;
       IDEX_instr_rd <= instr_rd;
       IDEX_instr_rs <= instr_rs;
       IDEX_instr_rt <= instr_rt;
       IDEX_RegDst <= RegDst;
       IDEX_ALUcntrl <= ALUcntrl;
       IDEX_ALUSrc <= ALUSrc;
       IDEX_Branch <= Branch;
       IDEX_MemRead <= MemRead;
       IDEX_MemWrite <= MemWrite;
       IDEX_MemToReg <= MemToReg;                  
       IDEX_RegWrite <= RegWrite;
       IDEX_Shamt <= instr_sh;
    end
  end

always @(posedge clock)
begin
  if (bubble_idex == 1'b1) begin
    IDEX_rdA <= 32'b0;    
    IDEX_rdB <= 32'b0;
    IDEX_signExtend <= 32'b0;
    IDEX_instr_rd <= 5'b0;
    IDEX_instr_rs <= 5'b0;
    IDEX_instr_rt <= 5'b0;
    IDEX_RegDst <= 1'b0;
    IDEX_ALUcntrl <= 2'b0;
    IDEX_ALUSrc <= 1'b0;
    IDEX_Branch <= 1'b0;
    IDEX_MemRead <= 1'b0;
    IDEX_MemWrite <= 1'b0;
    IDEX_MemToReg <= 1'b0;                  
    IDEX_RegWrite <= 1'b0;
    IDEX_Shamt <= 5'b0;
  end

  case (stall)
    1'b0:begin
      IDEX_rdA<= RDA;
       IDEX_rdB<= RDB;
       IDEX_signExtend<= signExtend;
       IDEX_instr_rd<= instr_rd;
       IDEX_instr_rs<= instr_rs;
       IDEX_instr_rt<= instr_rt;
       IDEX_RegDst<= RegDst;
       IDEX_ALUcntrl<= ALUcntrl;
       IDEX_ALUSrc<= ALUSrc;
       IDEX_Branch<= Branch;
       IDEX_MemRead<= MemRead;
       IDEX_MemWrite<= MemWrite;
       IDEX_MemToReg<= MemToReg;                  
       IDEX_RegWrite<= RegWrite;
       IDEX_Shamt <= instr_sh;
    end 
    1'b1:
    begin
      IDEX_rdA <= 32'b0;    
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                  
       IDEX_RegWrite <= 1'b0;
       IDEX_Shamt <= 5'b0;
    end 
    default: begin
      IDEX_rdA <= 32'bx;    
       IDEX_rdB <= 32'bx;
       IDEX_signExtend <= 32'bx;
       IDEX_instr_rd <= 5'bx;
       IDEX_instr_rs <= 5'bx;
       IDEX_instr_rt <= 5'bx;
       IDEX_RegDst <= 1'bx;
       IDEX_ALUcntrl <= 2'bx;
       IDEX_ALUSrc <= 1'bx;
       IDEX_Branch <= 1'bx;
       IDEX_MemRead <= 1'bx;
       IDEX_MemWrite <= 1'bx;
       IDEX_MemToReg <= 1'bx;                  
       IDEX_RegWrite <= 1'bx;
       IDEX_Shamt <= 5'bx;
    end
  endcase
end
// Main Control Unit 
control_main control_main (RegDst,
                  PCSrc,
                  MemRead,
                  MemWrite,
                  MemToReg,
                  ALUSrc,
                  RegWrite,
                  Jump,
                  ALUcntrl,
                  bubble_idex,
                  Zero_b,
                  opcode);
                  
// Instantiation of Control Unit that generates stalls goes here
control_stall_ex control_stall(stall, ifid_write, pc_write, IDEX_MemRead, IDEX_instr_rt, IDEX_instr_rs, instr_rs, instr_rt,bubble_idex);
                          
/***************** Execution Unit (EX)  ****************/
always @( negedge clock)
begin
  case (bypassA)
    2'b00:  IDEX_rdA = IDEX_rdA;
    2'b01:  IDEX_rdA = wRegData;
    2'b10:  IDEX_rdA = EXMEM_ALUOut; 
    default:  IDEX_rdA = 32'bx;
  endcase
  case (bypassB)
    2'b00:  IDEX_rdB = IDEX_rdB;
    2'b01:  IDEX_rdB = wRegData;
    2'b10:  IDEX_rdB = EXMEM_ALUOut; 
    default:  IDEX_rdB = 32'bx;
  endcase
end 

assign ALUInA = IDEX_rdA;
                 
assign ALUInB = (IDEX_ALUSrc == 1'b0) ? IDEX_rdB : IDEX_signExtend;

//  ALU
ALU  #(32) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, IDEX_Shamt, ALUOp);

assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

 // EXMEM pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       EXMEM_ALUOut <= 32'b0;    
       EXMEM_RegWriteAddr <= 5'b0;
       EXMEM_MemWriteData <= 32'b0;
       EXMEM_Zero <= 1'b0;
       EXMEM_Branch <= 1'b0;
       EXMEM_MemRead <= 1'b0;
       EXMEM_MemWrite <= 1'b0;
       EXMEM_MemToReg <= 1'b0;                  
       EXMEM_RegWrite <= 1'b0;
      end 
    else 
      begin
       EXMEM_ALUOut <= ALUOut;    
       EXMEM_RegWriteAddr <= RegWriteAddr;
       EXMEM_MemWriteData <= IDEX_rdB;
       EXMEM_Zero <= Zero;
       EXMEM_Branch <= IDEX_Branch;
       EXMEM_MemRead <= IDEX_MemRead;
       EXMEM_MemWrite <= IDEX_MemWrite;
       EXMEM_MemToReg <= IDEX_MemToReg;                  
       EXMEM_RegWrite <= IDEX_RegWrite;
      end
  end
  
  // ALU control
  control_alu control_alu(ALUOp, IDEX_ALUcntrl, IDEX_signExtend[5:0]);
  
   // Instantiation of control logic for Forwarding goes here
  control_bypass_ex control_bypass (bypassA, bypassB, IDEX_instr_rs, IDEX_instr_rt, EXMEM_RegWriteAddr, MEMWB_RegWriteAddr , EXMEM_RegWrite, MEMWB_RegWrite);


  
  
  
/***************** Memory Unit (MEM)  ****************/  

// Data memory 1KB
Memory cpu_DMem(clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, EXMEM_MemWriteData, DMemOut);

// MEMWB pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       MEMWB_DMemOut <= 32'b0;    
       MEMWB_ALUOut <= 32'b0;
       MEMWB_RegWriteAddr <= 5'b0;
       MEMWB_MemToReg <= 1'b0;                  
       MEMWB_RegWrite <= 1'b0;
      end 
    else 
      begin
       MEMWB_DMemOut <= DMemOut;
       MEMWB_ALUOut <= EXMEM_ALUOut;
       MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
       MEMWB_MemToReg <= EXMEM_MemToReg;                  
       MEMWB_RegWrite <= EXMEM_RegWrite;
      end
  end

  
  
  

/***************** WriteBack Unit (WB)  ****************/  
assign wRegData = (MEMWB_MemToReg == 1'b0) ? MEMWB_ALUOut : MEMWB_DMemOut;


endmodule