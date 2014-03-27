/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
`include "register_file_if.vh"
`include "alu_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;

  // program counter
  word_t pc, nextPc;
  logic dEN;
  logic goToNextPC;

  // Extended signal
  word_t ext;

  // Signals derived from imemload
  opcode_t op;
  funct_t funct;
  logic [4:0] rs, rt, rd, rw;
  logic [15:0] imm16;
  logic [25:0] inst;
  logic [31:0] instruction;
  logic [4:0] shiftAmnt;
  
  // Hazard unit Signals
  logic clearIfid, clearIdex, useExmem, useMemwb, jumping;

  // Signals from flagger
  aluop_t aluOp;
  logic regDst, aluSrc, memToReg, regW, memW, pcSrc, branchEq, branchNe, jump, jumpr, jal, extOp, luiOp, shift, halt, superHalt;

  // ALU Signals
  word_t portA, portB, outPort;
  logic negF, zerF, oveF;

  // register file interface
  register_file_if rfif();
  // map register
  register_file RF(CLK, nRST, rfif);
  
  // PIPELINE SIGNALS
  // IF/ID
  logic [31:0] ifid_pc, ifid_instruction;
  // ID/EX
  logic [31:0] idex_pc, idex_busA, idex_busB, idex_ext;
  logic [25:0] idex_inst;
  logic [4:0]  idex_rw, idex_rs, idex_rt, idex_shiftAmnt;
  aluop_t idex_aluOp;
  logic idex_regW, idex_luiOp, idex_aluSrc, idex_branchNe, idex_branchEq, idex_memToReg, idex_memW, idex_jump, idex_jumpr, idex_jal, idex_shift, idex_halt;
  // EX/MEM
  logic [31:0] exmem_pc, exmem_busA, exmem_busB, exmem_outPort, exmem_ext;
  logic [25:0] exmem_inst;
  logic [4:0]  exmem_rw;
  logic exmem_regW, exmem_memToReg, exmem_memW, exmem_pcSrc, exmem_jump, exmem_jumpr, exmem_jal, exmem_halt;
  // MEM/WB
  logic [31:0] memwb_pc, memwb_busA, memwb_ext, memwb_dmemload, memwb_outPort;
  logic [25:0] memwb_inst;
  logic [4:0]  memwb_rw;
  logic memwb_memToReg, memwb_regW, memwb_pcSrc, memwb_jump, memwb_jumpr, memwb_jal, memwb_halt;
  
  // PIPELINE REGISTERS
  always_ff @(posedge CLK, negedge nRST)
  begin
    if(!nRST)
    begin
      ifid_pc           <= '0;
      ifid_instruction  <= '0;
      
      idex_pc           <= '0;
      idex_busA         <= '0;
      idex_busB         <= '0;
      idex_ext          <= '0;
      idex_inst         <= '0;
      idex_rw           <= '0;
      idex_rs           <= '0;
      idex_rt           <= '0;
      idex_shiftAmnt    <= '0;
      idex_regW         <= 0;
      idex_luiOp        <= 0;
      idex_aluSrc       <= 0;
      idex_branchNe     <= 0;
      idex_branchEq     <= 0;
      idex_aluOp        <= aluop_t'(0);
      idex_memToReg     <= 0;
      idex_memW         <= 0;
      idex_jump         <= 0;
      idex_jumpr        <= 0;
      idex_jal          <= 0;
      idex_shift        <= 0;
      idex_halt         <= 0;

      exmem_pc          <= '0;
      exmem_busA        <= '0;
      exmem_busB        <= '0;
      exmem_outPort     <= '0;
      exmem_ext         <= '0;
      exmem_inst        <= '0;
      exmem_rw          <= '0;
      exmem_regW        <= 0;
      exmem_memToReg    <= 0;
      exmem_memW        <= 0;
      exmem_pcSrc       <= 0;
      exmem_jump        <= 0;
      exmem_jumpr       <= 0;
      exmem_jal         <= 0;
      exmem_halt        <= 0;

      memwb_pc          <= '0;
      memwb_busA        <= '0;
      memwb_outPort     <= '0;
      memwb_ext         <= '0;
      memwb_dmemload    <= '0;
      memwb_inst        <= '0;
      memwb_rw          <= '0;
      memwb_memToReg    <= 0;
      memwb_regW        <= 0;
      memwb_pcSrc       <= 0;
      memwb_jump        <= 0;
      memwb_jumpr       <= 0;
      memwb_jal         <= 0;
      memwb_halt        <= 0;  
    end
    else
    begin
      ifid_pc           <= (clearIfid) ? '0 : pc;
      ifid_instruction  <= (clearIfid) ? '0 : instruction;
      
      idex_pc           <= (clearIdex) ? '0 : ifid_pc;
      idex_busA         <= (clearIdex) ? '0 : (memwb_regW & memwb_rw == rs) ? memwb_outPort : (idex_regW & idex_rw == rs) ? outPort : rfif.rdat1;
      idex_busB         <= (clearIdex) ? '0 : (memwb_regW & memwb_rw == rt) ? memwb_outPort : (idex_regW & idex_rw == rt) ? outPort : rfif.rdat2;
      idex_ext          <= (clearIdex) ? '0 : ext;
      idex_rw           <= (clearIdex) ? '0 : rw;
      idex_rs           <= (clearIdex) ? '0 : rs;
      idex_rt           <= (clearIdex) ? '0 : rt;
      idex_shiftAmnt    <= (clearIdex) ? '0 : shiftAmnt;
      idex_inst         <= (clearIdex) ? '0 : inst;
      idex_regW         <= (clearIdex) ? 0 : regW;
      idex_luiOp        <= (clearIdex) ? 0 : luiOp;
      idex_aluSrc       <= (clearIdex) ? 0 : aluSrc;
      idex_branchNe     <= (clearIdex) ? 0 : branchNe;
      idex_branchEq     <= (clearIdex) ? 0 : branchEq;
      idex_aluOp        <= (clearIdex) ? aluop_t'(0) : aluOp;
      idex_memToReg     <= (clearIdex) ? 0 : memToReg;
      idex_memW         <= (clearIdex) ? 0 : memW;
      idex_jump         <= (clearIdex) ? 0 : jump;
      idex_jumpr        <= (clearIdex) ? 0 : jumpr;
      idex_jal          <= (clearIdex) ? 0 : jal;
      idex_shift        <= (clearIdex) ? 0 : shift;
      idex_halt         <= (clearIdex) ? 0 : halt;

      exmem_pc          <= (useExmem) ? idex_pc          : '0;
      exmem_busA        <= (useExmem) ? idex_busA        : '0;
      exmem_busB        <= (useExmem) ? idex_busB        : '0;
      exmem_outPort     <= (useExmem) ? outPort          : '0;
      exmem_ext         <= (useExmem) ? idex_ext         : '0;
      exmem_inst        <= (useExmem) ? idex_inst        : '0;
      exmem_rw          <= (useExmem) ? idex_rw          : '0;
      exmem_regW        <= (useExmem) ? idex_regW        : 0;
      exmem_memToReg    <= (useExmem) ? idex_memToReg    : 0;
      exmem_memW        <= (useExmem) ? idex_memW        : 0;
      exmem_pcSrc       <= (useExmem) ? pcSrc            : 0;
      exmem_jump        <= (useExmem) ? idex_jump        : 0;
      exmem_jumpr       <= (useExmem) ? idex_jumpr       : 0;
      exmem_jal         <= (useExmem) ? idex_jal         : 0;
      exmem_halt        <= (clearIdex) ? 0 : idex_halt;

      memwb_pc          <= (useMemwb) ? exmem_pc         : idex_pc;
      memwb_busA        <= (useMemwb) ? exmem_busA       : idex_busA;
      memwb_outPort     <= (useMemwb) ? exmem_outPort    : outPort;
      memwb_ext         <= (useMemwb) ? exmem_ext        : idex_ext;
      memwb_inst        <= (useMemwb) ? exmem_inst       : idex_inst;
      memwb_rw          <= (useMemwb) ? exmem_rw         : idex_rw;
      memwb_dmemload    <= (useMemwb) ? dpif.dmemload    : '0;
      memwb_memToReg    <= (useMemwb) ? exmem_memToReg   : idex_memToReg;
      memwb_regW        <= (useMemwb) ? exmem_regW       : idex_regW;
      memwb_jal         <= (useMemwb) ? exmem_jal        : idex_jal;
      memwb_halt        <= exmem_halt;    // This is the halt signal that will be sent out
    end  
  end  
  // PIPELINE REGISTERS
  
  // HAZARD UNIT
  assign superHalt = (halt | idex_halt | exmem_halt | memwb_halt); // Prevents reading bad instructions
  assign useExmem = (~exmem_pcSrc & (idex_memW | idex_memToReg | pcSrc | jumping | exmem_regW));
  assign useMemwb = (useExmem | exmem_memW | exmem_memToReg | exmem_jal);
