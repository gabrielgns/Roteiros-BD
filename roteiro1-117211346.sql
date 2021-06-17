/* Primeira Questão. 
Vou apenas escrever comentários sobre os atributos necessários para cada tabela 
AUTOMOVEL: placa, nome_proprietario, país, cor, marca, modelo, ano, seguro_ativo;
SEGURO:  apolice, placa_automovel, data_inicial, data_final, cobertura, valor_seguro, cpf_segurado;
SEGURADO: cpf, nome, celular, endereco;
SINISTRO: numero_ocorrencia, tipo_ocorrencia, data_ocorrido, apolice;
PERITO: cpf, nome;
PERICIA:  placa_automovel, avaliacao, tem_conserto, cpf_perito;
REPARO: placa_automovel, observacoes_perito, valor_conserto, resposta_perito, cnpj_oficina;
OFICINA: cnpj, nome, endereco;
*/

-- Segunda Questão
CREATE TABLE automovel ( 
    placa CHAR(7), -- No mundo real seria necessário o chassi, mas para simplificar estou usando apenas a plcaca como identificador único do automovel que acredito já ser suficiente
    nome_proprietario TEXT,
    pais TEXT, -- Estou seguindo apenas o padrão novo de placas que não tem mais a cidade - estado, apenas país
    cor TEXT,
    marca TEXT,
    modelo TEXT,
    ano INTEGER,
    seguro_ativo BOOLEAN
);
CREATE TABLE seguro (
    apolice CHAR(30),
    placa_automovel CHAR(7),
    data_inicial DATE,
    data_final DATE,
    cobertura TEXT, -- Informa as condições e casos que o seguro acoberta
    valor_seguro NUMERIC,
    cpf_segurado CHAR(11)
);
CREATE TABLE segurado ( 
    cpf CHAR(11), -- Acredito que no mundo real também se pede o RG mas para simplificação eu acho que CPF já é o suficiente para identificar uma pessoa
    nome TEXT,
    celular CHAR(9), -- Considerando que o usuário passe o número no formato 9xxxxxxxx e desconsiderado +55 83 9xxxx-xxxx por motivos de simplificação
    endereco TEXT
);
CREATE TABLE sinistro (
    numero_ocorrencia SERIAL,
    tipo_ocorrencia TEXT,
    data_ocorrido TIMESTAMP,
    apolice_seguro CHAR(30) -- Para saber se o seguro cobre o ocorrido com o carro
);
CREATE TABLE perito (
    cpf CHAR(11),
    nome TEXT
);
CREATE TABLE pericia (
    placa_automovel CHAR(7),
    avaliacao TEXT, -- O perito diz o que aconteceu e em que situação o carro se encontra
    tem_conserto BOOLEAN, -- Decisão final do perito se vale a pena fazer o conserto 
    cpf_perito CHAR(11)
);
CREATE TABLE reparo (
    placa_automovel CHAR(7),
    observacoes_perito TEXT,
    valor_conserto NUMERIC,
    cnpj_oficina CHAR(14)
);
CREATE TABLE oficina (
    cnpj CHAR(14),
    nome TEXT,
    endereco TEXT
);

-- Terceira Questão
ALTER TABLE automovel ADD PRIMARY KEY (placa);
ALTER TABLE seguro ADD PRIMARY KEY (apolice);
ALTER TABLE segurado ADD PRIMARY KEY (cpf);
ALTER TABLE sinistro ADD PRIMARY KEY (numero_ocorrencia);
ALTER TABLE perito ADD PRIMARY KEY (cpf);
ALTER TABLE pericia ADD PRIMARY KEY (placa_automovel, avaliacao);
ALTER TABLE reparo ADD PRIMARY KEY (placa_automovel);
ALTER TABLE oficina ADD PRIMARY KEY (cnpj);

-- Quarta Questão
ALTER TABLE seguro
ADD CONSTRAINT seguro_placa_automovel_fkey 
FOREIGN KEY (placa_automovel) 
REFERENCES automovel (placa);

ALTER TABLE seguro
ADD CONSTRAINT seguro_cpf_segurado_fkey 
FOREIGN KEY (cpf_segurado) 
REFERENCES segurado (cpf);

ALTER TABLE sinistro
ADD CONSTRAINT sinistro_apolice_seguro_fkey 
FOREIGN KEY (apolice_seguro) 
REFERENCES seguro (apolice);

ALTER TABLE pericia
ADD CONSTRAINT pericia_placa_automovel_fkey 
FOREIGN KEY (placa_automovel) 
REFERENCES automovel (placa);

ALTER TABLE pericia
ADD CONSTRAINT pericia_cpf_perito_fkey 
FOREIGN KEY (cpf_perito) 
REFERENCES perito (cpf);

ALTER TABLE reparo
ADD CONSTRAINT reparo_placa_automovel_observacoes_perito_fkey 
FOREIGN KEY (placa_automovel, observacoes_perito) 
REFERENCES pericia (placa_automovel, avaliacao);

ALTER TABLE reparo
ADD CONSTRAINT reparo_cnpj_oficina_fkey 
FOREIGN KEY (cnpj_oficina) 
REFERENCES oficina (cnpj);

