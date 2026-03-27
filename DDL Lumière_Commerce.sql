-- Criação do Banco de dados

create database Lumiere_Commerce
character set utf8mb4
collate utf8mb4_0900_ai_ci;

use Lumiere_Commerce;

-- Criação das tabelas

-- Criação da tabela de clientes
create table clientes(
id_cliente int auto_increment primary key,
nome varchar(100),
cpf char(11) unique not null,
email varchar(50) unique,
telefone varchar(15) unique,
status_cliente enum('Ativo', 'Inativo', 'Bloqueado') default 'Ativo',
cidade varchar(20),
uf char(2)
);

-- Criação da tabela de perfumes
create table perfumes(
id_perfume int auto_increment primary key,
nome varchar(100),
familia_olfativa varchar(50),
concentracao enum('EDP', 'EDT', 'EDC', 'Parfum') default 'EDT',
volume_ml int not null,
id_marca int,
pais_origem varchar(20),
preco_venda decimal(10,2) not null,
estoque_atual int default 0,
notas_topo text,
notas_coracao text,
notas_base text
);

-- Criação da tabela de marcas
create table marcas(
id_marca int auto_increment primary key,
nome_marca varchar(50)
);

-- Criação da tabela relacional de perfumes e marcas
create table perfume_marca(
primary key (id_perfume, id_marca),
id_perfume int,
id_marca int
);

-- Criação da tabela de vendas
create table vendas(
id_venda int auto_increment primary key,
id_perfume int,
id_cliente int,
valor_venda decimal(10,2),
data_venda timestamp default current_timestamp
);

-- Criação da tabela de histórico das vendas
create table historico_vendas(
id_historico int auto_increment primary key,
id_perfume int,
id_cliente int,
data_venda date not null
);

-- Criação da tabela de avaliações
create table avaliacoes(
id_avaliacao int auto_increment primary key,
id_perfume int not null,
id_cliente int not null,
nota int not null,
comentario text,
data_avaliacao timestamp default current_timestamp
);

create table alertas_estoque(
id_alerta int auto_increment primary key,
id_perfume int,
mensagem varchar(255),
data_alerta timestamp default current_timestamp,
status_alerta enum('Pendente', 'Enviado') default 'Pendente'
);

-- Criação das pontes entre tabelas

alter table clientes
add constraint chk_cpf_formato check (cpf regexp '^[0-9]{11}$');

alter table perfumes
add constraint fk_per_mar foreign key (id_marca) references marcas (id_marca);

alter table perfume_marca
add constraint fk_PerMar_per foreign key (id_perfume) references perfumes (id_perfume),
add constraint fk_PerMar_mar foreign key (id_marca) references marcas (id_marca);

alter table vendas
add constraint fk_ven_per foreign key (id_perfume) references perfumes (id_perfume),
add constraint fk_ven_clien foreign key (id_cliente) references clientes (id_cliente);

alter table historico_vendas
add constraint fk_HisVen_per foreign key (id_perfume) references perfumes (id_perfume),
add constraint fk_HisVen_clien foreign key (id_cliente) references clientes (id_cliente);

alter table avaliacoes
add constraint fk_ava_per foreign key (id_perfume) references perfumes (id_perfume),
add constraint fk_ava_clien foreign key (id_cliente) references clientes (id_cliente);

alter table alertas_estoque
add constraint fk_alert_per foreign key (id_perfume) references perfumes (id_perfume);

-- Criação das triggers

-- Monitoramento de quantidade mínima de estoque
delimiter //

create trigger trg_monitorar_estoque_vazio
before insert on vendas
for each row
begin
declare v_estoque int;
select estoque_atual into v_estoque
from perfumes
where id_perfume = new.id_perfume;

if v_estoque <= 0 then
signal sqlstate '45000'
set message_text =  'Perfume indisponível em estoque';

    end if;

end //
delimiter ;

-- Atualização de quantidade de cada perfume por venda 
delimiter //

create trigger trg_monitorar_vendas
after insert on vendas
for each row
begin 
update perfumes set estoque_atual = estoque_atual - 1 where id_perfume = new.id_perfume;

end //
delimiter ;

-- Atualização do valor de cada venda
delimiter //

create trigger trg_att_valor_venda
before insert on vendas
for each row
begin

declare v_preco decimal(10,2);
    
    select preco_venda into v_preco 
    from perfumes 
    where id_perfume = new.id_perfume;

   set new.valor_venda = v_preco;

end //
delimiter ;

-- Validação de possibilidade de avaliação
delimiter //

create trigger trg_validar_avaliacao
before insert on avaliacoes
for each row
begin
declare v_comp_perf int;

select count(*) into v_comp_perf 
from historico_vendas 
where id_cliente = new.id_cliente and id_perfume = new.id_perfume;

if v_comp_perf = 0 then
signal sqlstate '45000'
set message_text = 'Erro: O usuário só pode avaliar perfumes que ja tenha comprado!.';
end if;

end //
delimiter ;

-- Registro de histórico de cada venda
delimiter //

create trigger trg_gerar_historico
after insert on vendas
for each row
begin
    insert into historico_vendas (id_perfume, id_cliente, data_venda)
    values (new.id_perfume, new.id_cliente, curdate());
end //

delimiter ;

delimiter //

-- Gatilho de alerta automático de compra de perfumes
create trigger trg_alerta_escassez
after insert on vendas
for each row
begin
    declare v_estoque_atual int;
    declare v_nome_perfume varchar(100);

    select estoque_atual, nome into v_estoque_atual, v_nome_perfume
    from perfumes
    where id_perfume = new.id_perfume;

    if v_estoque_atual = 1 then
        insert into alertas_estoque (id_perfume, mensagem)
        values (new.id_perfume, concat('[ALERTA!]: O perfume "', v_nome_perfume, '" só possui mais 1 unidade em estoque!'));
    end if;

end //

delimiter ;

-- Vizualização de faturamento mensal com base em vendas de cada mês
delimiter //

create procedure sp_fechamento_financeiro_mensal(
in p_mes int,
in p_ano int
)
begin
declare v_total_pago decimal(10,2) default 0.00;
declare v_qnt_vendas int default 0;

select sum(valor_venda) into v_total_pago
from vendas
where month(data_venda) = p_mes
and year(data_venda) = p_ano;

select count(*) into v_qnt_vendas
from vendas
where month(data_venda) = p_mes
and year(data_venda) = p_ano;

select 
p_mes as 'Mês referência',
p_ano as 'Ano referência',
v_qnt_vendas as 'Quantidade de vendas',
ifnull(v_total_pago, 0) as 'Faturamento: (R$)';

end//
delimiter ;
