# 🏺 Lumière Commerce - Sistema de Gestão para Perfumaria de Luxo

![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)
![Database](https://img.shields.io/badge/Database-Design-blue?style=for-the-badge)

O **Lumière Commerce** é um sistema de banco de dados relacional (RDBMS) desenvolvido para gerenciar operações de e-commerce especializadas em perfumaria de alta gama. O projeto foca em integridade de dados, automação de processos via triggers e segurança de regras de negócio diretamente no servidor.

## Funcionalidades Principais

* **Gestão de Inventário:** Controle rigoroso de estoque com travas automáticas para produtos indisponíveis.
* **Automação de Vendas:** Cálculo automático de preços e baixa de estoque em tempo real.
* **Segurança Anti-Fraude:** Sistema de avaliações protegido; apenas clientes que efetivamente compraram o produto podem avaliá-lo.
* **Relatórios Financeiros:** Stored Procedure para fechamento mensal de faturamento e volume de vendas.
* **Validação de Dados:** Uso de Expressões Regulares (RegEx) para garantir o formato correto de documentos (CPF).

## Tecnologias Utilizadas

* **MySQL 8.0:** Motor de banco de dados.
* **Triggers:** Para automação de logs, histórico e controle de estoque.
* **Stored Procedures:** Para processamento de relatórios financeiros.
* **RegEx (Regular Expressions):** Para validação de integridade dos dados de clientes.

## Estrutura do Banco de Dados

O banco de dados é composto pelas seguintes tabelas:

1.  **`clientes`**: Cadastro completo com status e validação de CPF.
2.  **`perfumes`**: Catálogo detalhado (família olfativa, notas de topo, coração e base).
3.  **`marcas`**: Fabricantes e marcas associadas.
4.  **`vendas`**: Registro de transações comerciais.
5.  **`historico_vendas`**: Tabela de auditoria e controle para permissões de avaliação.
6.  **`avaliacoes`**: Feedback de clientes com sistema de nota e comentário.

## Lógica Programável (Exemplos)

### Validação de Estoque
O sistema impede a criação de uma venda caso o perfume solicitado não possua unidades em estoque, retornando uma mensagem de erro personalizada.

### Integridade de Avaliação
```sql
-- Regra: O usuário só pode avaliar perfumes que já tenha comprado.
IF v_comp_perf = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Erro: O usuário só pode avaliar perfumes que já tenha comprado!.';
END IF;
