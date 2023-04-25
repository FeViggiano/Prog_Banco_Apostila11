--Aula 25/04/23

CREATE OR REPLACE PROCEDURE sp_obter_notas_para_compor_o_troco (OUT resultadoVARCHAR(500), IN troco INT)
LANGUAGE plpgsql AS $$
DECLARE
	notas200 INT := 0;
	notas100 INT := 0;
	notas50 INT := 0;
	notas20 INT := 0;
	notas10 INT := 0;
	notas5 INT := 0;
	notas2 INT := 0;
	moedas1 INT := 0;
BEGIN
	nota200 := troco / 200;
	notas100 := troco % 200 / 100;
	notas50 := troco % 200 % 100 / 50;
	notas20 := troco % 200 % 100 % 50 / 20;
	notas10 := troco % 200 % 100 % 50 % 20 / 10;
	notas5 := troco % 200 % 100 % 50 % 20 % 10 / 5;
	notas2 := troco % 200 % 100 % 50 % 20 % 10 % 5 / 2;
	moedas1 := troco % 200 % 100 % 50 % 20 % 10 % 5 % 2 / 1;


END;
$$

--Escrever um bloco anônimo
--Chama o proc para calcular o valor do pedido 1
--Chama o proc para calcular o valor do troco quando o valor do pagamento é igual a 100
--Por fim, ele mostra o total da conta e o valor de troco
DO $$
DECLARE
	p_valor_total INT;
	p_troco INT;
	p_valor_a_pagar INT := 100;
	
BEGIN

	CALL sp_calcular_valor_de_um_pedido (1, p_valor_total);
	CALL sp_calcular_troco(p_valor_total, p_troco, p_valor_a_pagar);
	RAISE NOTICE 'O valor total da conta deu R$%, você pago com R$%,  seu troco é de R$%', p_valor_total, p_valor_a_pagar, p_troco;

END;
$$


--Calculando o troco

CREATE OR REPLACE PROCEDURE sp_calcular_troco(
	OUT p_troco INT,
	IN p_valor_a_pagar INT,
	IN p_valor_total INT
)
LANGUAGE plpgsql AS $$
BEGIN
	p_troco := p_valor_a_pagar - p_valor_total;
END;
$$




--O valor está abaixo do necessário
DO $$
BEGIN
	CALL sp_fechar_pedido(20, 1);
END;
$$

-- O pedido está sendo fechado
CREATE OR REPLACE PROCEDURE sp_fechar_pedido(
	IN p_valor_a_pagar INT,
	IN p_cod_pedido INT
)
LANGUAGE plpgsql AS $$
DECLARE

	valor_total INT;
	
BEGIN

CALL sp_calcular_valor_de_um_pedido(
	p_codigo_pedido,
	valor_total
);
	IF p_valor_a_pagar < valor_total THEN
		RAISE 'R$% é insuficiente par apagar a conta de R$', p_valor_a_pagar, valor_total;
	ELSE
		UPDATE tb_pedido p SET
			data_moficacao = CURRENT_TIMESTAMP,
			status = 'fechado'
			WHERE p.cod_pedido = $2;
	END IF;

END;
$$




--Calculando o valor total do pedido
DO $$
DECLARE
	valor_total INT;
BEGIN
	CALL sp_calcular_valor_de_um_pedido(1, valor_total);
	RAISE NOTICE 'Total do pedido %: R$%', 1, valor_total;

END;
$$



--Calculando valor de um pedido
CREATE OR REPLACE PROCEDURE
sp_calcular_valor_de_um_pedido(
	IN p_cod_pedido INT,
	OUT p_valor_total INT
)
LANGUAGE plpgsql AS $$
BEGIN
	SELECT 
		--p.cod_pedido, i.cod_item, i.valor
		SUM(i.valor)
	FROM
		tb_pedido p
			INNER JOIN
		tb_item_pedido ip
			ON p.cod_pedido = ip.cod_pedido
			INNER JOIN
		tb_item i
			ON ip.cod_item = i.cod_item
		WHERE p.cod_pedido = p_cod_pedido
		INTO $2;
END;
$$





CALL sp_adicionar_item_a_pedido(1,1)
CALL sp_adicionar_item_a_pedido(1,1)
CALL sp_adicionar_item_a_pedido(2,1)



SELECT 
	p.cod_pedido, i.cod_item, i.valor
