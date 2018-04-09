.data
fileIN:		.asciiz	"(123,AAVAV)"
fileNumero:	.asciiz	                                        
fileString:	.asciiz	

.text

la	$t0, fileIN 	# endereo do comeco do arquivo passado para $a0	
la 	$t1, fileNumero
la	$t2, fileString
addi	$sp,$sp,-12
sw	$t0, 8($sp)
sw	$t1, 4($sp)
sw	$t2, ($sp)
jal 	parseLoad			


parseLoad: 	# tira a vircgula e os parenteses do sting
	lw	$t2,($sp)	#endereco para vetorString	
	lw	$t1,4($sp)	#endereco para vetorNumero
	lw	$t0,8($sp)	#endereco do vetor de entrada
	addi	$sp,$sp,12
parse:	 
	lb $t3, 0($t0)
	addi $t0, $t0, 1
	beqz $t3, endDescaca
	beq $t3, '(',Pulo
	beq $t3, ',',puloMudaVetor
	beq $t3, ')',Pulo
	sb $t3, 0($t1)
	addi $t1, $t1, 1
	Pulo: j parse
	
puloMudaVetor:
	move	$t1,$t2		#quando encontrar a virgula, muda para o vetor de string
	j	parse
	
endDescaca:
	li $v0, 4
	la $a0, fileString
	syscall

