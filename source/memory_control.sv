/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 1;

   logic ramBusy;   

   assign ramBusy = (ccif.ramstate != ACCESS);// && ccif.ramstate != FREE);

   // Outputs to ram
   assign ccif.ramstore = ccif.dstore;
   assign ccif.ramaddr = (ccif.dREN | ccif.dWEN) ? ccif.daddr : ccif.iaddr;
   assign ccif.ramWEN = ccif.dWEN;
   assign ccif.ramREN = (ccif.dREN) ? 1 : (ccif.dWEN) ? 0 : ccif.iREN;

   // Outputs to caches
   assign ccif.iwait = (ccif.dREN | ccif.dWEN | ramBusy);//ccif.iREN & (ramBusy);
   assign ccif.dwait = (ccif.dREN | ccif.dWEN) & (ramBusy);
   assign ccif.iload = ccif.ramload;
   assign ccif.dload = ccif.ramload;

   // Coherence signals
   assign ccif.ccwait = 0;//(ccif.ramstate == BUSY);
   assign ccif.ccinv = 0;//(ccif.ramstate == ERROR);
   assign ccif.ccsnoopaddr = 0;//(ccif.dREN | ccif.dWEN) ? ccif.iaddr : ccif.daddr;

endmodule
