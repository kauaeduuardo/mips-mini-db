# 🎲Mini Banco de Dados em Assembly MIPS

Este projeto foi desenvolvido como atividade de fechamento da disciplina Organização e Arquitetura de Computadores, com o objetivo de aplicar, de forma prática, os conceitos estudados ao longo da disciplina, utilizando Assembly MIPS como linguagem de implementação.

O foco do trabalho está na compreensão do funcionamento de baixo nível do computador, incluindo:
- organização da memória
- uso de registradores
- convenção de chamadas
- manipulação da pilha
- controle explícito do fluxo de execução

## Objetivo do Projeto
Implementar um mini banco de dados em memória, capaz de manipular registros simples, explorando diretamente os mecanismos fundamentais da arquitetura MIPS.
Todo o controle é feito manualmente, sem abstrações de alto nível, reforçando o entendimento da arquitetura subjacente.

## Estrutura de um Registro

| Offset | Campo | Tipo | Tamanho | 
| :---: | :---: | :---: | :---:|
| 0 | ID | word | 4 bytes | 
| 4 | IDADE | word | 4 bytes |
| 8 | MATRÍCULA | word | 4 bytes | 
| 16 | ATIVO | word | 4 bytes |

**Tamanho do Registro = 16 bytes**

## Organização do Repositório
~~~
/mips-mini-db/
│
├── README.md
├── Mars4_5.jar
├── src/
│   └── miniDB.asm
│
├── formato_registro.txt
│
└── backup_exemplo.txt
~~~

## Discentes responsáveis

- **Kauã Eduardo Andrade de Lima**  
  GitHub: https://github.com/kauaeduuardo

- **Matheus Santos de Jesus**  
  GitHub: https://github.com/Littlemonster22

## Docente 
- Andre Luis Meneses Silva  
GitHub: https://github.com/andrelumesi
