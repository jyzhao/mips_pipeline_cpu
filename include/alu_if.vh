`ifndef ALU_IF_VH
`define ALU_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alu_if;
  // import types
  import cpu_types_pkg::*;

  logic     negF,zerF,oveF;
  aluop_t   aluop;
  word_t    portA, portB, outPort;

  modport a (
    input   portA,portB,aluop,
    output  outPort,negF,zerF,oveF
  );

endinterface

`endif //ALU_IF_VH