FROM
	tb_pedido p
		INNER JOIN
	tb_item_pedido ip
		ON p.cod_pedido = ip.cod_pedido
		INNER JOIN
	tb_item i
		ON ip.cod_item = i.cod_item;

--
CALL sp_adicionar_item_a_pedido(1, 1);
SELECT * FROM tb_item_pedido;
SELECT * FROM tb_pedido;
SELECT * FROM tb_item;



--adicionar um item a um pedido
CREATE or REPLACE PROCEDURE sp_adicionar_item_a_pedido(
	IN p_cod_item INT,
	IN p_cod_pedido INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_item_pedido
	(cod_item, cod_pedido) VALUES
	(p_cod_item, p_cod_pedido);
	UPDATE tb_pedido p SET data_modificacao = CURRENT_TIMESTAMP WHERE p.cod_pedido = $2;	
END;
$$



-- SELECT * FROM tb_pedido;




DO $$
DECLARE
	cod_pedido INT;
	cod_cliente INT;
BEGIN
	SELECT c.cod_cliente FROM tb_cliente c WHERE nome LIKE 'João da Silva' INTO cod_cliente;
	CALL sp_criar_pedido(cod_pedido, cod_cliente);
	RAISE NOTICE 'Código do pedido recém criado: %', cod_pedido;
END;
$$


-- SELECT * FROM tb_cliente;

CALL sp_cadastrar_cliente('João da Silva');
CALL sp_cadastrar_cliente('Maria Santos');


SELECT * FROM tb_cliente;











-- --criar um pedido, como se o cliente entrasse no restaurante e pegasse a comanda
CREATE OR REPLACE PROCEDURE sp_criar_pedido(
	OUT p_cod_pedido INT,
	IN p_cod_cliente INT
) LANGUAGE plpgsql AS $$

BEGIN
	INSERT INTO tb_pedido (cod_cliente) VALUES (p_cod_cliente);
	--LASTVAL é uma função do PostgreSQL que obtém o último valor gerado pelo mecanismo serial
	SELECT LASTVAL() INTO p_cod_pedido;
END;
$$






--cadastro de cliente
CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente(
	IN p_nome VARCHAR(200),
	IN p_codigo INT DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
	IF p_codigo IS NULL THEN
		INSERT INTO tb_cliente(nome) VALUES(p_nome);
	ELSE
		INSERT INTO tb_cliente(cod_cliente, nome) VALUES (p_codigo, p_nome);
	END IF;
END;
$$



CREATE TABLE tb_item_pedido(
	--surrogate key
	cod_item_pedido SERIAL PRIMARY KEY,
	cod_item INT,
	cod_pedido INT,
	CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES tb_item(cod_item),
	CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES tb_pedido(cod_pedido)
);

item_pedido
(100, 10)
(100, 11)
(101, 10)
(101, 10)

pedido
(100, hoje, hoje, aberto, 1)
(101, ontem, hoje, fechado, 2)

item
(10, 'Hamburguer', 9, 2)
(11, 'Refrigerante', 5, 1)



CREATE TABLE tb_item(
	cod_item SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL,
	valor NUMERIC(10, 2) NOT NULL,
	cod_tipo INT NOT NULL,
	CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES tb_tipo_item(cod_tipo)
);

INSERT INTO tb_item (descricao, valor, cod_tipo)
VALUES
('Refrigerante', 7, 1),
('Suco', 8, 1),
('Hamburguer', 12, 2),
('Batata frita', 9, 2);


CREATE TABLE tb_tipo_item(
	cod_tipo SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL
);

INSERT INTO tb_tipo_item (descricao) VALUES ('Bebida'), ('Comida');
SELECT * FROM tb_tipo_item;


CREATE TABLE tb_pedido(
	cod_pedido SERIAL PRIMARY KEY,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	status VARCHAR(200) DEFAULT 'aberto',
	cod_cliente INT NOT NULL,
	CONSTRAINT fk_cliente FOREIGN KEY(cod_cliente) REFERENCES tb_cliente(cod_cliente)
);


CREATE TABLE tb_cliente(
	cod_cliente SERIAL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL
);

CREATE OR REPLACE PROCEDURE sp_calcula_media (VARIADIC valores INT [])
LANGUAGE plpgsql
AS $$
DECLARE
	media NUMERIC(10, 2) := 0;
	valor INT;
BEGIN
	FOREACH	 valor IN ARRAY valores LOOP
		media := media + valor;
	END LOOP;
	RAISE NOTICE 'A média é: %', media / array_length(valores, 1);
END;
$$

