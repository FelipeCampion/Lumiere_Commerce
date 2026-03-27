use Lumiere_commerce;

-- Inserindo Marcas de Luxo
insert into marcas (nome_marca) values 
('Dior'), 
('Chanel'), 
('Tom Ford'), 
('Creed'), 
('Giorgio Armani');

-- Inserindo o Catálogo de Perfumes
-- Note: O estoque do Sauvage (ID 1) está em 2 unidades. Quando a primeira venda ocorrer, o estoque cairá para 1 e o Alerta de Escassez será gerado.
insert into perfumes (nome, familia_olfativa, concentracao, volume_ml, id_marca, preco_venda, estoque_atual, pais_origem) 
values 
('Sauvage', 'Fougère Amadeirado', 'EDP', 100, 1, 650.00, 2, 'França'),
('Bleu de Chanel', 'Amadeirado', 'Parfum', 100, 2, 890.00, 5, 'França'),
('Tobacco Vanille', 'Oriental Especiado', 'EDP', 50, 3, 1200.00, 8, 'EUA'),
('Aventus', 'Chypre Frutado', 'EDP', 100, 4, 2500.00, 3, 'França'),
('Acqua di Giò', 'Cítrico Aquático', 'EDT', 100, 5, 480.00, 15, 'Itália');

-- Inserindo Clientes (Respeitando o CHECK de CPF de 11 dígitos)
insert into clientes (nome, cpf, email, telefone, status_cliente, cidade, uf) 
values 
('Felipe Campion', '12345678901', 'felipe@dev.com', '19999999999', 'Ativo', 'Rio Claro', 'SP'),
('Ana Silva', '98765432100', 'ana.silva@email.com', '11988887777', 'Ativo', 'São Paulo', 'SP'),
('Carlos Eduardo', '45678912344', 'carlos@vendas.com', '21977776666', 'Ativo', 'Rio de Janeiro', 'RJ');

-- SIMULAÇÃO DE VENDAS (A mágica das Triggers acontece aqui)
-- Não informamos 'valor_venda' nem 'data_venda', o banco preenche sozinho!

-- Venda 1: Felipe compra um Sauvage (ESTOQUE VAI PARA 1 - DISPARA ALERTA)
insert into vendas (id_perfume, id_cliente) values (1, 1);

-- Venda 2: Ana compra um Sauvage (Estoque do ID 1 chega a zero aqui)
insert into vendas (id_perfume, id_cliente) values (1, 2);

-- Venda 3: Felipe compra um Aventus (Luxo!)
insert into vendas (id_perfume, id_cliente) values (4, 1);

-- Teste de trava de estoque (Monitoramento de estoque vazio)
-- Como o Sauvage (ID 1) acabou nas vendas anteriores, este comando deve RETORNAR ERRO:
-- "Error Code: 1644. Perfume indisponível em estoque"
insert into vendas (id_perfume, id_cliente) values (1, 3);

-- Teste de avaliação (Validação de possibilidade de avaliação)
-- Funciona porque Felipe (ID 1) comprou o Sauvage (ID 1) no passo anterior.
insert into avaliacoes (id_perfume, id_cliente, nota, comentario) 
values (1, 1, 5, 'Fixação absurda e projeção elegante. Vale cada centavo!');

-- Teste de bloqueio de avaliação (Usuário não comprou o item)
-- Carlos (ID 3) tenta avaliar o Bleu (ID 2) sem ter comprado. Deve retornar ERRO:
-- "Error Code: 1644. Erro: O usuário só pode avaliar perfumes que ja tenha comprado!."
insert into avaliacoes (id_perfume, id_cliente, nota, comentario) 
values (2, 3, 1, 'Não gostei, cheiro comum.');

-- Relatório financeiro (Procedure de Fechamento)
-- Executa o fechamento do mês atual (Março de 2026)
call sp_fechamento_financeiro_mensal(3, 2026);

-- Conferência final dos dados e do alerta automático
select * from vendas;
select * from historico_vendas;
select * from alertas_estoque;
select id_perfume, nome, estoque_atual from perfumes;
