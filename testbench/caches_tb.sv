// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns

module caches_tb;
  
  /*
  logic [3:0]  tb_i_AddrInd;
  logic [25:0] tb_i_AddrTag;
  logic [25:0] tb_i_tag;
  logic [31:0] tb_i_data;
  logic tb_i_valid,tb_i_hit,tb_i_ready;
  */
  
  parameter PERIOD = 10;
  logic tb_CLK = 0, tb_nRST;
  always #(PERIOD/2) tb_CLK++;

  datapath_cache_if dcif();
  cache_control_if ccif();

  // import types
  import cpu_types_pkg::word_t;

  parameter CPUID = 0;

  word_t instr;

  caches DUT(	tb_CLK,
  		tb_nRST,
	  	dcif,
  		ccif
  		
  		/*
  		.i_AddrInd(tb_i_AddrInd),
  		.i_AddrTag(tb_i_AddrTag),
  		.i_tag(tb_i_tag),
  		.i_data(tb_i_data),
  		.i_valid(tb_i_valid),
  		.i_hit(tb_i_hit),
  		.i_ready(tb_i_ready)*/
  	);
  	
  initial
  begin
    dcif.imemREN = 1;

    //reset
    tb_nRST = 0;
    dcif.imemaddr = 'h00000000;
    ccif.iwait = 1;
    ccif.iload = 'h00000000;
    #(PERIOD)
    
    tb_nRST = 1;
    
    //fill up cache
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00000000;
    ccif.iload = 'h0108DDFA;
    #(PERIOD)
    ccif.iwait = 0;
    //if(dcif.imemload == 0)
      $display("Test1: Address %h Miss @ %g ns", dcif.imemaddr,$time);
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00110004;
    ccif.iload = 'h0108CCCC;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00220008;
    ccif.iload = 'hDEADBEEF;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h0033000C;
    ccif.iload = 'h0108EEFA;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00440010;
    ccif.iload = 'hDEADDEAD;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00550014;
    ccif.iload = 'hEEAA8700;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00660018;
    ccif.iload = 'hFAD0FAD1;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h0077001C;
    ccif.iload = 'hCCEE0040;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00880020;
    ccif.iload = 'hEE00CC00;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00990024;
    ccif.iload = 'hAADD9900;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00AA0028;
    ccif.iload = 'hEEFA0108;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00BB002C;
    ccif.iload = 'hFAD0FAD1;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00CC0030;
    ccif.iload = 'hFA10EB08;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00DD0034;
    ccif.iload = 'hCDCD0500;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00EE0038;
    ccif.iload = 'h0500CDCD;
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00FF003C;
    ccif.iload = 'hFFFFFFFF;
    #(PERIOD)
    ccif.iwait = 0;
    
    
    //check miss/hit
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00440040;
    ccif.iload = 'hEEEEAAAA;	//miss
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00880020;
    ccif.iload = 'hEE00CC00;	//hit
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00CC0040;
    ccif.iload = 'hEB08FA10;	//miss
    #(PERIOD)
    ccif.iwait = 0;

    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00440010;
    ccif.iload = 'hDEADDEAD;	//hit
    #(PERIOD)
    ccif.iwait = 0;
    
    #(2*PERIOD)
    ccif.iwait = 1;
    dcif.imemaddr = 'h00CC0030;
    ccif.iload = 'hFA10EB08;	//hit
    #(PERIOD)
    ccif.iwait = 0;
    
  end
  		
endmodule
