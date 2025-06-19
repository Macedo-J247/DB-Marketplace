-- DDL para o Schema do Marketplace

-- Tabela desenvolvedor
-- Cada desenvolvedor tem um ID único, um nome, um email único e uma data de registro.
CREATE TABLE "desenvolvedor" (
    "id_desenvolvedor" SERIAL PRIMARY KEY,
    "nome_dev" VARCHAR(255) NOT NULL,
    "email_dev" VARCHAR(255) UNIQUE NOT NULL,
    "data_cadastro" DATE NOT NULL
);

-- Tabela categoria
-- Categoriza os produtos. Cada categoria tem um ID único, um nome único e uma descrição (opcional).
CREATE TABLE "categoria" (
    "id_categoria" SERIAL PRIMARY KEY,
    "nome_categoria" VARCHAR(255) UNIQUE NOT NULL,
    "descricao" VARCHAR(255)
);

-- Tabela produto (Entidade Pai para Software e API)
-- Representa um produto genérico, vinculado a um desenvolvedor e uma categoria.
CREATE TABLE "produto" (
    "id_produto" SERIAL PRIMARY KEY,
    "desenvolvedor_id" INT NOT NULL,
    "categoria_id" INT NOT NULL,
    "nome_produto" VARCHAR(255) NOT NULL,
    "descricao" TEXT NULL,
    "preco" DECIMAL(10, 2) NOT NULL,
    "tipo" ENUM('software', 'api') NOT NULL,
    "status" ENUM('ativo', 'inativo', 'revisao') NOT NULL,
    "data_publicacao" DATE NOT NULL,
    "data_atualizacao" DATE NULL,
    CONSTRAINT "FK_produto_desenvolvedor_id"
        FOREIGN KEY ("desenvolvedor_id")
            REFERENCES "desenvolvedor"("id_desenvolvedor"),
    CONSTRAINT "FK_produto_categoria_id"
        FOREIGN KEY ("categoria_id")
            REFERENCES "categoria"("id_categoria")
);

-- Tabela software (Especialização de produto)
-- Contém atributos específicos para produtos do tipo 'software'.
CREATE TABLE "software" (
    "produto_id" INT PRIMARY KEY,
    "tipo_licenca" VARCHAR(100) NOT NULL,
    CONSTRAINT "FK_software_produto_id"
        FOREIGN KEY ("produto_id")
            REFERENCES "produto"("id_produto")
);

-- Tabela api (Especialização de produto)
-- Contém atributos específicos para produtos do tipo 'api'.
CREATE TABLE "api" (
    "produto_id" INT PRIMARY KEY,
    "endpoint_url" VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT "FK_api_produto_id"
        FOREIGN KEY ("produto_id")
            REFERENCES "produto"("id_produto")
);

-- Tabela versao
-- Registra as diferentes versões de um produto.
CREATE TABLE "versao" (
    "id_versao" SERIAL PRIMARY KEY,
    "produto_id" INT NOT NULL,
    "num_versao" VARCHAR(50) NOT NULL,
    "data_lancamento" DATE NOT NULL,
    CONSTRAINT "UQ_versao_produto_num_versao"
        UNIQUE ("produto_id", "num_versao"),
    CONSTRAINT "FK_versao_produto_id"
        FOREIGN KEY ("produto_id")
            REFERENCES "produto"("id_produto")
);

-- Tabela usuario
-- Representa os usuários do marketplace.
CREATE TABLE "usuario" (
    "id_usuario" SERIAL PRIMARY KEY,
    "nome_usuario" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "senha" VARCHAR(255) NOT NULL,
    "tipo_usuario" ENUM("cliente", "admin", "desenvolvedor") NOT NULL DEFAULT "cliente",
    "data_registro" DATE NOT NULL
);

-- Tabela suporte (Tabela de Junção para a solicitação de suporte)
-- Registra as solicitações de suporte de um usuário para um produto/versão específico(a).
CREATE TABLE "suporte" (
    "id_suporte" SERIAL PRIMARY KEY,
    "usuario_id" INT NOT NULL,
    "produto_id" INT NOT NULL,
    "versao_id" INT NOT NULL,
    "tipo" ENUM("erro", "duvida", "melhoria") NOT NULL,
    "descricao" TEXT NOT NULL,
    "data_suporte" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" ENUM("aberto", "em andamento", "resolvido", 'fechado', 'cancelado') NOT NULL,
    CONSTRAINT "FK_suporte_usuario_id"
        FOREIGN KEY ("usuario_id")
            REFERENCES "usuario"("id_usuario"),
    CONSTRAINT "FK_suporte_produto_id"
        FOREIGN KEY ("produto_id")
            REFERENCES "produto"("id_produto"),
    CONSTRAINT "FK_suporte_versao_id"
        FOREIGN KEY ("versao_id")
            REFERENCES "versao"("id_versao")
);

