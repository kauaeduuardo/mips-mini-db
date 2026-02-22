.data
    MAX_REGISTROS: .word 100
    banco: .space 1600 # 100 * 16 = 1600 bytes

#registro (16 bytes):

#offset +0   → ID         (word)
#offset +4   → IDADE      (word)
#offset +8   → MATRÍCULA  (word)
#offset +12  → ATIVO      (word: 1 ou 0)

.text
.globl main
main:
    la $s0, banco      # base do banco
    move $s1, $zero    # qtd registros = 0
    lw $s2, MAX_REGISTROS
    li $s3, 16         # TAM_REGISTRO

loop:
    j loop    	
exit:
    li $v0, 10
    syscall