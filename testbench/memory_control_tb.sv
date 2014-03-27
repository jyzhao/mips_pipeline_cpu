
// interface
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"

// types
`include "cpu_types_pkg.vh"


import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module memory_control_tb;

  // interface
  cache_control_if ccif();
  cpu_ram_if ramif();
  
  parameter PERIOD = 20;

  // signals
  logic CLK = 1, nRST;

  // clock
  always #(PERIOD/2) CLK++;
  
  memory_control D1 (CLK, nRST, ccif);
  ram D2(CLK, nRST, ramif);
  
  
  assign ccif.ramstate = ramif.ramstate;
  assign ramif.ramaddr = ccif.ramaddr;
  assign ramif.ramREN = ccif.ramREN;
  assign ramif.ramWEN = ccif.ramWEN;
  assign ccif.ramload = ramif.ramload;
  assign ramif.ramstore = ccif.ramstore;
  
  
initial
begin

ccif.dREN = 0;
ccif.dWEN = 0;
ccif.iREN = 1;
ccif.daddr = 0;
ccif.dstore = 0;
ccif.iaddr = 0;

nRST = 0;

#(PERIOD)

nRST = 1;

#(PERIOD)

ccif.dREN = 1;
ccif.dWEN = 0;
ccif.iREN = 1;
ccif.daddr = 4;
ccif.dstore = 8;
ccif.iaddr = 0;






end


endmodule