//  assign useMemwb = (exmem_regW);
  assign jumping = (idex_jump | idex_jumpr | idex_jal | exmem_jump | exmem_jumpr | exmem_jal);
  assign clearIfid = (dEN | superHalt | exmem_pcSrc | jumping);
  assign clearIdex = (exmem_pcSrc | jumping);
  // HAZARD UNIT

//Hazard_Detection
/*
  Hazard_Detection Hazard_Detection(
    .IFIDRegRs          (rs),
    .IFIDRegRt          (rt),
    .IDEXMemRead        (0),//(idex_memW),//not sure
    .IDEXRegDST         (idex_rw),
  //.Branch             (branchEq),
    .IDEXRegWrite       (idex_regW),
    .Stall              (Stall),
    .CLK                (CLK),
    .nRST               (nRST)
);*/



  // ALU
  alu ALU_DUT(
  .portA(portA),
  .portB(portB),
  .aluop(idex_aluOp),
  .outPort(outPort),
  .negF(negF),
  .zerF(zerF),
  .oveF(oveF)
  );
   

/*
  alu_if aif();
  
  alu ALU_DUT(aif);
  assign aif.portA = portA;
  assign aif.portB = portB;
  assign aif.aluop = idex_aluOp;
  assign outPort = aif.outPort;
  assign negF = aif.negF;
  assign zerf = aif.zerF;
  assign oveF = aif.oveF;
*/


  // CONTROL UNIT
  flagger FLAGGER_DUT(
  .instruction(ifid_instruction),
  .aluOp(aluOp),
  .regDst(regDst),
  .aluSrc(aluSrc),
  .memToReg(memToReg),
  .regW(regW),
  .memW(memW),
  .branchEq(branchEq),
  .branchNe(branchNe),
  .jump(jump),
  .jumpr(jumpr),
  .jal(jal),
  .extOp(extOp),
  .luiOp(luiOp),
  .shift(shift),
  .halt(halt)
  );  
  assign pcSrc = (idex_branchEq & zerF) ? 1 : (idex_branchNe & ~zerF) ? 1 : 0;
    
  assign op[5:0] = ifid_instruction[31:26];
  assign rs = ifid_instruction[25:21];
  assign rt = ifid_instruction[20:16];
  assign rd = ifid_instruction[15:11];
  assign imm16 = ifid_instruction[15:0];
  assign funct[5:0] = ifid_instruction[5:0];
  assign inst = ifid_instruction[25:0];
  assign shiftAmnt = ifid_instruction[10:6];
  // CONTROL UNIT

  // PC UNIT
  always_ff @(posedge CLK, negedge nRST)
  begin
    if(!nRST)
      pc <= PC_INIT;
    else
    begin
      if(goToNextPC)
        pc <= nextPc;
      else
        pc <= pc;
    end
  end
  
  
  //working version
  /*
  assign nextPc = (exmem_jump) ? {exmem_pc[31:28],exmem_inst << 2} : (exmem_jumpr) ? exmem_busA : (exmem_pcSrc) ? (exmem_ext << 2) + exmem_pc : pc + 4;  
  assign goToNextPC = (exmem_pcSrc) ? 1 : ~(idex_memToReg | idex_memW);
  */
  
  
  logic jump_idex,jumpr_idex,pcSrc_exmem,memToReg_idex,memW_idex;
  word_t pc_idex,pc_exmem,busA_idex,ext_idex;
  logic [25:0] inst_idex;
  
  //assign jump_idex = (clearIdex) ? 0 : jump;
  //assign pc_idex = (clearIdex) ? '0 : ifid_pc;
  //assign pc_exmen = (useExmem) ? idex_pc : '0;
  //assign inst_idex = (clearIdex) ? '0 : inst;
  //assign jumpr_idex = (clearIdex) ? 0 : jumpr;
  assign busA_idex = (memwb_regW & memwb_rw == rs) ? memwb_outPort : (idex_regW & idex_rw == rs) ? outPort : rfif.rdat1;
  //assign pcSrc_exmem = (useExmem) ? pcSrc : 0;
  //assign ext_exmem = (useExmem) ? idex_ext : '0;
  //assign memToReg_idex = (clearIdex) ? 0 : memToReg;
  //assign memW_idex = (clearIdex) ? 0 : memW;
  
  assign nextPc = (idex_jump) ? {idex_pc[31:28],idex_inst << 2} : (jumpr) ? busA_idex : (pcSrc) ? (idex_ext << 2) + idex_pc : pc + 4;  
  assign goToNextPC = (exmem_pcSrc) ? 1 : ~(idex_memToReg | idex_memW);
  
  // PC UNIT

  // REQUEST UNIT
  always_ff @(posedge CLK, negedge nRST)
  begin
    if(!nRST)
    begin
      dEN <= 0;
      instruction <= '0;
    end
    else
    begin
      if(dpif.ihit | dpif.dhit)
      begin
        dEN <= (exmem_pcSrc) ? 0 : (idex_memToReg | idex_memW);
        if(clearIdex)
          instruction <= '0;
        else if(idex_memToReg | idex_memW)
          instruction <= instruction;
        else
          instruction <= dpif.imemload;
      end
      else
      begin
        dEN <= dEN;
        instruction <= instruction;
      end
    end
  end

  assign dpif.dmemREN = (dEN) ? exmem_memToReg : 0;
  assign dpif.dmemWEN = (dEN) ? exmem_memW : 0;
  assign dpif.imemREN = 1;
  // REQUEST UNIT

  // Register signals
  assign rw = (jal) ? 5'b11111 : (regDst) ? rd : rt; // Sent into pipeline
  assign rfif.wsel = memwb_rw;
  assign rfif.rsel1 = rs;
  assign rfif.rsel2 = rt;
  assign rfif.WEN = memwb_regW;
  assign rfif.wdat = (memwb_jal) ? memwb_pc : (memwb_memToReg) ? memwb_dmemload : memwb_outPort;

  // ALU port signals
  assign portA = (memwb_memToReg & idex_rs == memwb_rw) ? memwb_dmemload : (exmem_memToReg & idex_rs == exmem_rw) ? dpif.dmemload : (idex_luiOp) ? idex_ext : idex_busA;
  assign portB = (memwb_memToReg & idex_rt == memwb_rw) ? memwb_dmemload : (exmem_memToReg & idex_rt == exmem_rw) ? dpif.dmemload : (idex_luiOp) ? 16  : (idex_aluSrc) ? idex_ext : (idex_shift) ? idex_shiftAmnt : idex_busB;

  // Extended signal
  assign ext = (extOp) ? {{16{imm16[15]}}, imm16} : {16'h0000, imm16};

  // Datapath Outputs
  assign dpif.halt = memwb_halt;
  assign dpif.imemaddr = pc;
  assign dpif.datomic = 0; // No idea what this is supposed to do
  assign dpif.dmemstore = exmem_busB;
  assign dpif.dmemaddr = exmem_outPort;

endmodule
 
