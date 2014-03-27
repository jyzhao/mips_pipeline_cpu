`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module flagger (
  input word_t instruction,
	output aluop_t aluOp,
	output logic regDst, aluSrc, memToReg, regW, memW, branchEq, branchNe, jump, jumpr, jal, extOp, luiOp, shift, halt
);
opcode_t op;
funct_t funct;

assign shift = (op == RTYPE & (aluOp == ALU_SLL | aluOp == ALU_SRL));
assign op[5:0] = instruction[31:26];
assign funct[5:0] = instruction[5:0];

// extOp => 1 means SignExt
// extOp => 0 means ZeroExt

always_comb
begin
  if(instruction == 0)
  begin
	  regDst 		= 0;
	  aluSrc 		= 0;
	  memToReg 	= 0;
	  regW 		  = 0;
	  memW 		  = 0;
	  branchEq 	= 0;
	  branchNe 	= 0;
	  jump 	  	= 0;
	  jumpr     = 0;
	  jal       = 0;
	  extOp 		= 0;
	  luiOp 		= 0;
	  halt 		  = 0;
	  aluOp 		= ALU_ADD;  
  end
  else
  begin
	  regDst 		= 0;
	  aluSrc 		= 0;
	  memToReg 	= 0;
	  regW 		  = 0;
	  memW 		  = 0;
	  branchEq 	= 0;
	  branchNe 	= 0;
	  jump 		  = 0;
	  jumpr     = 0;
	  jal       = 0;
	  extOp 	  = 0;
	  luiOp 	  = 0;
	  halt 		  = 0;
			  
	  unique casez (op)
		  RTYPE: begin
			  regDst 	= 1;
			  regW 		= 1;			

			  unique casez (funct)
				  SLL:  aluOp = ALU_SLL;
				  SRL:  aluOp = ALU_SRL;
				  JR:   begin
				    aluOp = ALU_ADD;
				    jumpr = 1;
				    regW  = 0;
				  end
				  ADD:  aluOp = ALU_ADD; // Unused
				  ADDU: aluOp = ALU_ADD;
				  SUB:  aluOp = ALU_SUB; // Unused
				  SUBU: aluOp = ALU_SUB;
				  AND:  aluOp = ALU_AND;
				  OR:   aluOp = ALU_OR;
				  XOR:  aluOp = ALU_XOR;
				  NOR:  aluOp = ALU_NOR;
				  SLT:  aluOp = ALU_SLT;
				  SLTU: aluOp = ALU_SLTU;
				  default: aluOp = ALU_ADD;
			  endcase
		  end
		  J: begin
			  jump 		= 1;
			  aluOp 	= ALU_ADD;
		  end
		  JAL: begin
			  regW 		= 1;
			  jump 		= 1;
			  jal     = 1;
			  aluOp 	= ALU_ADD;
		  end
		  BEQ: begin
			  branchEq 	= 1;
			  extOp 		= 1;
			  aluOp 		= ALU_SUB;
		  end
		  BNE: begin
			  branchNe 	= 1;
			  extOp 		= 1;
			  aluOp 		= ALU_SUB;
		  end
		  ORI: begin
			  aluSrc 		= 1;
			  regW 		  = 1;
			  aluOp 		= ALU_OR;
		  end
		  XORI: begin
			  aluSrc 		= 1;
			  regW 		  = 1;
			  aluOp 		= ALU_XOR;
		  end
		  ANDI: begin
			  aluSrc 		= 1;
			  regW 		  = 1;
			  aluOp 		= ALU_AND;
		  end
		  ADDI: begin // Not Used
			  aluSrc 		= 1;
			  regW 		  = 1;
			  extOp 		= 1;
			  aluOp 		= ALU_ADD;
		  end
		  ADDIU: begin
			  aluSrc 		= 1;
			  regW 		  = 1;
			  extOp 		= 1;
			  aluOp 		= ALU_ADD;
		  end
		  SLTI: begin
			  aluSrc 		= 1;
			  regW 		  = 1;
			  extOp 		= 1;
			  aluOp 		= ALU_SLT;		
		  end
		  SLTIU: begin
			  aluSrc 		= 1;
			  regW 		  = 1;
			  extOp 		= 1;
			  aluOp 		= ALU_SLTU;		
		  end
		  LUI: begin // Load Upper Immediate
			  aluSrc 		= 1;
			  regW 		  = 1;
			  luiOp 		= 1;
			  aluOp 		= ALU_SLL;
		  end
		  LW: begin
			  aluSrc 		= 1;
			  memToReg 	= 1;
			  regW 		  = 1;
			  extOp 		= 1;
			  aluOp 		= ALU_ADD;
		  end
		  SW: begin
			  aluSrc 		= 1;
			  memW 		  = 1;
			  extOp 		= 1;
			  aluOp 		= ALU_ADD;
		  end
		  HALT: begin
			  halt 		  = 1;
			  aluOp 		= ALU_ADD;
		  end
      default: begin
			  aluOp 		= ALU_ADD;
		  end
	  endcase
	end
end

endmodule
