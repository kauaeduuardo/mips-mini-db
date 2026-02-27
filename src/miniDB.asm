.data
    # ============================================================
    # Execução:
    #   java -jar Mars4_5.jar sm src/miniDB.asm
    # ============================================================

    # ============================================================
    # Constantes globais do sistema
    # ============================================================
    .align 2
    MAX_REGISTROS: .word 100
    TAM_REGISTRO: .word 16
    QTD_REGISTROS: .word 0
    
    NEXT_ID: .word 1
    
    # ============================================================
    # Banco de registros em memória
    # ============================================================
    .align 2
    BANCO: .space 1600 # Vetor linear de registros
                       # MAX_REGISTROS * TAM_REGISTRO
    
    # ============================================================
    # Mensagens da interface (menu e feedback ao usuário)
    # ============================================================
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
    
    msg_carregamento: .asciiz "Carregando dados...\n"
    msg_dados_carregados: .asciiz "Dados anteriores encontrados e carregados com sucesso!\n"
    msg_banco_vazio: .asciiz "O banco está vazio!\n"
    
    # ============================================================
    # Persistência em arquivo texto
    # ============================================================
    arquivo_nome: .asciiz "backup-banco/banco_de_registros.txt"
    buffer: .space 64
    espaco: .asciiz " "
    newline: .asciiz "\n"
    
    linha: .space 64 
    
.text
.globl main

# ===== Inicialização =====
main:
    la $s0, BANCO		# base do banco
    lw $s1, QTD_REGISTROS	# QTD_REGISTROS = 0
    lw $s2, MAX_REGISTROS	# MAX_REGISTROS = 100
    lw $s3, TAM_REGISTRO 	# TAM_REGISTRO
    
    jal carregar_banco  
   
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
    beq $t0, 0, sair_com_salvamento
        
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

# ------------------------------------------------------------
# Função: inserir
# Descrição:
#   Insere um novo registro ativo no banco em memória.
#   O ID é gerado automaticamente e é sempre crescente (NEXT_ID).
#
# Entradas: Nenhuma (dados são lidos via syscall)
#
# Saídas: Nenhuma
#
# Efeitos colaterais:
#   - Escreve um novo registro em BANCO
#   - Incrementa QTD_REGISTROS
#   - Incrementa NEXT_ID
#
# Pré-condições:
#   - QTD_REGISTROS < MAX_REGISTROS
#
# Pós-condições:
#   - Registro inserido com ATIVO = 1
# ------------------------------------------------------------
inserir:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    bne  $s1, $s2, inserir_continua   

    li   $v0, 4
    la   $a0, msg_cheio
    syscall
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra                          

inserir_continua:
    mul  $t0, $s1, $s3
    add  $t0, $t0, $s0

    jal  ler_dados
   
    # Geração de ID lógico monotônico (não reutilizável)
    # NEXT_ID nunca retrocede, mesmo após remoções 
    lw   $t9, NEXT_ID    
    sw   $t9, 0($t0)    
    addi $t9, $t9, 1
    sw   $t9, NEXT_ID   
        
    sw   $a1, 4($t0)
    sw   $a2, 8($t0)
    li   $t1, 1
    sw   $t1, 12($t0)

    addi $s1, $s1, 1
    sw   $s1, QTD_REGISTROS

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
    
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
    move $t1, $s1     
    
    beq $t1, $zero, busca_nao_encontrado
    
    li $t2, 0            # $t2 = índice atual (contador)
    
    # Carregar endereço base
    move $t3, $s0  
    
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
        addi $t2, $t2, 1     
        blt $t2, $t1, busca_loop  
        j busca_nao_encontrado  
    
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
        li $a0, 10          
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
        jr $ra    

# ------------------------------------------------------------
# Função: remover_registro
# Descrição: Realiza remoção lógica de um registro, marcando-o como inativo.
#
# Entrada: ID fornecido pelo usuário
#
# Saídas: Nenhuma
#
# Efeitos colaterais:
#   - Atualiza o campo ATIVO do registro para 0
#
# Observações:
#   - A remoção não compacta o banco
#   - IDs não são reutilizados
# ------------------------------------------------------------
remover_registro:
    # Pedir ID para remoção
    li $v0, 4
    la $a0, msg_remover_id
    syscall
    
    li $v0, 5
    syscall
    move $t0, $v0        # $t0 = ID a remover
    
    move $t1, $s1     # $t1 = número total de registros
    
    beq $t1, $zero, remover_nao_encontrado
    
    li $t2, 0            # $t2 = índice atual (contador)
    
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
        j remover_nao_encontrado  
    
    remover_encontrado:
        # Verificar se já está inativo
        lw $t6, 12($t5)       # carrega ATIVO
        beq $t6, 0, remover_ja_inativo
        
        sw $zero, 12($t5) # Remoção lógica: registro permanece na memória
        
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
        jr $ra    

