.data
	pergunta: .asciiz "O que você deseja escrever no arquivo?\n" 
	conteudoArq: .space 1024 
	localArq: .asciiz "miniDB.txt"
.text
	la $a0, pergunta
	jal imprimirString
	jal lerString
	
	move $s0, $a0
	
	jal strLen #conta a quantidade de caracteres em uma cadeia
	
	move $s1, $v0 #quantidade 
	subi $s1, $s1, 1
	
	li $v0, 1
	move $a0, $s1
	syscall 
	
	jal arquivoEscrever
	
	
	li $v0, 10
	syscall 
	
	arquivoEscrever:
		li $v0, 13
		la $a0, localArq
		li $a1, 1 #modo escrita
		syscall #o descritor é salvo em $v0
	
		move $s0, $v0
		move $a0, $v0
	
		#escrevendo no arquivo
		#o descritor deve estar em $a0
		li $v0, 15 
		la $a1, conteudoArq
		move $a2, $s1
		syscall 
	
		#fechar o arquivo
		li $v0, 16
		move $a0, $s0
		syscall
		
		jr $ra
	
	#------------------------------------------
	
	imprimirString:
		li $v0, 4 
		syscall 
		
		jr $ra
		
	#------------------------------------------
	
	lerString:
		li $v0, 8
		la $a0, conteudoArq
		li $a1, 1024
		syscall 
		
		jr $ra
		
	#------------------------------------------
	
	
	strLen:
		move $t0, $a0 #endereço da palavra
		li $v0, 0 #contador
		loop:
			lb $t1, 0($t0)
			beq $t1, $zero, end
			addi $v0, $v0, 1
			addi $t0, $t0, 1
		
			j loop
		end:
			jr $ra
	
