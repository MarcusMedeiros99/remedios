BEGIN;
CREATE TABLE remedio(
	ggrem CHAR(15) ,
	apresentacao VARCHAR(50),
	PRIMARY KEY(ggrem)
);

CREATE TABLE medico(
	id SERIAL,
	nome VARCHAR(30) NOT NULL,
	numero_crm CHAR(6) NOT NULL,
	uf_crm CHAR(2) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (id),
	UNIQUE(numero_crm, uf_crm)
);

CREATE TABLE administradora_convenio(
	cnpj CHAR(14),
	nome VARCHAR(30) NOT NULL,
	endereco VARCHAR(50),
	cep CHAR(8),
	telefone_1 VARCHAR(12),
	telefone_2 VARCHAR(12),
	email VARCHAR(30),
	PRIMARY KEY(cnpj)
);

CREATE TABLE convenio(
	id SERIAL,
	cnpj_administradora CHAR(14) NOT NULL,

	PRIMARY KEY (id),

	FOREIGN KEY (cnpj_administradora) REFERENCES administradora_convenio(cnpj)
);

CREATE TABLE regiao(
	id SERIAL,
	nome VARCHAR(15) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE posto_regional(
	id SERIAL,
	descricao VARCHAR(15) NOT NULL,
	regiao_id INT NOT NULL,

	PRIMARY KEY (id),
	
	FOREIGN KEY (regiao_id) REFERENCES regiao(id)
);

CREATE TABLE paciente(
	cpf CHAR(11),
	nome VARCHAR(30) NOT NULL,
	convenio_id INT,
	posto_regional_id INT NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	PRIMARY KEY (cpf),
	
	FOREIGN KEY (convenio_id) REFERENCES convenio(id),
	FOREIGN KEY (posto_regional_id) REFERENCES posto_regional(id)
);

CREATE TYPE prontidao_receita_t AS ENUM('EMERGENCIAL', 'SEMANAL', 'MENSAL');

CREATE TABLE receita_remedio(
	id SERIAL,
	paciente_cpf CHAR(11) NOT NULL,
	medico_id INT NOT NULL,
	prontidao prontidao_receita_t NOT NULL,
	remedio_ggrem CHAR(15) NOT NULL,
	quantidade INT NOT NULL,
	retencao BOOLEAN NOT NULL,
	posto_regional_id INT NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	PRIMARY KEY (id),
	
	FOREIGN KEY (medico_id) REFERENCES medico(id),
	FOREIGN KEY (remedio_ggrem) REFERENCES remedio(ggrem),
	FOREIGN KEY (posto_regional_id) REFERENCES posto_regional(id),

	CHECK (quantidade > 0)
);

CREATE TABLE farmaceutico(
	id SERIAL,
	nome VARCHAR(30),
	PRIMARY KEY (id)
);

CREATE TYPE requisicao_status_t AS ENUM('CRIADO', 'ENTREGUE', 'ERRO');

CREATE TABLE requisicao_remedio(
	id SERIAL,
	farmaceutico_id INT NOT NULL,
	receita_id INT NOT NULL,
	"status" requisicao_status_t NOT NULL,
	entregue_em TIMESTAMP,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (id),

	FOREIGN KEY (farmaceutico_id) REFERENCES farmaceutico(id),
	FOREIGN KEY (receita_id) REFERENCES receita_remedio(id),

	--restrições para garantir que apenas existe uma requisicao com status ENTREGUE para uma dada receita
	UNIQUE(receita_id, entregue_em),
	CHECK ("status" = 'ENTREGUE' AND entregue_em IS NOT NULL OR "status" <> 'ENTREGUE' AND entregue_em = NULL)
);

CREATE TABLE "local" (
	id SERIAL,
	endereco VARCHAR(50) NOT NULL,

	PRIMARY KEY (id)
);

CREATE TABLE estoque_local (
	regiao_id INT NOT NULL,
	local_id INT NOT NULL,
	remedio_ggrem CHAR(15) NOT NULL,
	quantidade INT NOT NULL,

	PRIMARY KEY (regiao_id, local_id, remedio_ggrem),

	FOREIGN KEY (regiao_id) REFERENCES regiao(id),
	FOREIGN KEY (local_id) 	REFERENCES "local"(id),
	FOREIGN KEY (remedio_ggrem) REFERENCES remedio(ggrem),
	
	CHECK (quantidade >= 0)
);

CREATE TYPE movimentacao_estoque_t AS ENUM('BAIXA', 'ABASTECIMENTO');

CREATE TABLE movimentacao_estoque_local(
	id SERIAL,
	farmaceutico_id INT NOT NULL,
	regiao_id INT NOT NULL,
	local_id INT NOT NULL,
	remedio_ggrem CHAR(15) NOT NULL,
	quantidade INT NOT NULL,
	tipo movimentacao_estoque_t NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,


	PRIMARY KEY (id),

	FOREIGN KEY (regiao_id, local_id, remedio_ggrem) REFERENCES estoque_local(regiao_id, local_id, remedio_ggrem),
	FOREIGN KEY (farmaceutico_id) REFERENCES farmaceutico(id),

	CHECK (quantidade <> 0)
);

CREATE TABLE estoque_regional(
	regiao_id INT NOT NULL,
	remedio_ggrem CHAR(15) NOT NULL,
	quantidade INT NOT NULL,

	PRIMARY KEY (regiao_id, remedio_ggrem),

	FOREIGN KEY (regiao_id) REFERENCES regiao(id),
	FOREIGN KEY (remedio_ggrem) REFERENCES remedio(ggrem),
	
	CHECK (quantidade >= 0)
);

CREATE TABLE despache_remedio(
	id SERIAL,
	regiao_id INT NOT NULL,
	remedio_ggrem CHAR(15) NOT NULL,
	quantidade INT NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (id),

	FOREIGN KEY (regiao_id) REFERENCES regiao(id),
	FOREIGN KEY (remedio_ggrem) REFERENCES remedio(ggrem),

	CHECK (quantidade > 0)
);


COMMIT;