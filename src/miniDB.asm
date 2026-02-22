.data
    #java -jar Mars4_5.jar sm src/miniDB.asm 
    # Constantes
    MAX_REGISTROS: .word 100
    TAM_REGISTRO: .word 16
    QTD_REGISTROS: .word 0
    
    # Banco de registros
    BANCO: .space 1600 # 100 * 16 = 1600 bytes
    
    # Strings do menu
    menu: .asciiz "\nSistema de Gerenciamento de Registros\nEscolha uma opção \n1 - Inserir\n2 - Listar\n3 - Buscar\n4 - Remover\n0 - Sair\nOpção: "
    msg_cheio: .asciiz "Banco de dados cheio, não é possível adicionar mais registros!\n"
    msg_invalido: .asciiz "Opção inválida!\n"

    msg_busca_id: .asciiz "Digite o ID para buscar: "
    msg_busca_sucesso: .asciiz "Registro encontrado:\n"
    msg_busca_nao_encontrado: .asciiz "Registro não encontrado ou inativo.\n"
    msg_id: .asciiz "\nID: "
    msg_idade: .asciiz "Idade: "
    msg_matricula: .asciiz "Matrícula: "

    msg_remover_id: .asciiz "Digite o ID para remover: "
    msg_remover_sucesso: .asciiz "Registro removido com sucesso!\n"
    msg_remover_nao_encontrado: .asciiz "ID não encontrado.\n"
    msg_remover_ja_inativo: .asciiz "Registro já está inativo.\n"

.text
.globl main

# ===== Inicialização =====
main:
    la $s0, BANCO	# base do banco
    lw $s1, QTD_REGISTROS	# QTD_REGISTROS = 0
    lw $s2, MAX_REGISTROS	# MAX_REGISTROS = 100
    lw $s3, TAM_REGISTRO # TAM_REGISTRO
   
# ===== Menu ===== 
loop_menu:
    # Exibir menu
    li $v0, 4
    la $a0, menu
    syscall
        
    # Ler opção
    li $v0, 5
    syscall
    move $t0, $v0
        
    beq $t0, 1, chamar_inserir
    beq $t0, 2, chamar_listar
    beq $t0, 3, chamar_busca
    beq $t0, 4, chamar_remocao
    beq $t0, 0, sair
        
    #li $v0, 4
    #la $a0, msg_invalido
    #syscall
    #j loop_menu

# Labels para chamar funções e voltar
chamar_inserir:
    jal inserir
    j loop_menu
    
chamar_listar:
    jal listar
    j loop_menu   
    
chamar_busca:
    jal buscar_registro
    j loop_menu

chamar_remocao:
    jal remover_registro
    j loop_menu

# ===== Inserção =====
inserir:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    beq $s1, $s2, banco_cheio # verifica se qtd == max
    
    mul  $t0, $s1, $s3     # índice * TAM_REGISTRO
    add  $t0, $t0, $s0    # base + deslocamento
    
    jal ler_dados
    move $a0, $s1
    addi $a0, $a0, 1
    
    sw $a0, 0($t0) # ID
    sw $a1, 4($t0) # IDADE
    sw $a2, 8($t0) # MATRÍCULA
    li $t1, 1
    sw $t1, 12($t0) # ATIVO = 1
    
    addi $s1, $s1, 1
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra 
    
ler_dados:
    li $v0, 4
    la $a0, msg_idade
    syscall  

    li $v0, 5
    syscall 
    move $a1, $v0

    li $v0, 4
    la $a0, msg_matricula
    syscall  

    li $v0, 5
    syscall 
    move $a2, $v0

    jr $ra

# ===== Listagem =====
listar:
    li $t0, 0
    loop_listar:
        beq $t0, $s1, fim_listagem
        mul $t1, $t0, $s3
        add $t1, $t1, $s0
        lw  $t2, 12($t1)
        beq $t2, $zero, proximo
    
        #id
        li $v0, 4
        la $a0, msg_id
        syscall 
        li $v0, 1
        lw $a0, 0($t1)
        syscall 
    
        li $v0, 11
        li $a0, '\n'
        syscall    
    
        #idade
        li $v0, 4
        la $a0, msg_idade
        syscall 
        li $v0, 1
        lw $a0, 4($t1)
        syscall 
    
        li $v0, 11
        li $a0, '\n'
        syscall    
    
        #matricula
        li $v0, 4
        la $a0, msg_matricula
        syscall 
        li $v0, 1
        lw $a0, 8($t1)
        syscall  
    
        li $v0, 11
        li $a0, '\n'
        syscall    
        
    proximo:
        addi $t0, $t0, 1
        j loop_listar   
    fim_listagem:
        jr $ra