# ------------------------------------------------------------
# Função: salvar_banco
# Descrição:
#   Persiste os registros ativos em arquivo texto.
#
# Observações:
#   - Apenas registros ATIVO = 1 são gravados
#   - Não altera dados em memória
#   - Falhas de abertura ou escrita impedem a persistência
# ------------------------------------------------------------
salvar_banco:
    addi $sp, $sp, -32
    sw   $ra,  28($sp)
    sw   $s5,  24($sp)
    sw   $s4,  20($sp)
    sw   $s3,  16($sp)
    sw   $s1,  12($sp)
    sw   $s0,   8($sp)
    sw   $t1,   4($sp)
    sw   $t0,   0($sp)

    li   $v0, 13
    la   $a0, arquivo_nome
    li   $a1, 1
    li   $a2, 0
    syscall

    move $s5, $v0
    bltz $s5, salvar_fim

    li   $t0, 0

salvar_loop:
    beq  $t0, $s1, fechar_arquivo

    mul  $t1, $t0, $s3
    add  $t1, $t1, $s0

    lw   $t2, 12($t1)
    beq  $t2, $zero, salvar_proximo

    # ===== ID =====
    lw   $a0, 0($t1)
    la   $a1, buffer
    sw   $t0, 0($sp)
    sw   $t1, 4($sp)
    jal  int_to_str
    lw   $t1, 4($sp)
    lw   $t0, 0($sp)
    move $s4, $v0

    li   $v0, 15
    move $a0, $s5
    la   $a1, buffer
    move $a2, $s4
    syscall

    li   $v0, 15
    move $a0, $s5
    la   $a1, espaco
    li   $a2, 1
    syscall

    # ===== IDADE =====
    lw   $a0, 4($t1)
    la   $a1, buffer
    sw   $t0, 0($sp)
    sw   $t1, 4($sp)
    jal  int_to_str
    lw   $t1, 4($sp)
    lw   $t0, 0($sp)
    move $s4, $v0

    li   $v0, 15
    move $a0, $s5
    la   $a1, buffer
    move $a2, $s4
    syscall

    li   $v0, 15
    move $a0, $s5
    la   $a1, espaco
    li   $a2, 1
    syscall

    # ===== MATRÍCULA =====
    lw   $a0, 8($t1)
    la   $a1, buffer
    sw   $t0, 0($sp)
    sw   $t1, 4($sp)
    jal  int_to_str
    lw   $t1, 4($sp)
    lw   $t0, 0($sp)
    move $s4, $v0

    li   $v0, 15
    move $a0, $s5
    la   $a1, buffer
    move $a2, $s4
    syscall

    li   $v0, 15
    move $a0, $s5
    la   $a1, newline
    li   $a2, 1
    syscall

salvar_proximo:
    addi $t0, $t0, 1
    j salvar_loop

fechar_arquivo:
    li   $v0, 16
    move $a0, $s5
    syscall

salvar_fim:
    lw   $t0,   0($sp)
    lw   $t1,   4($sp)
    lw   $s0,   8($sp)
    lw   $s1,  12($sp)
    lw   $s3,  16($sp)
    lw   $s4,  20($sp)
    lw   $s5,  24($sp)
    lw   $ra,  28($sp)
    addi $sp, $sp, 32   
    jr   $ra
 
# ===== int_to_str =====
int_to_str:
    # $a0 = inteiro, $a1 = endereço do buffer
    # Retorna: $v0 = tamanho da string
    addiu   $sp, $sp, -24
    sw      $ra, 20($sp)
    sw      $s0, 16($sp)
    sw      $s1, 12($sp)
    sw      $s2,  8($sp)
    sw      $s3,  4($sp)
    sw      $s4,  0($sp)

    move    $s0, $a0        # número
    move    $s1, $a1        # ponteiro para buffer
    move    $s2, $a1        # guarda início do buffer
    li      $s3, 0          # tamanho da string
    li      $s4, 0          

    beqz $s0, zero_case
    
convert_loop:
    beqz    $s0, reverse
    li      $t1, 10
    div     $s0, $t1
    mfhi    $t2             # resto = dígito
    mflo    $s0             # quociente
    addiu   $t2, $t2, '0'   # converte para ASCII
    sb      $t2, 0($s1)
    addiu   $s1, $s1, 1
    addiu   $s3, $s3, 1
    j       convert_loop

# Os dígitos foram escritos em ordem inversa, precisamos inverter
reverse:
    # $s2 = início dos dígitos, $s1-1 = fim dos dígitos
    addiu   $t0, $s1, -1    # ponteiro para o último dígito
    move    $t1, $s2        # ponteiro para o primeiro dígito

