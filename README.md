# 🎲 Mini Banco de Dados em Assembly MIPS (MiniDB)

Este projeto foi desenvolvido como atividade de fechamento da disciplina Organização e Arquitetura de Computadores, com o objetivo de aplicar, de forma prática, os conceitos estudados ao longo da disciplina, utilizando Assembly MIPS como linguagem de implementação.

O foco do trabalho está na compreensão do funcionamento de baixo nível do computador, incluindo:
- organização da memória
- uso de registradores
- convenção de chamadas
- manipulação da pilha
- controle explícito do fluxo de execução

## Objetivo do Projeto
Implementar um mini banco de dados em memória principal, capaz de inserir, listar, buscar e remover registros simples, utilizando exclusivamente Assembly MIPS.
Todo o controle é feito manualmente, sem abstrações de alto nível, reforçando o entendimento da arquitetura subjacente.

## Estrutura de um Registro

| Offset | Campo | Tipo | Tamanho | 
| :---: | :---: | :---: | :---:|
| 0 | ID | word | 4 bytes | 
| 4 | IDADE | word | 4 bytes |
| 8 | MATRÍCULA | word | 4 bytes | 
| 12 | ATIVO | word | 4 bytes |

**Tamanho total do Registro = 16 bytes**  
O campo `ATIVO` indica se o registro está ativo (`1`) ou removido logicamente (`0`).

## Organização do Repositório
~~~
/mips-mini-db/
│
├── backup-banco/
│   └── banco_de_registros.txt
│
├── src/
│   └── miniDB.asm
│
├── uteis/
│   └── formato_registro.txt
│
├── Mars4_5.jar
└── README.md
~~~

- `banco_de_registros.txt`: arquivo necessário para persistência dos dados
- `miniDB.asm`: arquivo principal do projeto
- `formato_registro.txt`: especificação do formato de persistência dos registros em arquivo texto

## Como Executar o Programa
Este projeto foi desenvolvido em **Assembly MIPS** e pode ser executado de duas formas:
utilizando o simulador **MARS** ou via **linha de comando** (terminal).

### 1. Execução pelo MARS
1. Abra o simulador **Mars**
2. No menu, clique em **File → Open** e selecione o arquivo principal do projeto:
   ~~~
   src/miniDB.asm
   ~~~
3. Clique em **Assemble**
4. Após a montagem sem erros, clique em **Run**.

### 2. Execução pelo Terminal
Esta alternativa é recomendada quando se deseja evitar limitações da interface gráfica ou automatizar testes.  

**Pré-requisitos:**
- Java instalado
- Arquivo `Mars4_5.jar` disponível no projeto ou no sistema

**Comando de execução**
1. No diretório raiz do projeto, execute:
   ~~~
   java -jar Mars4_5.jar sm src/miniDB.asm
   ~~~

## Discentes responsáveis

- **Kauã Eduardo Andrade de Lima**  
  GitHub: https://github.com/kauaeduuardo

- **Matheus Santos de Jesus**  
  GitHub: https://github.com/Littlemonster22

## Docente 
- Andre Luis Meneses Silva  
GitHub: https://github.com/andrelumesi
