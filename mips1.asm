.data

fileCompactadoName:	.asciiz	"compactado.txt"
fileOriginalName:	.asciiz	"original.txt"
stringErroArquivo:	.asciiz	"Erro abertura de arquivo"
bufferLeituraArquivo:	.space	1
stringLida:		.space	64
stringValor:		.space	64
stringChave:		.space	64
string:			.asciiz	"R"

.text
la	$a0,string
jal	retornaIndex
move	$a0,$v0
li	$v0,1
syscall
li	$v0,10
syscall



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
	li	$s5,0	#contador do index
	move	$s7,$v0	#salva em a0 o file descriptor
	continuaFuncao:
		la	$s6,stringLida
		la	$s4,stringChave
		loopLeituraArquivo:
			li	$v0,14
			move	$a0,$s7
			la	$a1,bufferLeituraArquivo
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
				sb	$t0,($s2)
				pula:
				beq	$t0,',',inicioString
				j	loopFimLeituraArquivo
			inicioString:
				lb	$t0,($s6)
				addi	$s6,$s6,1
				sb	$t0,($s4)
				addi	$s4,$s4,1
				beq	$t0,')',fimString	#trocar esse valor por \0
				j	inicioString
			fimString:
				addi	$s4,$s4,-1		#RETIRAR LINHA
				sb	$zero,($s4)		#RETIRAR LINHA - servem apenas para trocar o ) por \0
				la	$a0,stringChave
				move	$a1,$s3
				comparaString:
					lb	$t0,($a0)	#carrega da memoria um byte string1
					lb	$t1,($a1)	#carrega da memoria um byte string2	
					bne	$t0,$t1, notEqual
					beq	$t0,$t1, equal		
				notEqual:	
					addi	$s5,$s5,1
					j	continuaFuncao
				equal:	
					beq	$t0,$zero,fimCompara
					addi	$a0,$a0,1
					addi	$a1,$a1,1
					j	comparaString
				fimCompara:
					move	$v0,$s5
					jr	$ra
				fimArquivo:
					li	$v0,-1
					jr	$ra
	
			
		
		

	

