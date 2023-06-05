/* 1- Adicione uma tabela de log ao sistema do restaurante. Ajuste cada procedimento para que ele registre:
a data em que a operação aconteceu;
o nome do procedimento executado; */


CREATE TABLE tb_procedures (
	cod_procedure SERIAL PRIMARY KEY,
	data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	nome_procedure VARCHAR(200),
	cod_cliente INT NOT NULL,
	cod_pedido INT NOT NULL,
	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES tb_cliente(cod_cliente),
	CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES tb_pedido(cod_pedido)
);

CREATE OR REPLACE PROCEDURE sp_registro_procedure(
	IN p_nome VARCHAR(200)
) LANGUAGE plpgsql AS $$
BEGIN
	INSERT INTO tb_procedures(nome_procedures) VALUES (p_nome);
END;
$$


/*
1.2 Adicione um procedimento ao sistema do restaurante. Ele deve:

receber um parâmetro de entrada (IN) que representa o código de um cliente;

exibir, com RAISE NOTICE, o total de pedidos que o cliente tem;
*/

CREATE OR REPLACE PROCEDURE sp_total_pedidos_cliente(
	IN p_cliente INT,
	IN p_pedido INT
) LANGUAGE plpgsql AS $$
DECLARE
	total_pedidos INT;
BEGIN 
	SELECT 
		COUNT(p.total_pedidos)
	FROM
		tb_pedido p 
	WHERE p.cod_cliente = p.cliente;
	RAISE NOTICE 'O cliente % e realizou um total de %.', p_cliente, total_pedidos;
END;
$$


/*
1.3 Reescreva o exercício 1.2 de modo que o total de pedidos seja armazenado em uma
variável de saída (OUT).
*/

CREATE OR REPLACE PROCEDURE sp_total_pedidos_cliente(
  IN p_cliente INT,
  OUT p_pedido INT
) LANGUAGE plpgsql AS $$
DECLARE
	total_pedidos INT;
BEGIN
  SELECT 
  	COUNT(p.total_pedidos)
  FROM tb_pedido p
  WHERE p.cod_cliente = p.p_cliente;
  RAISE NOTICE 'O cliente % teve um total de % pedidos.', p_cliente, total_pedidos;
END;
$$ 



/*
1.4 Adicione um procedimento ao sistema do restaurante. Ele deve:

Receber um parâmetro de entrada e saída (INOUT);

Na entrada, o parâmetro possui o código de um cliente;

Na saída, o parâmetro deve possuir o número total de pedidos realizados pelo cliente;
*/

CREATE OR REPLACE PROCEDURE sp_atualiza_pedidos_cliente(
  INOUT p_cliente INT,
  IN p_pedido INT
) LANGUAGE plpgsql AS $$
DECLARE
  total_pedidos INT;
BEGIN
  SELECT 
  	COUNT(p.total_pedidos)
  FROM tb_pedido p
  WHERE p.cod_cliente = p.p_cliente;

  p_cliente := p.total_pedidos;
END;
$$



/*
1.5 Adicione um procedimento ao sistema do restaurante. Ele deve:

Receber um parâmetro VARIADIC contendo nomes de pessoas;

Fazer uma inserção na tabela de clientes para cada nome recebido;

Receber um parâmetro de saída que contém o seguinte texto:

“Os clientes: Pedro, Ana, João etc foram cadastrados”

Evidentemente, o resultado deve conter os nomes que de fato foram enviados por meio do
parâmetro VARIADIC.
*/


CREATE OR REPLACE PROCEDURE sp_cadastrar_clientes(VARIADIC nomes text[])
AS $$
DECLARE
  nome_cliente text;
  msg_saida text := 'Os seguintes clientes foram cadastrados:';
  
BEGIN

  FOREACH nome_cliente IN ARRAY nomes LOOP
    INSERT INTO tb_cliente (nome) VALUES (nome_cliente);
    msg_saida := msg_saida || ' ' || nome_cliente || ',';
  END LOOP;
  RAISE NOTICE '%', msg_saida;
  
END;
$$
LANGUAGE plpgsql;





/*
1.6 Para cada procedimento criado, escreva um bloco anônimo que o coloca em execução.
*/

-- Exercício 1.1

INSERT INTO tb_procedures (nome_procedure, cod_cliente, cod_pedido)
VALUES ('teste', 1,1);
       

-- Exercício 1.2

DO $$
DECLARE
	total_pedidos INT;
	codigo_cliente INT := 1;
BEGIN

	SELECT COUNT(*) INTO total_pedidos
	FROM tb_pedido
	WHERE cod_cliente = codigo_cliente;
	RAISE NOTICE 'O cliente de código % possui um total de % pedidos.', codigo_cliente, total_pedidos;

END;
$$

-- Exercício 1.3
DO $$
DECLARE
  total_pedidos INT;
  p_cliente INT := 2;
BEGIN 

  SELECT COUNT(*) INTO total_pedidos 
  FROM tb_pedido 
  WHERE cod_cliente = p_cliente;
  RAISE NOTICE 'O cliente %, teve um total de % pedidos.', p_cliente, total_pedidos;
  
END;
$$


-- Exercício 1.4
DO $$
DECLARE
  cliente_id INT := 1; 
  pedido_id INT := 1; 
BEGIN
  CALL sp_atualiza_pedidos_cliente(cod_cliente, cod_pedido);
  
END $$;


-- Exercicio 1.5 
DO $$
DECLARE
  nomes text[] := ARRAY['pedro paulo', 'ana maria', 'joao jose'];
  nome_cliente text;
  msg_saida text := 'Os clientes:';
BEGIN
  FOREACH nome_cliente IN ARRAY nomes LOOP
    INSERT INTO tb_cliente (nome) VALUES (nome_cliente);
    msg_saida := msg_saida || ' ' || nome_cliente || ',';
  END LOOP;
  RAISE NOTICE '%', msg_saida || ' foram cadastrados';
END $$;


