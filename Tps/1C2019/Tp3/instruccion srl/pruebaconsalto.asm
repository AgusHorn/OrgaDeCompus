
addi $t0,$zero,80
li $t1,80
beq $t0,$t1,SRL_OP
srl $t0,$t0,15


SRL_OP:
srl $t0,$t0,1
srl $t0,$t0,2