-- Tabela avaliacao (Tabela de Junção para a avaliação de um produto/versão por um usuário)
CREATE TABLE "avaliacao" (
    "id_avaliacao" SERIAL PRIMARY KEY,
    "usuario_id" INT NOT NULL,
    "versao_id" INT NOT NULL,
    "nota" DECIMAL(3, 2) NOT NULL,
    "data_avaliacao" DATE NOT NULL,
    CONSTRAINT "UQ_avaliacao_usuario_produto"
        UNIQUE ("usuario_id", "versao_id"),
    CONSTRAINT "FK_avaliacao_usuario_id"
        FOREIGN KEY ("usuario_id")
            REFERENCES "usuario"("id_usuario"),
    CONSTRAINT "FK_avaliacao_versao_id"
        FOREIGN KEY ("versao_id")
            REFERENCES "versao"("id_versao")
);

-- Tabela tipo_pagamento
-- Define os tipos de métodos de pagamento disponíveis.
CREATE TABLE "tipo_pagamento" (
    "id_tipo_pagamento" SERIAL PRIMARY KEY,
    "nome_tipo" ENUM('cartao', 'boleto', 'pix') UNIQUE NOT NULL
);

-- Tabela assinatura
-- Representa a assinatura de um usuário a uma versão específica de um produto.
CREATE TABLE "assinatura" (
    "id_assinatura" SERIAL PRIMARY KEY,
    "usuario_id" INT NOT NULL,
    "versao_id" INT NOT NULL,
    "tipo_pagamento_id" INT NOT NULL,
    "data_inicio" DATE NOT NULL,
    "data_termino" DATE NULL,
    "status" ENUM("ativa", "suspensa", "cancelada", "expirada", "teste") NOT NULL,
    CONSTRAINT "FK_assinatura_usuario_id"
        FOREIGN KEY ("usuario_id")
            REFERENCES "usuario"("id_usuario"),
    CONSTRAINT "FK_assinatura_versao_id"
        FOREIGN KEY ("versao_id")
            REFERENCES "versao"("id_versao"),
    CONSTRAINT "FK_assinatura_tipo_pagamento_id"
        FOREIGN KEY ("tipo_pagamento_id")
            REFERENCES "tipo_pagamento"("id_tipo_pagamento")
);

-- Tabela parcela
-- Detalhes das parcelas de pagamento de uma assinatura.
CREATE TABLE "parcela" (
    "id_parcela" SERIAL PRIMARY KEY,
    "assinatura_id" INT NOT NULL,
    "valor" DECIMAL(10, 2) NOT NULL,
    "data_vencimento" DATE NOT NULL,
    "data_pagamento" DATE,
    "status" ENUM("pendente", "pago", "atrasado", "falha", "estornado") NOT NULL,
    CONSTRAINT "FK_parcela_assinatura_id"
        FOREIGN KEY ("assinatura_id")
            REFERENCES "assinatura"("id_assinatura")
);

-- função para validar o preço de um produto
CREATE OR REPLACE FUNCTION validar_preco_produto()
returns trigger as $$
BEGIN
IF NEW.preco <= 0 THEN
RAISE EXCEPTION 'O preço do produto %" deve ser um valor positivo.', NEW.nome_produto;
END IF;
RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
-- Trigger para validar o preço antes de inserir ou atualizar um produto
CREATE Trigger trg_validar_preco_produto
before insert or update on produto
FOR EACH ROW
EXECUTE FUNCTION validar_preco_produto();

CREATE OR REPLACE FUNCTION atualizar_data_atualizacao_produto()
RETURNS TRIGGER AS $$
BEGIN
NEW.data_atualizacao = NOW();
RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
-- Trigger que chama a função antes de qualquer UPDATE na tabela produto
CREATE TRIGGER trg_produto_data_atualizacao
before on update on produto
FOR EACH ROW
EXECUTE FUNCTION atualizar_data_atualizacao_produto();