reverse_loop:
    bge     $t1, $t0, end_null
    lb      $t2, 0($t1)
    lb      $t3, 0($t0)
    sb      $t3, 0($t1)
    sb      $t2, 0($t0)
    addiu   $t1, $t1, 1
    addiu   $t0, $t0, -1
    j       reverse_loop

zero_case:
    li $t2, '0'
    sb $t2, 0($s1)
    addiu $s1, $s1, 1
    li $s3, 1
    j end_null

end_null:
    sb      $zero, 0($s1)   # null terminator

    addu    $v0, $s3, $s4   # tamanho dos dígitos

    lw      $ra, 20($sp)
    lw      $s0, 16($sp)
    lw      $s1, 12($sp)
    lw      $s2,  8($sp)
    lw      $s3,  4($sp)
    lw      $s4,  0($sp)
    addiu   $sp, $sp, 24

    jr      $ra

# ------------------------------------------------------------
# Função: carregar_banco
# Descrição:
#   Reconstrói o banco de registros em memória a partir do
#   arquivo de persistência, caso exista.
#
# Efeitos colaterais:
#   - Preenche BANCO com registros ativos
#   - Atualiza QTD_REGISTROS
#   - Recalcula NEXT_ID com base no maior ID encontrado
#
# Observações:
#   - A ausência do arquivo é tratada como banco vazio
#   - O banco não é compactado nem validado estruturalmente
# ------------------------------------------------------------
carregar_banco:	
    li $v0, 4
    la $a0, msg_carregamento
    syscall 
    
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $t0, 1
    sw  $t0, NEXT_ID

    # abrir arquivo (read-only)
    li   $v0, 13
    la   $a0, arquivo_nome
    li   $a1, 0
    li   $a2, 0
    syscall

    move $t7, $v0               # fd
    bltz $t7, carregar_fim      # se erro, sai

ler_linha:
    la   $t8, linha          # ponteiro de escrita no buffer
    li   $t9, 0              # contador de bytes da linha

ler_char:
    li   $v0, 14
    move $a0, $t7
    move $a1, $t8            # lê 1 byte direto na posição atual
    li   $a2, 1
    syscall

    blez $v0, fechar_arquivo_carregamento   # EOF ou erro

    lb   $t6, 0($t8)

    beq  $t6, '\n', linha_completa          # achou fim de linha

    addi $t8, $t8, 1        # avança ponteiro
    addi $t9, $t9, 1
    j    ler_char

linha_completa:
    beqz $t9, ler_linha    # linha vazia, ignora

    sb   $zero, 0($t8)     # null terminator no lugar do \n

    la   $a0, linha
    jal  parse_linha

    j    ler_linha

fechar_arquivo_carregamento:
    li   $v0, 16
    move $a0, $t7
    syscall

    sw   $s1, QTD_REGISTROS

    beq  $s1, $zero, banco_vazio_msg

    li   $v0, 4
    la   $a0, msg_dados_carregados
    syscall
    j carregar_fim

banco_vazio_msg:
    li   $v0, 4
    la   $a0, msg_banco_vazio
    syscall

carregar_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# ===== Parse Linha =====
parse_linha: 
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    move $t0, $a0               # ponteiro da linha

    # ID
    move $a0, $t0
    jal  str_to_int
    move $t1, $v0               # ID
    move $t0, $v1               # próximo campo
    
    lw $t6, NEXT_ID       	
    blt $t1, $t6, skip_update_next_id
    addi $t6, $t1, 1
    sw  $t6, NEXT_ID

    skip_update_next_id:

    # IDADE
    move $a0, $t0
    jal  str_to_int
    move $t2, $v0               # IDADE
    move $t0, $v1

    # MATRÍCULA
    move $a0, $t0
    jal  str_to_int
    move $t3, $v0               # MATRÍCULA

    # endereço do registro
    mul  $t4, $s1, $s3
    add  $t4, $t4, $s0

    sw   $t1, 0($t4)
    sw   $t2, 4($t4)
    sw   $t3, 8($t4)
    li   $t5, 1
    sw   $t5, 12($t4)           # ATIVO = 1

    addi $s1, $s1, 1            # incrementa contador

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# ===== str_to_int =====
str_to_int:
    li   $v0, 0                 # acumulador

loop_str_to_int:
    lb   $t0, 0($a0)
    beq  $t0, ' ', fim_str
    beq  $t0, '\n', fim_str
    beq  $t0, 0, fim_str

    addi $t0, $t0, -48          # ASCII → número
    mul  $v0, $v0, 10
    add  $v0, $v0, $t0

    addi $a0, $a0, 1
    j loop_str_to_int

fim_str:
    addi $a0, $a0, 1            # pula separador
    move $v1, $a0               # retorna novo ponteiro
    jr   $ra        
        
# ===== Encerramento =====
sair_com_salvamento:
    jal salvar_banco
    j sair

sair:
    li $v0, 10
    syscall 