/* Quinta Questão
Tem muitos atributos que acredito que não possam ser null pois são de muita importâcia para o sentido geral do banco,
as primary keys já são not null claro, mas tem coisas importantes que temos que considerar como nome do segurado/perito/oficina 
se pensarmos em um sistema  que faria essas perguntas apesar do identificador único ser cpf/cnpj eu acho muito estranho se não pedirem o nome
obrigatoriamente sendo assim os nomes também são NOT NULL. Outro fator que considerei foi a validade do seguro do automovel e tanto o tipo de
ocorrência do sinistro como o que o seguro cobre para sabermos se ele poderá ser ativado, assim como as caracteristicas do carro que
são de grande importância para essa situação.
*/

-- Sexta Questão
DROP TABLE reparo;
DROP TABLE oficina;
DROP TABLE pericia;
DROP TABLE perito;
DROP TABLE seguro CASCADE;
DROP TABLE segurado;
DROP TABLE sinistro;
DROP TABLE automovel;

-- Setima e Oitava Questões
CREATE TABLE automovel ( 
    placa CHAR(7) CONSTRAINT automovel_pkey PRIMARY KEY, 
    pais TEXT NOT NULL, 
    cor TEXT NOT NULL,
    marca TEXT NOT NULL,
    modelo TEXT NOT NULL,
    ano INTEGER NOT NULL, -- Informações básicas do carro que é o foco da tabela
    seguro_ativo BOOLEAN NOT NULL -- Precisa saber se aquele carro tem seguro atualmente
);
CREATE TABLE segurado ( 
    cpf CHAR(11) CONSTRAINT segurado_pkey PRIMARY KEY, 
    nome TEXT NOT NULL,
    celular CHAR(9), 
    endereco TEXT,
    ocorrencia_acionada INTEGER 
);
CREATE TABLE perito (
    cpf CHAR(11) CONSTRAINT perito_pkey PRIMARY KEY,
    nome TEXT NOT NULL
);
CREATE TABLE seguro (
    apolice CHAR(30) CONSTRAINT seguro_pkey PRIMARY KEY,
    placa_automovel CHAR(7) NOT NULL,
    data_inicial DATE,
    data_final DATE NOT NULL, -- Para saber a data de validade
    cobertura TEXT NOT NULL, -- Precisa saber em quais situações o seguro cobre para poder ser ativado 
    valor_seguro NUMERIC NOT NULL, -- É definido na hora do contrato do seguro 
    cpf_segurado CHAR(11),
    CONSTRAINT seguro_placa_automovel_fkey FOREIGN KEY (placa_automovel)
    REFERENCES automovel (placa),
    CONSTRAINT seguro_cpf_segurado_fkey FOREIGN KEY (cpf_segurado)
    REFERENCES segurado (cpf)
);
CREATE TABLE sinistro (
    numero_ocorrencia SERIAL CONSTRAINT sinistro_pkey PRIMARY KEY,
    tipo_ocorrencia TEXT NOT NULL, -- É necessário saber qual foi a situação que aconteceu para saber se o seguro cobre
    data_ocorrido TIMESTAMP NOT NULL, -- Data e hora da ocorrência são informações relevantes
    apolice_seguro CHAR(30),
    CONSTRAINT sinistro_apolice_seguro_fkey FOREIGN KEY (apolice_seguro)
    REFERENCES seguro (apolice)
);
CREATE TABLE pericia (
    placa_automovel CHAR(7),
    avaliacao TEXT NOT NULL, 
    tem_conserto BOOLEAN, -- Pode ser que o perito não tenha uma decisão final e precise chamar outro perito 
    cpf_perito CHAR(11),
    CONSTRAINT pericia_pkey PRIMARY KEY(placa_automovel, avaliacao), -- Acredito que o conjunto de placa mais avalicação do que aconteceu com o carro é o ideal para ser primary key nessa situação
    CONSTRAINT pericia_placa_automovel_fkey FOREIGN KEY (placa_automovel)
    REFERENCES automovel (placa),
    CONSTRAINT pericia_cpf_perito_fkey FOREIGN KEY (cpf_perito)
    REFERENCES perito (cpf)
);
CREATE TABLE oficina (
    cnpj CHAR(14) CONSTRAINT oficina_pkey PRIMARY KEY,
    nome TEXT NOT NULL,
    endereco TEXT
);
CREATE TABLE reparo (
    placa_automovel CHAR(7) CONSTRAINT reparo_pkey PRIMARY KEY,
    observacoes_perito TEXT,
    valor_conserto NUMERIC,
    resposta_perito BOOLEAN,
    cnpj_oficina CHAR(14),
    CONSTRAINT reparo_placa_automovel_observacoes_perito_fkey FOREIGN KEY (placa_automovel, observacoes_perito)
    REFERENCES pericia (placa_automovel, avaliacao),
    CONSTRAINT reparo_cnpj_ofina_fkey FOREIGN KEY (cnpj_oficina)
    REFERENCES oficina (cnpj)
);
-- Perceba que as tabelas estão na ordem que precisam ser criadas para não ter problemas na hora de criar as constraints

-- Nona Questão
DROP TABLE reparo;
DROP TABLE oficina;
DROP TABLE pericia;
DROP TABLE sinistro;
DROP TABLE seguro;
DROP TABLE perito;
DROP TABLE segurado;
DROP TABLE automovel;
-- Podemos perceber que as tabelas são removidas em ordem contrária a que foram criadas para não ter problemas

/* Decima Questão
Poderia ter uma tabela seguradora(
    cnp CHAR(14),
    nome text,
    cpf_segurado CHAR(9),
    contrato TEXT,
    endereco TEXT,
    contato TEXT
    );
*/