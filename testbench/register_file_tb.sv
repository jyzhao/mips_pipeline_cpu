/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if tbif ();
  // test program
  test #(.PERIOD (PERIOD)) PROG (
  				CLK,nRST,tbif
  				);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (tbif.rdat2),
    .\rfif.rdat1 (tbif.rdat1),
    .\rfif.wdat (tbif.wdat),
    .\rfif.rsel2 (tbif.rsel2),
    .\rfif.rsel1 (tbif.rsel1),
    .\rfif.wsel (tbif.wsel),
    .\rfif.WEN (tbif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

endmodule

program test (input logic CLK, output logic nRST,register_file_if.tb tbif);
  parameter PERIOD = 10;
  initial begin
    //$monitor("@%00g CLK = %b nRST = %b wdat = %b wsel = %b rsel1 = %b rsel2 = %b WEN = %b rdat1 = %b rdat2 = %b",
    //	      $time,CLK,nRST,tbif.wdat,tbif.wsel,tbif.rsel1,tbif.rsel2,tbif.WEN,tbif.rdat1,tbif.rdat2);
    nRST = 0;
    #(PERIOD)
    nRST = 1;
    #(PERIOD)
    nRST = 0;
    #(PERIOD)
    tbif.wsel = 0;
    tbif.wdat = 1;
    tbif.WEN = 1;
    #(PERIOD)
    tbif.WEN = 0;
    #(PERIOD)
    tbif.WEN = 1;
    
    $finish;
  end


endprogram
