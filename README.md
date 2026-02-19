# 🎲Mini Banco de Dados em Assembly MIPS
## Projeto Final – Organização e Arquitetura de Computadores

### Universidade Federal de Sergipe (UFS)
### Campus Universitário Professor Alberto Carvalho – Itabaiana  
### Curso: Sistemas de Informação
### Professor: Dr. Andre Luis Meneses Silva

## 📖 Contexto Acadêmico
Este projeto foi desenvolvido como atividade de fechamento da disciplina Organização e Arquitetura de Computadores, com o objetivo de aplicar, de forma prática, os conceitos estudados ao longo da disciplina, utilizando Assembly MIPS como linguagem de implementação.

O foco do trabalho está na compreensão do funcionamento de baixo nível do computador, incluindo:
- organização da memória
- uso de registradores
- convenção de chamadas
- manipulação da pilha
- controle explícito do fluxo de execução

## 🎯 Objetivo do Projeto
Implementar um mini banco de dados em memória, capaz de manipular registros simples, explorando diretamente os mecanismos fundamentais da arquitetura MIPS.  
Todo o controle é feito manualmente, sem abstrações de alto nível, reforçando o entendimento da arquitetura subjacente.

## 🧱 Estrutura de um Registro

Cada registro é composto por:
~~~
ID       -> inteiro (word)
ATIVO    -> byte (1 = ativo, 0 = inativo)
DADOS    -> string (campo associado ao registro)
~~~
Os registros são organizados por meio de *arrays* paralelos, onde o índice funciona como vínculo lógico entre os campos.

## 🗂 Organização do Repositório
~~~
mips-mini-db/
│
├── README.md
│
├── miniDB.asm              # Fluxo principal do programa
~~~
