onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color {Blue Violet} /cpu_tb/clock
add wave -noupdate /cpu_tb/reset
add wave -noupdate /cpu_tb/cpu0/PC
add wave -noupdate /cpu_tb/cpu0/PCIncr
add wave -noupdate /cpu_tb/cpu0/instr
add wave -noupdate -group IFID -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group IFID /cpu_tb/cpu0/IFID_PCplus4
add wave -noupdate -group IFID /cpu_tb/cpu0/IFID_instr
add wave -noupdate -group IFID /cpu_tb/cpu0/cpu_IMem/data
add wave -noupdate -group ID -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group ID /cpu_tb/cpu0/instr_rd
add wave -noupdate -group ID /cpu_tb/cpu0/instr_rs
add wave -noupdate -group ID /cpu_tb/cpu0/instr_rt
add wave -noupdate -group ID /cpu_tb/cpu0/imm
add wave -noupdate -group ID /cpu_tb/cpu0/func
add wave -noupdate -group ID /cpu_tb/cpu0/signExtend
add wave -noupdate -group ID /cpu_tb/cpu0/opcode
add wave -noupdate -group IDEX -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group IDEX /cpu_tb/cpu0/cpu_regs/data
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_ALUSrc
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_ALUcntrl
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_Branch
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_MemRead
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_MemToReg
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_MemWrite
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_RegDst
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_RegWrite
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_instr_rd
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_instr_rs
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_instr_rt
add wave -noupdate -group IDEX /cpu_tb/cpu0/rdA
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_rdA
add wave -noupdate -group IDEX /cpu_tb/cpu0/rdB
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_rdB
add wave -noupdate -group IDEX /cpu_tb/cpu0/instr_sh
add wave -noupdate -group IDEX /cpu_tb/cpu0/IDEX_Shamt
add wave -noupdate -group {CONTROL UNIT} -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/RegDst
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/RegWrite
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/MemRead
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/MemToReg
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/MemWrite
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/ALUSrc
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/Branch
add wave -noupdate -group {CONTROL UNIT} /cpu_tb/cpu0/ALUcntrl
add wave -noupdate -group {STAII UNIT} -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group {STAII UNIT} /cpu_tb/cpu0/stall
add wave -noupdate -group {STAII UNIT} /cpu_tb/cpu0/ifid_write
add wave -noupdate -group {STAII UNIT} /cpu_tb/cpu0/pc_write
add wave -noupdate -group ALU -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group ALU /cpu_tb/cpu0/ALUInA
add wave -noupdate -group ALU /cpu_tb/cpu0/ALUInB
add wave -noupdate -group ALU /cpu_tb/cpu0/ALUOp
add wave -noupdate -group ALU /cpu_tb/cpu0/ALUOut
add wave -noupdate -group ALU /cpu_tb/cpu0/Zero
add wave -noupdate -group ALU /cpu_tb/cpu0/IDEX_Shamt
add wave -noupdate -group BYPASS -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group BYPASS /cpu_tb/cpu0/bypassA
add wave -noupdate -group BYPASS /cpu_tb/cpu0/bypassB
add wave -noupdate -group BYPASS /cpu_tb/cpu0/control_bypass/idex_rs
add wave -noupdate -group BYPASS /cpu_tb/cpu0/control_bypass/idex_rt
add wave -noupdate -group BYPASS /cpu_tb/cpu0/control_bypass/exmem_rd
add wave -noupdate -group BYPASS /cpu_tb/cpu0/control_bypass/memwb_rd
add wave -noupdate -group BYPASS /cpu_tb/cpu0/control_bypass/exmem_regwrite
add wave -noupdate -group BYPASS /cpu_tb/cpu0/control_bypass/memwb_regwrite
add wave -noupdate -group EXMEM -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_ALUOut
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_Branch
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_MemRead
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_MemToReg
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_MemWrite
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_MemWriteData
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_RegWrite
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_RegWriteAddr
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_Zero
add wave -noupdate -group EXMEM /cpu_tb/cpu0/EXMEM_instr_rd
add wave -noupdate -group DMEM -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group DMEM /cpu_tb/cpu0/DMemOut
add wave -noupdate -group MEMWB -color {Blue Violet} /cpu_tb/clock
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MEMWB_ALUOut
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MEMWB_DMemOut
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MEMWB_MemToReg
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MEMWB_RegWrite
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MEMWB_RegWriteAddr
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MEMWB_instr_rd
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MemRead
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MemToReg
add wave -noupdate -group MEMWB /cpu_tb/cpu0/MemWrite
add wave -noupdate -group MEMWB /cpu_tb/cpu0/cpu_DMem/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {231569 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 230
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {215250 ps}
