
// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module caches (
  input logic CLK, nRST,
  datapath_cache_if.cache dcif,
  cache_control_if.caches ccif
);
  // import types
  import cpu_types_pkg::word_t;

  parameter CPUID = 0;

  word_t instr;

  // dcache
  // dcache  DCACHE(dcif, ccif);
  // word_t [15:0][1:0] dcache_register;  


  // ### ICACHE ###
  // Direct Mapped
  // One word per block

  //icache  ICACHE(dcif, ccif); // When to use this?
  logic [15:0][58:0] icache_register;
  // 58    => Valid bit
  // 57:32 => Tag
  // 31:0  => Data

  // For [31:0] Address
  // [1:0]  => Byte Offset (thrown away)
  // [5:2]  => Index (4 bits for 16 places)
  // [31:6] => Tag (26 bits)

  logic [3:0]  i_AddrInd;
  logic [25:0] i_AddrTag;
  logic [25:0] i_tag;
  logic [31:0] i_data;
  logic i_valid,i_hit,i_ready;

  assign i_AddrTag = dcif.imemaddr[31:6];
  assign i_AddrInd = dcif.imemaddr[5:2];

  assign i_valid = icache_register[i_AddrInd][58];
  assign i_tag   = icache_register[i_AddrInd][57:32];
  assign i_data  = icache_register[i_AddrInd][31:0];

  assign i_hit = (i_AddrTag == i_tag);

    
// States
typedef enum {RESET, IDLE, ALLOCATE, SET_CACHE} istates;
istates i_state, i_nstate;

  // Cache State Machine
  always_ff @(posedge CLK, negedge nRST)
  begin
    if(!nRST)
      i_state <= RESET;
    else
      i_state <= i_nstate;
  end

  // Next State Logic for icache
  always_comb
  begin
    case (i_state)
      IDLE:
        begin
          if(dcif.imemREN && (~i_valid || ~i_hit))
            i_nstate = ALLOCATE;
          else
            i_nstate = IDLE;
    	  end
      ALLOCATE:
        begin
          if(~ccif.iwait[CPUID])
            i_nstate = SET_CACHE;
          else
            i_nstate = ALLOCATE;
        end
      SET_CACHE:
        begin
          i_nstate = IDLE;
        end
      RESET:
        begin
          i_nstate = IDLE;
        end
    endcase
  end
  
  // Output Logic for icache
  always_comb
  begin
    ccif.iREN[CPUID] = 0;
    ccif.iaddr[CPUID] = 0;
    i_ready = 0;

    // No change in cache register
/*    icache_register[i_AddrInd][58]    = icache_register[i_AddrInd][58];
    icache_register[i_AddrInd][57:32] = icache_register[i_AddrInd][57:32];
    icache_register[i_AddrInd][31:0]  = icache_register[i_AddrInd][31:0]; */

    case (i_state)
      IDLE:
        begin
          i_ready = 1;
        end
      ALLOCATE:
        begin
          ccif.iREN[CPUID]  = 1;
          ccif.iaddr[CPUID] = dcif.imemaddr;
        end
      SET_CACHE:
        begin
          icache_register[i_AddrInd][58]    = 1; // Set Valid Flag
          icache_register[i_AddrInd][57:32] = i_AddrTag;
          icache_register[i_AddrInd][31:0]  = ccif.iload[CPUID];
        end
      RESET:
        begin
          icache_register = 0;
        end
    endcase
  end
  
  // Actual Outputs that are seen by the datapath
  assign dcif.imemload = (dcif.imemREN && i_valid && i_hit) ? i_data : 0;
  assign dcif.ihit = i_ready;
  // ### ICACHE ###

  // ### DCACHE ###
  // Two way associative -> Two blocks per set?
  // Two words per block

  logic [7:0][185:0] dcache_register;
  // SET 1 [185:93]
  // 185     => Dirty Bit
  // 184     => Least Recently Used bit
  // 183     => Valid bit
  // 182:157 => Tag
  // 156:125 => Block 1 Data
  // 124:93  => Block 2 Data

  // SET 2 [92:0]
  // 92      => Dirty Bit
  // 91      => Least Recently Used bit
  // 90      => Valid bit
  // 89:64   => Tag
  // 63:32   => Block 1 Data
  // 31:0    => Block 2 Data

  // For [31:0] Address
  // [1:0]  => Byte Offset (thrown away)
  // 2      => Block Offset
  // [5:3]  => Index (3 bits for 8 places)
  // [31:6] => Tag (26 bits)

  logic [2:0]  d_AddrInd;
  logic [25:0] d_AddrTag;
  logic [25:0] d_s1Tag, d_s2Tag;
  logic [31:0] d_s1Data, d_s1Block1, d_s1Block2, d_s2Data, d_s2Block1, d_s2Block2;
  logic d_s1Valid, d_s1Hit, d_s1LRU, d_s2Valid, d_s2Hit, d_s2LRU, d_blockOffset, d_s1Dirty, d_s2Dirty;
  
  logic d_ready;
  
  logic [31:0] hit_counter;
  
  assign d_AddrTag     = dcif.dmemaddr[31:6];
  assign d_AddrInd     = dcif.dmemaddr[5:3];
  assign d_blockOffset = dcif.dmemaddr[2];

  assign d_s1Dirty  = dcache_register[d_AddrInd][185];
  assign d_s1LRU    = dcache_register[d_AddrInd][184];
  assign d_s1Valid  = dcache_register[d_AddrInd][183];
  assign d_s1Tag    = dcache_register[d_AddrInd][182:157];
  assign d_s1Block1 = dcache_register[d_AddrInd][156:125];
  assign d_s1Block2 = dcache_register[d_AddrInd][124:93];

  assign d_s2Dirty  = dcache_register[d_AddrInd][92];
  assign d_s2LRU    = dcache_register[d_AddrInd][91];
  assign d_s2Valid  = dcache_register[d_AddrInd][90];
  assign d_s2Tag    = dcache_register[d_AddrInd][89:64];
  assign d_s2Block1 = dcache_register[d_AddrInd][63:32];
  assign d_s2Block2 = dcache_register[d_AddrInd][31:0];

  assign d_s1Data = (d_blockOffset) ? d_s1Block2 : d_s1Block2;
  assign d_s2Data = (d_blockOffset) ? d_s2Block2 : d_s2Block2;

  assign d_s1Hit = (d_AddrTag == d_s1Tag);
  assign d_s2Hit = (d_AddrTag == d_s2Tag);

