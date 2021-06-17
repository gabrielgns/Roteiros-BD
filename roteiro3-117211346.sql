CREATE TYPE ESTADOS AS ENUM (
    'PB',
    'BA',
    'AL',
    'CE',
    'MA',
    'PE',
    'PI',
    'RN',
    'SE'
);
CREATE TABLE funcionarios (
    cpf CHAR(11) CONSTRAINT funcionarios_pkey PRIMARY KEY,
    nome TEXT NOT NULL,
    cargo CHAR(1), -- Com intuito de simplificar o sistema vou considerar a primeira letra
    farmacia_trabalha INTEGER, -- Unidade em que ele trabalha
    CONSTRAINT chk_funcionario  CHECK 
    (cargo = 'F' OR cargo = 'V' OR cargo = 'E' OR cargo = 'C' OR cargo = 'A'), -- F = farmaceutico, V = vendedor, E = entregadores, C = caixa, A = administrador
    CONSTRAINT chk_tamanho_valido CHECK (LENGTH(cpf) = 11)
);

CREATE TABLE farmacias (
    id_loja INTEGER CONSTRAINT farmacias_pkey PRIMARY KEY,
    bairro TEXT NOT NULL,
    cidade TEXT NOT NULL,
    estado ESTADOS NOT NULL,
    tipo CHAR(6) NOT NULL,
    cpf_gerente CHAR(11),
    func_gerente TEXT,
    CONSTRAINT chk_tipo  CHECK 
    (tipo = 'sede' OR tipo = 'filial'),
    CONSTRAINT bairros_diferentes_excl 
    EXCLUDE USING gist(bairro WITH=, cidade WITH=),
    CONSTRAINT sede_unica_excl 
    EXCLUDE USING gist(tipo WITH=) WHERE (tipo='sede'),
    CONSTRAINT farmacias_cpf_gerente_fkey FOREIGN KEY (cpf_gerente)
    REFERENCES funcionarios (cpf),
    CONSTRAINT chk_gerente_funcao CHECK
    (func_gerente = 'F' OR func_gerente = 'A'),
    CONSTRAINT chk_null_cpf_funcao CHECK
    ((func_gerente IS NOT NULL AND cpf_gerente IS NOT NULL) OR (func_gerente IS NULL AND cpf_gerente IS NULL))
);

ALTER TABLE funcionarios 
ADD CONSTRAINT funcionarios_farmacia_trabalha 
FOREIGN KEY (farmacia_trabalha)
REFERENCES farmacias (id_loja);

CREATE TABLE medicamentos (
    id BIGINT CONSTRAINT medicamentos_pkey PRIMARY KEY,
    valor REAL NOT NULL,
    apenas_receita BOOLEAN NOT NULL,
    nome TEXT,
    mg INTEGER
);

CREATE TABLE clientes (
    cpf CHAR(11) CONSTRAINT cpf_pkey PRIMARY KEY,
    nome TEXT NOT NULL,
    data_nascimento DATE NOT NULL,
    tipo_endereco TEXT NOT NULL,
    CONSTRAINT chk_idade CHECK
    ((data_nascimento + INTERVAL '18 year') < CURRENT_DATE),
    CONSTRAINT chk_tipo_endereco CHECK 
    (tipo_endereco = 'residencia' OR tipo_endereco = 'trabalho' OR tipo_endereco = 'outro')
);

CREATE TABLE vendas (
    num_venda BIGINT CONSTRAINT vendas_pkey PRIMARY KEY,
    valor REAL NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    id_farmacia INTEGER,
    cpf_vendedor CHAR(11),
    func_vendendor TEXT NOT NULL ,
    cpf_cliente CHAR(11),
    id_medicamento BIGINT,
    precisa_receita BOOLEAN NOT NULL,
    quantidade INTEGER,
    CONSTRAINT vendas_id_medicamento FOREIGN KEY (id_medicamento)
    REFERENCES medicamentos (id),
    CONSTRAINT chk_func_vendedor CHECK 
    (func_vendendor = 'V'),
    CONSTRAINT vendas_cpf_vendedor_fkey FOREIGN KEY (cpf_vendedor)
    REFERENCES funcionarios (cpf) ON DELETE RESTRICT,
    CONSTRAINT vendas_id_medicamento_fkey FOREIGN KEY (id_medicamento)
    REFERENCES medicamentos (id) ON DELETE RESTRICT,
    CONSTRAINT vendas_cpf_cliente_fkey FOREIGN KEY (cpf_cliente)
    REFERENCES clientes (cpf),
    CONSTRAINT chk_medicamento_vendas CHECK
    (((precisa_receita = '1') AND cpf_cliente IS NOT NULL) OR precisa_receita = '0')
);

CREATE TABLE entregas (
    id BIGINT CONSTRAINT entregas_pkey PRIMARY KEY,
    id_venda BIGINT NOT NULL,
    cpf_cliente CHAR(11),
    CONSTRAINT entregas_cpf_cliente_fkey FOREIGN KEY (cpf_cliente)
    REFERENCES clientes (cpf)
);

--
-- COMANDOS ADICIONAIS
-- 

-- deve ser executado com sucesso
INSERT INTO farmacias VALUES(001, 'Centro', 'Campina Grande', 'PB','filial', null, null);
INSERT INTO funcionarios VALUES(12345678911, 'Jose', 'A', 001);
INSERT INTO funcionarios VALUES(12345678912, 'Joao', 'V', 001);
UPDATE funcionarios SET farmacia_trabalha = 001 WHERE cpf = '12345678911';
UPDATE farmacias SET cpf_gerente = '12345678911', func_gerente = 'F' WHERE id_loja = 001;
INSERT INTO clientes VALUES('12345678917', 'Jonas', '1970-10-09', 'residencia');
INSERT INTO medicamentos VALUES('100', 12.00, FALSE, 'Dorflex', 1);
INSERT INTO vendas VALUES('00000', 27.55, '2021-03-11 14:12:13', 001, '12345678912', 'V', '12345678917', '100', FALSE, 1); 
INSERT INTO entregas VALUES('010', '00000', '12345678917');

