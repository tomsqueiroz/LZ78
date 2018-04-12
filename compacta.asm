.data
fileCompactadoName:	.asciiz	"file.txt"
fileOriginalName:	.asciiz	"original.txt"
stringErroArquivo:	.asciiz	"Erro abertura de arquivo"
inputBuffer:		.space	1
outputBuffer:		.space	1
stringLida:		.space	64
stringValor:		.space	64
stringChave:		.space	64
stringChaveEscrever:	.space	64
stringValorEscrever:	.space	64
stringPadraoZero:	.space	2
.text

li	$v0,13
la	$a0,fileOriginalName
li	$a1,0
li	$a2,0
syscall
slt	$t2,$v0,$zero
	bne	$t2,1,iniciaLeituraCompactar	#se vo > 0, nao ha erro
	li	$v0,4
	la	$a0,stringErroArquivo
	syscall
	li	$v0,10
	syscall	

iniciaLeituraCompactar:
move	$s7,$v0	#filedescriptor
la	$s6,stringValorEscrever
loopLeituraCompactar:
	move	$a0,$s7
	li	$v0,14
	la	$a1,inputBuffer
	li	$a2,1
	syscall
	beq	$v0,$zero,fimCompacta
	slt	$t2,$v0,$zero
	bne	$t2,1,continualoopLeituraCompactar	#se vo > 0, nao ha erro
	li	$v0,4
	la	$a0,stringErroArquivo
	syscall
	li	$v0,10
	syscall	
	continualoopLeituraCompactar:
		lb	$t5,($a1)
		sb	$t5,($s6)
		addi	$sp,$sp,-8
		sw	$s7,4($sp)
		sw	$s6,($sp)
		la	$a0,stringValorEscrever
		jal	retornaIndex
		move	$t4,$v0	#recebe o index no arquivo compactado, se for -1 nao existe
		lw	$s6,($sp)		
		lw	$s7,4($sp)
		addi	$sp,$sp,8
		bne	$t4,-1,existeByteCompactado	
		#entra aqui se ainda nao existir
		addi	$s6,$s6,1
		li	$t3,'\0'
		sb	$t3,($s6)
		la	$t7,stringPadraoZero
		li	$t3,'0'
		sb	$t3,($t7)
		addi	$t7,$t7,1
		li	$t3,'\0'
		sb	$t3,($t7)
		la	$a1,stringValorEscrever
		la	$a0,stringPadraoZero
		addi	$sp,$sp,-8
		sw	$s7,4($sp)
		sw	$s6,($sp)
		jal	addArquivo
		lw	$s6,($sp)		
		lw	$s7,4($sp)
		addi	$sp,$sp,8
		la	$s6,stringValorEscrever
		j	loopLeituraCompactar
		existeByteCompactado:

fimCompacta:
	li	$v0,10
	syscall

addArquivo:	#recebe $a0 chave , $a1 valor
	move	$t0,$a0
	move	$t1,$a1
	li	$v0,13
	la	$a0,fileCompactadoName
	li	$a1, 1          
	li 	$a2, 0
	syscall
	slt	$t2,$v0,$zero
	bne	$t2,1,continuaFuncaoAdd	#se vo > 0, nao ha erro
	li	$v0,4
	la	$a0,stringErroArquivo
	syscall
	li	$v0,10
	syscall	
	continuaFuncaoAdd:
	move	$a0,$v0
	move	$s7,$v0
	li	$v0,15
	la	$a1,outputBuffer
	li	$a2,1
	li	$t3,0
	li	$t5,'('
	sb	$t5,($a1)
	syscall
	li	$v0,15
		loopFuncaoAdd:
			lb	$t5,($t0)
			sb	$t5,($a1)
			addi	$t0,$t0,1
			syscall	
			li	$v0,15
			beq	$t5,'\0',fimStringAdd
			j	loopFuncaoAdd
			fimStringAdd:
				beq	$t3,$zero,escreveVirgula
				li	$t5,')'
				sb	$t5,($a1)
				syscall
				li	$v0,16
				move	$a0,$s7
				syscall
				jr	$ra
				escreveVirgula:
					li	$t5,','
					sb	$t5,($a1)
					move	$t0,$t1
					addi	$t3,$t3,1
					syscall
					li	$v0,15
					j	loopFuncaoAdd

retornaIndex:	#recebe $a0 string a pesquisar no arquivo compactado
	move	$s3,$a0
	la	$a0,fileCompactadoName
	li	$a1,0
	li	$a2,0
	li	$v0,13
	syscall
	slt	$t1,$v0,$zero
	bne	$t1,1,continuaFuncao	#se vo > 0, nao ha erro
	li	$v0,4
	la	$a0,stringErroArquivo
	syscall
	li	$v0,10
	syscall
	continuaFuncao:
	li	$s5,0	#contador do index
	move	$s7,$v0	#salva em a0 o file descriptor
	continueFuncao:
		la	$s6,stringLida
		la	$s4,stringChave
		loopLeituraArquivo:
			move	$a0,$s7
			la	$a1,inputBuffer
			li	$v0,14
			li	$a2,1
			syscall
			beq	$v0,$zero,fimArquivo	#se v0 igual == 0 significa fim do arqvuido
			slt	$t1,$v0,$zero
			bne	$t1,1,continuaLeituraArquivo	#se vo > 0, nao ha erro
			li	$v0,4
			la	$a0,stringErroArquivo
			syscall
			li	$v0,10
			syscall
		continuaLeituraArquivo:
			lb	$t0,($a1)
			sb	$t0,($s6)
			beq	$t0,')',fimLeituraArquivo
			addi	$s6,$s6,1
			j	loopLeituraArquivo
		fimLeituraArquivo:
			la	$s6,stringLida
			la	$s2,stringValor
			loopFimLeituraArquivo:
				lb	$t0,($s6)
				addi	$s6,$s6,1
				beq	$t0,'(',pula
				beq	$t0,'\0',pula	
				sb	$t0,($s2)
				addi	$s2,$s2,1
			pula:
				beq	$t0,',',inicioString
				j	loopFimLeituraArquivo
			inicioString:
				lb	$t0,($s6)
				addi	$s6,$s6,1
				sb	$t0,($s4)
				addi	$s4,$s4,1
				beq	$t0,'\0',fimString	#trocar esse valor por \0
				j	inicioString
			fimString:
				la	$a0,stringChave
				move	$a1,$s3
				comparaString:
					lb	$t0,($a0)	#carrega da memoria um byte string1
					lb	$t1,($a1)	#carrega da memoria um byte string2	
					bne	$t0,$t1, notEqual
					beq	$t0,$t1, equal		
				notEqual:	
					addi	$s5,$s5,1
					j	continueFuncao
				equal:	
					beq	$t0,$zero,fimCompara
					addi	$a0,$a0,1
					addi	$a1,$a1,1
					j	comparaString
				fimCompara:
					move	$a0,$s7
					li	$v0,16
					syscall
					move	$v0,$s5
					jr	$ra
				fimArquivo:
					move	$a0,$s7
					li	$v0,16
					syscall
					li	$v0,-1
					jr	$ra
	
			
		
		

	