// States
typedef enum {dRESET, dIDLE, dALLOCATE, SET1_CACHE, SET2_CACHE, SET_DIRTY, SET1_WRITE_BACK1, SET1_WRITE_BACK2, SET2_WRITE_BACK1, SET2_WRITE_BACK2, WRITE_COUNTER, HALT} dstates;
dstates d_state, d_nstate;

  // Cache State Machine
  always_ff @(posedge CLK, negedge nRST)
  begin
    if(!nRST)
    begin
      d_state <= dRESET;
      hit_counter <= 0;
    end
    else
    begin
      d_state <= d_nstate;
      if(d_state == dIDLE && dcif.dmemREN && ((d_s1Valid && d_s1Hit) || (d_s2Valid && d_s2Hit)))
        hit_counter <= hit_counter + 1;
      else
        hit_counter <= hit_counter;
    end
  end

  // Next State Logic for dcache
  always_comb
  begin
    case (d_state)
      dIDLE:
        begin
          if(dcif.dmemREN && (~d_s1Valid || ~d_s1Hit) && (~d_s2Valid || ~d_s1Hit))
            d_nstate = dALLOCATE;
          else if(dcif.dmemWEN)
            d_nstate = SET_DIRTY;
          else if(dcif.halt)
            d_nstate = WRITE_COUNTER;
          else
            d_nstate = dIDLE;
    	  end
      dALLOCATE:
        begin
          if(~ccif.dwait[CPUID])
          begin
            if(d_s1LRU)
            begin
              if(d_s1Dirty)
                d_nstate = SET1_WRITE_BACK1;
              else
                d_nstate = SET1_CACHE;
            end
            else
            begin
              if(d_s2Dirty)
                d_nstate = SET2_WRITE_BACK1;
              else
                d_nstate = SET2_CACHE;
            end
          end
          else
            d_nstate = dALLOCATE;
        end
      SET1_CACHE:
        begin
          d_nstate = dIDLE;
        end
      SET2_CACHE:
        begin
          d_nstate = dIDLE;
        end
      SET_DIRTY:
        begin
          if(d_s1LRU)
            d_nstate = SET1_CACHE;
          else
            d_nstate = SET2_CACHE;
        end
      SET1_WRITE_BACK1:
        begin
          if(~ccif.dwait[CPUID])
            d_nstate = SET1_WRITE_BACK2;
          else
            d_nstate = SET1_WRITE_BACK1;
        end
      SET1_WRITE_BACK2:
        begin
          if(~ccif.dwait[CPUID])
            d_nstate = SET1_CACHE;
          else
            d_nstate = SET1_WRITE_BACK2;
        end
      SET2_WRITE_BACK1:
        begin
          if(~ccif.dwait[CPUID])
            d_nstate = SET2_WRITE_BACK2;
          else
            d_nstate = SET2_WRITE_BACK1;
        end
      SET2_WRITE_BACK2:
        begin
          if(~ccif.dwait[CPUID])
            d_nstate = SET2_CACHE;
          else
            d_nstate = SET2_WRITE_BACK2;
        end
      WRITE_COUNTER:
        begin
          if(~ccif.dwait[CPUID])
            d_nstate = HALT;
          else
            d_nstate = WRITE_COUNTER;
        end
      HALT:
        begin
          d_nstate = HALT;
        end
      dRESET:
        begin
          d_nstate = dIDLE;
        end
    endcase
  end
  
  // Output Logic for icache
  always_comb
  begin
    ccif.dREN[CPUID] = 0;
    ccif.dWEN[CPUID] = 0;
    ccif.daddr[CPUID] = 0;
    d_ready = 0;
    dcif.flushed = 0;
    
    case (d_state)
      dIDLE:
        begin
          d_ready = 1;
    	  end
      dALLOCATE:
        begin
          ccif.dREN[CPUID]  = 1;
          ccif.daddr[CPUID] = dcif.dmemaddr;
        end
      SET1_CACHE:
        begin
          dcache_register[d_AddrInd][184]       = 0; // This is most recently used
          dcache_register[d_AddrInd][91]        = 1; // Other set is LRU
          dcache_register[d_AddrInd][183]       = 1; // Set Valid Flag
          dcache_register[d_AddrInd][182:157]   = d_AddrTag;
          if(d_blockOffset)
            dcache_register[d_AddrInd][124:93]  = ccif.dload[CPUID];
          else
            dcache_register[d_AddrInd][156:125] = ccif.dload[CPUID];
        end
      SET2_CACHE:
        begin
          dcache_register[d_AddrInd][91]        = 0; // This is most recently used
          dcache_register[d_AddrInd][184]       = 1; // Other set is LRU
          dcache_register[d_AddrInd][90]        = 1; // Set Valid Flag
          dcache_register[d_AddrInd][89:64]     = d_AddrTag;
          if(d_blockOffset)
            dcache_register[d_AddrInd][31:0]    = ccif.dload[CPUID];
          else
            dcache_register[d_AddrInd][63:32]   = ccif.dload[CPUID];
        end
      SET_DIRTY:
        begin
          if(d_s1LRU)
            dcache_register[d_AddrInd][185] = 1;
          else
            dcache_register[d_AddrInd][92] = 1;
        end
      SET1_WRITE_BACK1:
        begin
          dcache_register[d_AddrInd][185] = 0;
          ccif.dWEN[CPUID]   = 1;
          ccif.daddr[CPUID]  = {d_s1Tag,d_AddrInd,3'b000};
          ccif.dstore[CPUID] = d_s1Block1;
        end
      SET1_WRITE_BACK2:
        begin
          ccif.dWEN[CPUID]   = 1;
          ccif.daddr[CPUID]  = {d_s1Tag,d_AddrInd,3'b100};
          ccif.dstore[CPUID] = d_s1Block2;
        end
      SET2_WRITE_BACK1:
        begin
          dcache_register[d_AddrInd][92] = 0;
          ccif.dWEN[CPUID]   = 1;
          ccif.daddr[CPUID]  = {d_s2Tag,d_AddrInd,3'b000};
          ccif.dstore[CPUID] = d_s2Block1;
        end
      SET2_WRITE_BACK2:
        begin
          ccif.dWEN[CPUID]   = 1;
          ccif.daddr[CPUID]  = {d_s2Tag,d_AddrInd,3'b100};
          ccif.dstore[CPUID] = d_s2Block2;
        end
      WRITE_COUNTER:
        begin
          ccif.dWEN[CPUID]   = 1;
          ccif.daddr[CPUID]  = 'h00003100;
          ccif.dstore[CPUID] = hit_counter;
        end
      HALT:
        begin
          dcif.flushed = 1;
        end
      dRESET:
        begin
          dcache_register = 0;
        end
    endcase
  end
  
  // Actual Outputs that are seen by the datapath
  always_comb
  begin
    if(dcif.dmemREN)
    begin
      if(d_s1Hit && d_s1Valid)
        dcif.dmemload = d_s1Data;
      else if(d_s2Hit && d_s2Valid)
        dcif.dmemload = d_s2Data;
      else
        dcif.dmemload = 0;
    end
    else
      dcif.dmemload = 0;
  end
  
  assign dcif.dhit = d_ready;
  // ### DCACHE ###

/*
  // single cycle instr saver (for memory ops)
  always_ff @(posedge CLK)
  begin
    if (!nRST)
    begin
      instr <= 0;
    end
    else
    if (!ccif.iwait[CPUID])
    begin
      instr <= ccif.iload[CPUID];
    end
  end

  //single cycle

  assign dcif.ihit = (dcif.imemREN) ? ~ccif.iwait[CPUID] : 0;
  assign dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~ccif.dwait[CPUID] : 0;
  assign dcif.imemload = (ccif.iwait[CPUID]) ? instr : ccif.iload[CPUID];
  assign dcif.dmemload = ccif.dload[CPUID];


  assign ccif.iREN[CPUID] = dcif.imemREN;
  assign ccif.dREN[CPUID] = dcif.dmemREN;
  assign ccif.dWEN[CPUID] = dcif.dmemWEN;
  assign ccif.dstore[CPUID] = dcif.dmemstore;
  assign ccif.iaddr[CPUID] = dcif.imemaddr;
  assign ccif.daddr[CPUID] = dcif.dmemaddr;
  */

endmodule
