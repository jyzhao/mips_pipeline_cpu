`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module Hazard_Detection(
    IFIDRegRs,
    IFIDRegRt,
    IDEXRegDST,
    IDEXMemRead,
    IDEXRegWrite,
    Stall,
    CLK,
    nRST
);

input regbits_t IFIDRegRs, IFIDRegRt, IDEXRegDST;
input logic IDEXMemRead, IDEXRegWrite, CLK,nRST;
output logic Stall;

logic Stall2;

initial begin
  Stall <= 0;
  Stall2 <= 0;
end

always_ff @ (posedge CLK, negedge nRST) begin

if (!nRST) begin
  Stall <= 0;
  Stall2 <= 0;
end
else begin

  Stall <= 0;
  if (IDEXMemRead && ((IFIDRegRs == IDEXRegDST) || (IFIDRegRt == IDEXRegDST))) begin
    Stall <= 1;
    Stall2 <= 1;
  end else if (IDEXRegWrite && ((IFIDRegRs == IDEXRegDST) || (IFIDRegRt == IDEXRegDST))) begin
    Stall <= 1;
    Stall2 <= 0;
  end else if (Stall2) begin
    Stall <= 1;
    Stall2 <= 0;
  end else begin
    Stall <= 0; 
  end
end
end

endmodule
