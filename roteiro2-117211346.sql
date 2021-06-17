-- Questão 1: Criar a tabela tarefas com os seus possíveis atributos
CREATE TABLE tarefas(
    id_tarefa INTEGER,
    descricao TEXT,
    id_encarregado CHAR(11),
    codigo_area INTEGER,
    status_limpeza CHAR(1)
);

-- Exemplo para cadastrar
INSERT INTO tarefas VALUES (2147483646, 'limpar chão do corredor cental', '98765432111', 0, 'F');
INSERT INTO tarefas VALUES (2147483647, 'limpar janelas da sala 203', '98765432122', 1, 'F');
INSERT INTO tarefas VALUES (null, null, null, null, null);
-- =================================================================
-- Exemplo de erro
INSERT INTO tarefas VALUES (2147483644, 'limpar chão do corredor superior', '987654323211', 0, 'F');
INSERT INTO tarefas VALUES (2147483643, 'limpar chão do corredor superior', '98765432321', 0, 'FF');

-- Questão 2: Mudar o tipo para suportar números de 8 bytes
ALTER TABLE tarefas ALTER COLUMN id_tarefa TYPE BIGINT;
-- Exemplo
INSERT INTO tarefas VALUES (2147483648, 'limpar portas do térreo', '32323232955', 4, 'A');

-- Questão 3: Limitar para 2 bytes
ALTER TABLE tarefas ALTER COLUMN codigo_area TYPE SMALLINT;

-- Exemplo para cadastrar
INSERT INTO tarefas VALUES (2147483651, 'limpar portas do 1o andar', '32323232911', 32767, 'A');
INSERT INTO tarefas VALUES (2147483652, 'limpar portas do 2o andar', '21212121911', 32766, 'A');
-- ================================================================
-- Exemplo de erro
INSERT INTO tarefas VALUES (2147483649, 'limpar portas da entrada principal', '32333233288', 32768, 'A');
INSERT INTO tarefas VALUES (2147483650, 'limpar janelas da entrada principal', '32333233288', 32769, 'A');

-- Questão 4: Deletar se alguém tiver com id null, settar atributos para null e mudar o nome 
DELETE FROM tarefas WHERE id_tarefa IS NULL;

ALTER TABLE tarefas ALTER COLUMN id_tarefa SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN descricao SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN id_encarregado SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN codigo_area SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN status_limpeza SET NOT NULL;

ALTER TABLE tarefas RENAME COLUMN id_tarefa TO id;
ALTER TABLE tarefas RENAME COLUMN id_encarregado TO func_resp_cpf;
ALTER TABLE tarefas RENAME COLUMN codigo_area TO prioridade;
ALTER TABLE tarefas RENAME COLUMN status_limpeza TO status;

-- Questão 5: Id único
ALTER TABLE tarefas ADD PRIMARY KEY (id);

-- Questão 6a: Constraint de tamanho
ALTER TABLE tarefas ADD CONSTRAINT tarefas_chk_tamanho_valido CHECK (LENGTH(func_resp_cpf) = 11);

-- Questão 6b: Constraint do char único do status
UPDATE tarefas SET status = 'P' WHERE status = 'A';
UPDATE tarefas SET status = 'E' WHERE status = 'R';
UPDATE tarefas SET status = 'C' WHERE status = 'F';

ALTER TABLE tarefas ADD CONSTRAINT tarefas_chk_sigla_status 
CHECK (status = 'P' OR status = 'E' OR status = 'C');

-- Questão 7: Constraint de prioridades possíveis
UPDATE tarefas SET prioridade = 5 WHERE prioridade > 5;

ALTER TABLE tarefas ADD CONSTRAINT tarefas_chk_num_prioridade CHECK (
    prioridade = 0 OR
    prioridade = 1 OR
    prioridade = 2 OR
    prioridade = 3 OR
    prioridade = 4 OR 
    prioridade = 5
);

-- Questão 8: Tabela funcionarios e suas dependências
CREATE TABLE funcionario (
    cpf CHAR(11) CONSTRAINT cpf_pkey PRIMARY KEY,
    data_nasc DATE NOT NULL,
    nome TEXT NOT NULL,
    funcao TEXT NOT NULL,
    nivel CHAR(1) NOT NULL,
    superior_cpf CHAR(11),
    CONSTRAINT funcionario_superior_cpf FOREIGN KEY (superior_cpf)
    REFERENCES funcionario (cpf)
);

ALTER TABLE funcionario ADD CONSTRAINT funcionario_chk_cpf_len CHECK (LENGTH (cpf) = 11);
ALTER TABLE funcionario ADD CONSTRAINT funcionario_chk_letra_nivel 
CHECK (nivel = 'J' OR nivel = 'P' OR nivel = 'S');

ALTER TABLE funcionario ADD CONSTRAINT funcionario_chk_funcao
CHECK ((funcao = 'LIMPEZA' AND superior_cpf IS NOT NULL) OR funcao = 'SUP_LIMPEZA');