-- deve retornar erro
--O comando abaixo não será aceito pois o tipo está matriz, e só é permitido sede ou filial. 
INSERT INTO farmacias VALUES(003, 'Alto Branco', 'Campina Grande', 'PB','matriz', null, null);
--ERROR:  new row for relation "farmacias" violates check constraint "chk_tipo"
--DETAIL:  Failing row contains (3, Alto Branco, Campina Grande, PB, matriz, null, null).

--O comando abaixo não será aceito, pois insere um tipo que não pode.
INSERT INTO funcionarios VALUES(12345678913, 'Caio', 'L', 001);
-- ERROR:  new row for relation "funcionarios" violates check constraint "chk_funcionario"
-- DETAIL:  Failing row contains (12345678913, Caio, L, 1).

--Cpf que não seja de algum funcionário
UPDATE farmacias SET cpf_gerente = '12345678910', func_gerente = 'F' WHERE id_loja = 001;
-- ERROR:  insert or update on table "farmacias" violates foreign key constraint "farmacias_cpf_gerente_fkey"
-- DETAIL:  Key (cpf_gerente)=(12345678910) is not present in table "funcionarios".

--O comando abaixo não será aceito pois não tem nenhum endereço.
INSERT INTO clientes VALUES('12345678920', 'Claudio', '1990-01-03', null);
-- ERROR:  null value in column "tipo_endereco" violates not-null constraint
-- DETAIL:  Failing row contains (12345678920, Claudio, 1990-01-03, null).

INSERT INTO entregas VALUES('020', '00002', '12345678930');
-- ERROR:  insert or update on table "entregas" violates foreign key constraint "entregas_cpf_cliente_fkey"
-- DETAIL:  Key (cpf_cliente)=(12345678930) is not present in table "clientes".

-- Fazendo uma venda
DELETE FROM funcionarios WHERE cpf = '12345678912';
-- ERROR:  update or delete on table "funcionarios" violates foreign key constraint "vendas_cpf_vendedor_fkey" on table "vendas"
-- DETAIL:  Key (cpf)=(12345678912) is still referenced from table "vendas".

-- Medicamento em venda
DELETE FROM medicamentos WHERE id = '100';
-- ERROR:  update or delete on table "medicamentos" violates foreign key constraint "vendas_id_medicamento" on table "vendas"
-- DETAIL:  Key (id)=(100) is still referenced from table "vendas".

-- Menor de idade
INSERT INTO clientes VALUES('12345678921', 'Ana', '2006-08-08', 'residencia');
-- ERROR:  new row for relation "clientes" violates check constraint "chk_idade"
-- DETAIL:  Failing row contains (12345678921, Ana, 2006-08-08, residencia).

-- Cadastrar farmacias no msm bairro e na mesma cidade.
INSERT INTO farmacias VALUES(004, 'Centro', 'Campina Grande', 'PB','filial', null, null);
-- ERROR:  conflicting key value violates exclusion constraint "bairros_diferentes_excl"
-- DETAIL:  Key (bairro, cidade)=(Centro, Campina Grande) conflicts with existing key (bairro, cidade)=(Centro, Campina Grande).

-- Cadastrar outra farmácia sede
INSERT INTO farmacias VALUES(001, 'Catolé', 'Campina Grande', 'PB','sede', null,null);
-- ERROR:  duplicate key value violates unique constraint "farmacias_pkey"
-- DETAIL:  Key (id_loja)=(1) already exists.

-- Adicionar vendendor como gerentes
UPDATE farmacias SET cpf_gerente = '12345678912', func_gerente = 'V' WHERE id_loja = 001;
-- ERROR:  new row for relation "farmacias" violates check constraint "chk_gerente_funcao"
-- DETAIL:  Failing row contains (1, Centro, Campina Grande, PB, filial, 12345678912, V).

INSERT INTO vendas VALUES('00005', 78.00, '2020-03-05 16:08:11', 001, '12345678912', 'V', null, '100', TRUE);
-- ERROR:  new row for relation "vendas" violates check constraint "chk_medicamento_vendas"
-- DETAIL:  Failing row contains (5, 78, 2020-03-05 16:08:11, 1, 12345678912, V, null, 100, t, null).

INSERT INTO vendas VALUES('00005', 10.90, '2019-07-01 20:00:54', 001, '12345678912', 'V','12345678930','100',TRUE);
-- ERROR:  insert or update on table "vendas" violates foreign key constraint "vendas_cpf_cliente_fkey"
-- DETAIL:  Key (cpf_cliente)=(12345678930) is not present in table "clientes".

INSERT INTO vendas VALUES('00005', 42.15, '2021-02-12 21:19:14', 001, '12345678901', 'F', null, '200', FALSE);
-- ERROR:  new row for relation "vendas" violates check constraint "chk_func_vendedor"
-- DETAIL:  Failing row contains (5, 42.15, 2021-02-12 21:19:14, 1, 12345678901, F, null, 200, f, null).

INSERT INTO farmacias VALUES(012, 'Copacabana', 'Rio de Janeiro', 'RJ','filial', null, null);
-- ERROR:  invalid input value for enum estados: "RJ"
-- LINE 1: ...acias VALUES(012, 'Copacabana', 'Rio de Janeiro', 'RJ','fili...                                                           ^