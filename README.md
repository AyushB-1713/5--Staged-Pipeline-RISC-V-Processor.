# 5--Staged-Pipeline-RISC-V-Processor.
Designed a 32-bit RISC-V ALU processor using Verilog with five pipeline stages.

Q:-What It Implements

Soln:-32-bit RISC-V style datapath
5 pipeline stages:
i)Instruction Fetch
ii)Instruction Decode
iii)Execute
iv)Memory Access
v)Write Back

Pipeline registers between all stages

Register file with 32 registers,
ALU,
Immediate generator,
Main control unit,
Forwarding unit for data hazards,
Simple instruction memory for simulation

Supported Instructions
i)R-type arithmetic/logical: ADD, SUB, AND, OR, XOR, SLT

ii)I-type arithmetic/logical: ADDI, ANDI, ORI, XORI, SLTI