banco_cheio:
	li $v0, 4
	la $a0, msg_cheio
	syscall 
	
	j loop_menu

# ===== Busca =====
buscar_registro:
    li $v0, 4
    la $a0, msg_busca_id
    syscall
    
    # Ler ID
    li $v0, 5
    syscall
    move $t0, $v0        # $t0 = ID procurado
    
    # Carregar quantidade de registros
    move $t1, $s1     # $t1 = número total de registros
    
    beq $t1, $zero, busca_nao_encontrado
    
    li $t2, 0            # $t2 = índice atual (contador)
    
    # Carregar endereço base
    move $t3, $s0  # $t3 = endereço base
    
    busca_loop:
        # Calcular offset: índice * 16
        mul $t4, $t2, $s3      # $t4 = offset
        add $t5, $t3, $t4     # $t5 = endereço do registro atual
        
        # Verificar se está ativo
        lw $t6, 12($t5)       # carrega campo ATIVO
        beq $t6, 0, busca_proximo  # se inativo, pula
        
        # Verificar ID
        lw $t6, 0($t5)        # carrega ID
        beq $t6, $t0, busca_encontrado  # se ID igual, encontrou
        
    busca_proximo:
        addi $t2, $t2, 1      # incrementa contador
        blt $t2, $t1, busca_loop  # se contador < qtd_registros, continua
        j busca_nao_encontrado  # se terminou o loop sem encontrar
    
    busca_encontrado:
        li $v0, 4
        la $a0, msg_busca_sucesso
        syscall
        
        # Exibir ID
        li $v0, 4
        la $a0, msg_id
        syscall
        lw $a0, 0($t5)
        li $v0, 1
        syscall
        li $v0, 11
        li $a0, 10            # newline
        syscall
        
        # Exibir Idade
        li $v0, 4
        la $a0, msg_idade
        syscall
        lw $a0, 4($t5)
        li $v0, 1
        syscall
        li $v0, 11
        li $a0, 10
        syscall
        
        # Exibir Matrícula
        li $v0, 4
        la $a0, msg_matricula
        syscall
        lw $a0, 8($t5)
        li $v0, 1
        syscall
        li $v0, 11
        li $a0, 10
        syscall
        
        j busca_fim
    
    busca_nao_encontrado:
        li $v0, 4
        la $a0, msg_busca_nao_encontrado
        syscall
    
    busca_fim:
        jr $ra    # Retorna para chamar_busca

# ===== Remoção =====
remover_registro:
    # Pedir ID para remoção
    li $v0, 4
    la $a0, msg_remover_id
    syscall
    
    # Ler ID
    li $v0, 5
    syscall
    move $t0, $v0        # $t0 = ID a remover
    
    # Carregar quantidade de registros
    move $t1, $s1     # $t1 = número total de registros
    
    # Se não há registros
    beq $t1, $zero, remover_nao_encontrado
    
    li $t2, 0            # $t2 = índice atual (contador)
    
    # Carregar endereço base
    move $t3, $s0   # $t3 = endereço base
    
    remover_loop:
        # Calcular offset: índice * 16
        mul $t4, $t2, $s3     # $t4 = offset
        add $t5, $t3, $t4     # $t5 = endereço do registro atual
        
        # Verificar ID
        lw $t6, 0($t5)        # carrega ID
        beq $t6, $t0, remover_encontrado  # se ID igual, encontrou
        
    remover_proximo:
        addi $t2, $t2, 1      # incrementa contador
        blt $t2, $t1, remover_loop  # se contador < qtd_registros, continua
        j remover_nao_encontrado  # se terminou o loop sem encontrar
    
    remover_encontrado:
        # Verificar se já está inativo
        lw $t6, 12($t5)       # carrega ATIVO
        beq $t6, 0, remover_ja_inativo
        
        # Marcar como inativo (ATIVO = 0)
        sw $zero, 12($t5)
        
        # Mensagem de sucesso
        li $v0, 4
        la $a0, msg_remover_sucesso
        syscall
        j remover_fim
    
    remover_ja_inativo:
        li $v0, 4
        la $a0, msg_remover_ja_inativo
        syscall
        j remover_fim
    
    remover_nao_encontrado:
        li $v0, 4
        la $a0, msg_remover_nao_encontrado
        syscall
    
    remover_fim:
        jr $ra    # Retorna para chamar_remocao

# ===== Encerramento =====
sair:
    li $v0, 10  
    syscall
