#initial operands stored in t0(R8),t1(R9)
#result stored in t2(R10)
#loop control variable stored in s0(R16)


	org		0x0000			#program starts at 0x0000
	ori		$sp, $zero, 0xFFFC	#initialize stack to address 0xFFFC



addi $t0,$zero,2	#set operand 1 to 2
addi $t1,$zero,3	#set operand 2 to 4
addi $t3,$zero,4	#set operand 3 to 6

addi $t4,$zero,1

START:

add $s0,$zero,$zero	#set $s0 to 0

PUSH $t0		#push t0 to stack
PUSH $t1		#push t1 to stack



addu $t2,$zero,$zero	#initialize result to 0

POP $t1			#pop t1 from stack
POP $t0			#pop t0 from stack

beq $t0,$zero,ZERO	#if one of the operands is zero, then the result is zero
beq $t1,$zero,ZERO



LOOP:

	
	slt $s1,$t1,$s0		#if t1 is less than s0, then set s1 to 1, otherwise 0
	beq $zero,$s1,MULT	#if s1 is 0, then branch to MULT
	j DONE			#if s1 is not 0, then jump to DONE

MULT:
	addu $t2,$t2,$t0	#add t0 to t2
	addi $s0,$s0,1		#increase loop control variable s0 by 1
	j LOOP			#go to loop
	

ZERO:				
	add $t2,$zero,$zero	#set result to 0
	j DONE			#jump to DONE
	
DONE:
	subu $t2,$t2,$t0	#take off one extra addition
	beq $t4,$zero,END
	
addu $t0,$zero,$t2
addu $t1,$zero,$t3
addu $t4,$zero,$zero
j START
	
END:
	PUSH $t2
	
	halt


