	org		0x0000
	
#reset	
addi		$14, $zero, 0
addi		$16, $zero, 0
addi		$17, $zero, 0
addi		$18, $zero, 0
addi		$27, $zero, 0
addi		$26, $zero, 0
addi    	$28, $zero, 0
addi		$15, $zero, 0
addi		$2, $zero, 0
addi		$3, $zero, 0
addi		$4, $zero, 0
addi		$5, $zero, 0
addi		$6, $zero, 0
	
	
ori		$sp, $zero, 0x3FFC
ori		$16, $zero, 2014 #current year
ori		$17, $zero, 1 #current month
ori		$18, $zero, 20 #current day
ori		$27, $zero, 4 #stack pointer increment/decrement

#Days = CurrentDay + (30 * (CurrentMonth - 1)) + 365 * (CurrentYear - 2000)) 
	
ori  $28, $zero, 1	#set $28 to 1
subu $17, $17, $28	#(current month - 1)
ori  $28, $zero, 2000	#set $28 to 2000
subu $16, $16, $28	#(current year - 1)
ori  $28, $zero, 30	#set $28 to 30
	
  subu $sp, $sp, $27	#decrement stack pointer by 4
  sw $17, 0($sp)	#store $17 to stack pointer with 0 offset, month
  subu $sp, $sp, $27	#decrement stack pointer by 4
  sw $28, 0($sp)	#store $28 to stack pointer with 0 offset, year
  jal MULT		#jump and link to subroutine MULT
  
  lw $26, 0($sp)	#load content at stack pointer with offset 0 to $26
  addiu $sp, $sp, 4	#increment stack pointer by 4
  
  addu $26, $26, $18	#$26 = $26 + current day
  
  addi $28, $zero, 365	#set 28 to 365
  subu $sp, $sp, $27	#decrement stack pointer by 4
  sw $16, 0($sp)	#store $16, current year to stack pointer with offset 0
  subu $sp, $sp, $27	#decrement stack pointer by 4
  sw $28, 0($sp)	#store $28, 365 to stack pointer with offset 0
  jal MULT		#jump and link to MULT
  
  lw $25, 0($sp)	#load content at stack pointer with offset 0 to $25
  addiu $sp, $sp, 4	#increment stack pointer by 4
	
  addu $26, $26, $25	
	
  sw 		$26, 0($sp)
	
	#addu  $sp, $sp, $27
	#sw		$26, 0($sp)
	halt
	
	
	
	org 0x0800
	
MULT:
  lw	$15, 0($sp)
  addiu $sp, $sp, 4
  lw 	$2, 0($sp)
  addiu $sp, $sp, 4
 
  or	$3, $zero, $zero
  ori 	$4, $zero, 1 #compare value in reg4
  or 	$5, $zero, $15 #load opA into reg5, will shift
  and 	$6, $zero, $6 #clear reg6 - will hold next bit for comp.

lbeg: 
  beq 	$2, $zero, done
  and	$6, $2, $4 #load first bit into reg
  srl 	$2, $2, 1 #shift opB to the right (clear bit used)
  beq 	$6, $4, ones
  j	MOVE
  
ones: 
	addu 	$3, $3, $5
MOVE: 
	sll 	$5, $5, 1
	j lbeg
done: 
	ori 	$14, $zero, 4
	subu 	$sp, $sp, $14 
  	sw 	$3, 0($sp) 
  	jr	$31
	