-- Exemplo para cadastrar
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) 
VALUES ('12345678911', '1980-05-07', 'Pedro da Silva', 'SUP_LIMPEZA', 'S', null);

INSERT INTO funcionario(cpf, data_nasc, nome, funcao, nivel, superior_cpf)
VALUES ('12345678912', '1980-03-08', 'Jose da Silva', 'LIMPEZA', 'J', '12345678911');

-- ==================================================================================
-- Exemplo de erro
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf)
VALUES ('123456678913', '1980-04-09', 'jose da Silva', 'LIMPEZA', 'J', null);

-- Questão 9: Exemplos e erros
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678914', '1981-05-11', 'Joao da Silva', 'LIMPEZA', 'P', '12345678911'),
('12345678915', '1982-10-10', 'Gabriel da Silva', 'SUP_LIMPEZA', 'S', null),
('12345678916', '1983-01-10', 'Caio da Silva', 'LIMPEZA', 'J', '12345678911'),
('12345678917', '1984-11-11', 'Igor da Silva', 'LIMPEZA', 'J', '12345678911'),
('12345678918', '1985-06-05', 'Felipe da Silva', 'LIMPEZA', 'J', '12345678911'),
('12345678919', '1985-05-01', 'Murilo da Silva', 'SUP_LIMPEZA', 'S', null),
('12345678920', '1986-05-01', 'Marcos da Silva', 'LIMPEZA', 'P', '12345678911'),
('12345678921', '1977-08-04', 'Marcelo da Silva', 'LIMPEZA', 'P', '12345678911'),
('12345678922', '1990-07-12', 'Daniela da Silva', 'LIMPEZA', 'J', '12345678911'),
('12345678923', '2000-07-12', 'Palloma da Silva', 'SUP_LIMPEZA', 'S', null);
-- ============================================================================
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('123456789244', '1981-05-10', 'Claudia da Silva', 'SUP_LIMPEZA', 'P', null);
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678925', '1981000510000', 'Claudia da Silva', 'SUP_LIMPEZA', 'P', null);
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678926', '1981-05-10', Claudia da Silva, 'SUP_LIMPEZA', 'P', null);
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678927', '1981-05-10', 'Claudia da Silva', 'LIMPEZA', 'P', null);
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678928', '1981-05-10', 'Claudia da Silva', 'SUP_LIMPEZA', 'X', '12345678911');
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678929', '1981-05-10', 'Claudia da Silva', 'LIMPEZA', 'P', '99999999999');
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678930', '1981-05-10', 'Claudia da Silva', 'LIMPEZA', 'P', '12346578911');
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678931', '1981-05-10', 'Claudia da Silva', 'LIMPEZA', 'P', '0000');
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('12345678932', '1981-05-10', 'Claudia da Silva', 'SUP_LIMPEZA', "P", null);
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('123456789', '1981-05-10', 'Claudia da Silva', 'SUP_LIMPEZA', 'P', null);

-- Questão 10: Constraint de drop on cascade e erro
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('98765432111', '2001-10-10', 'Jeferson da Silva', 'LIMPEZA', 'P', '12345678911');
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('98765432122', '1999-01-01', 'Thomas da Silva', 'LIMPEZA', 'J', '12345678911');
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES
('32333233288', '1995-01-12', 'Aline da Silva', 'LIMPEZA', 'J', '12345678911');

-- Opção 2
ALTER TABLE tarefas ADD CONSTRAINT tarefas_func_resp_cpf FOREIGN KEY 
(func_resp_cpf) REFERENCES funcionario (cpf);

DELETE FROM funcionario WHERE cpf = '32333233288';
--ERROR:  update or delete on table "funcionario" violates foreign key constraint "tarefas_func_resp_cpf" on table "tarefas"
--DETAIL:  Key (cpf)=(32333233288) is still referenced from table "tarefas".

-- ALTER TABLE tarefas DROP CONSTRAINT tarefas_func_resp_cpf;

-- Opção 1
ALTER TABLE tarefas ADD CONSTRAINT tarefas_func_resp_cpf FOREIGN KEY 
(func_resp_cpf) REFERENCES funcionario (cpf) ON DELETE CASCADE;

DELETE FROM funcionario WHERE cpf = '32333233288';

-- Questão 11: Permitir updade de set null e constraints finais
ALTER TABLE tarefas ADD CONSTRAINT funcao_chk_null CHECK 
(status = 'C' AND func_resp_cpf IS NOT NULL OR 
status = 'E' AND func_resp_cpf IS NOT NULL OR
status = 'P');

ALTER TABLE tarefas DROP CONSTRAINT tarefas_func_resp_cpf;

ALTER TABLE tarefas ADD CONSTRAINT tarefas_func_resp_cpf FOREIGN KEY 
(func_resp_cpf) REFERENCES funcionario (cpf) ON DELETE CASCADE ON UPDATE SET NULL;