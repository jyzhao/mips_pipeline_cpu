// interface
`include "control_unit_if.vh"

// types
`include "cpu_types_pkg.vh"


import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns


module control_unit_tb;
  
  control_unit_if cuif();
  
  parameter PERIOD = 20;
  
  control_unit DUT (cuif);
  
  initial
  begin
    
    cuif.opcode = RTYPE;
    
    cuif.funct = ADDU;
    
    #20
    cuif.funct = AND;
    
    #20
    cuif.funct = JR;
    
    #20
    cuif.funct = NOR;
    
    #20
    cuif.funct = OR;
    
    #20
    cuif.funct = SLT;
    
    #20
    cuif.funct = SLTU;
    
    #20
    cuif.funct = SLL;
    
    #20
    cuif.funct = SRL;
    
    #20
    cuif.funct = SUBU;
    
    #20
    cuif.funct = XOR;
    
    
    
    #20
    cuif.opcode = ADDIU;
    
    #20
    cuif.opcode = ANDI;
    
    #20
    cuif.opcode = BEQ;
    cuif.Equal = 1;
    
    #20
    cuif.Equal = 0;
    
    #20
    cuif.opcode = BNE;
    
    #20
    cuif.Equal = 1;
    
    #20
    cuif.opcode = LUI;
    
    #20
    cuif.opcode = LW;
    
    #20
    cuif.opcode = ORI;
    
    #20
    cuif.opcode = SLTI;
    
    #20
    cuif.opcode = SLTIU;
    
    #20
    cuif.opcode = SW;
    
    #20
    cuif.opcode = LL;
    
    #20
    cuif.opcode = SC;
    
    #20
    cuif.opcode = XORI;
    
    
    
    #20
    cuif.opcode = J;
    
    #20
    cuif.opcode = JAL;
    
    #20
    cuif.opcode = HALT;
  end
  
endmodule
    