.data
dicionario:	.asciiz	"\030\0Rafael\01\0 "                                      
palavra:	.asciiz	"Rafael"

.text

la	$a0,dicionario
li	$t0,3
sb	$t0,13($a0)
#jal	iniciaDicionario
la	$a1,palavra
jal	getIndex

move	$a0,$v0
li	$v0,1
syscall
li	$v0,10
syscall






iniciaDicionario:	#void iniciaDicionario( $a0 == vetorString )
	move	$t0,$a0	#dicionarioString
	li	$t1,'\0'
	li	$t2,3	#caracter ETX ( end of text )
	sb	$t1,($t0)
	sb	$t2,1($t0)
	jr	$ra

getIndex:		#int getIndex( $a0 dicionario, $a1 String )	#retorna -1 se nao existe valor
	move	$t0,$a0
	move	$t1,$a1
	li	$t2,0	#contador
	loopGetIndex:
		addi	$a0,$t0,1	#prepara para chamar comparaString
		move	$a1,$a1
		addi	$sp,$sp,-12
		sw	$t0,8($sp)
		sw	$ra,4($sp)
		sw	$t2,($sp)
		jal	comparaString
		lw	$t2,($sp)
		lw	$ra,4($sp)
		lw	$t0,8($sp)
		addi	$sp,$sp,12
		beq	$v0,-1,stringsDiferentes
		move	$v0,$t2
		jr	$ra
	stringsDiferentes:
		addi	$t2,$t2,1
		addi	$sp,$sp,-8
		sw	$ra,4($sp)
		sw	$t2,($sp)
		move	$a0,$t0
		jal	goToNextString
		lw	$t2,($sp)
		lw	$ra,4($sp)
		addi	$sp,$sp,8
		move	$t0,$v0
		beq	$t0,-1,fimDicionario
		j	loopGetIndex
	fimDicionario:
		li	$v0,-1
		jr 	$ra				
							
goToNextString:		# &string goToNexxtString( $a0 memoria )	retorna -1 se acabou dicionario
	move	$t0,$a0
	loopNextString:
		addi	$t0,$t0,1
		lb	$t3,($t0)
		beq	$t3,$zero,fimLoopNextString
		j	loopNextString	
	fimLoopNextString:
		lb	$t3,($t0)
		lb	$t4,1($t0)
		beq	$t4,3,returnFimDicionario
		move	$v0,$t0
		jr	$ra
	returnFimDicionario:
		li	$v0,-1
		jr	$ra
		
comparaString:	#coloca em $v0 1 se forem iguais e -1 se forem diferentes
	lb	$t0,($a0)	#carrega da memoria um byte string1
	lb	$t1,($a1)	#carrega da memoria um byte string2	
	bne	$t0,$t1, notEqual
	beq	$t0,$t1, equal		
notEqual:	
	li	$v0,-1
	jr	$ra
equal:	
	beq	$t0,$zero,fimCompara
	addi	$a0,$a0,1
	addi	$a1,$a1,1
	j	comparaString
fimCompara:
	li	$v0,1
	jr	$ra
	
	