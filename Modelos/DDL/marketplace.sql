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
    "descricao_categoria" VARCHAR(255)
);

-- Tabela produto (Entidade Pai para Software e API)
-- Representa um produto genérico, vinculado a um desenvolvedor e uma categoria.

-- Enum para os tipos de produtos disponíveis
CREATE TYPE TIPOS_PRODUTOS AS ENUM('software', 'api');

-- Enum para os tipos de status de um produto 
CREATE TYPE STATUS_PRODUTOS AS ENUM('ativo', 'inativo', 'revisao');

CREATE TABLE "produto" (
    "id_produto" SERIAL PRIMARY KEY,
    "desenvolvedor_id" INT NOT NULL,
    "categoria_id" INT NOT NULL,
    "nome_produto" VARCHAR(255) NOT NULL,
    "descricao" TEXT NULL,
    "preco" DECIMAL(10, 2) NOT NULL,
    "tipo" TIPOS_PRODUTOS NOT NULL,
    "status" STATUS_PRODUTOS NOT NULL,
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

-- Enum para os tipos de usuários
CREATE TYPE TIPOS_USUARIOS AS ENUM('administrador', 'cliente', 'desenvolvedor');

CREATE TABLE "usuario" (
    "id_usuario" SERIAL PRIMARY KEY,
    "nome_usuario" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "senha" VARCHAR(255) NOT NULL,
    "tipo_usuario" TIPOS_USUARIOS NOT NULL DEFAULT 'cliente',
    "data_registro" DATE NOT NULL
);

-- Tabela suporte (Tabela de Junção para a solicitação de suporte)
-- Registra as solicitações de suporte de um usuário para um produto/versão específico(a).

-- Enum para os tipos de suportes
CREATE TYPE TIPOS_SUPORTES as ENUM('erro', 'duvida', 'melhoria');

-- Enum para os tipos de status do suporte
CREATE TYPE STATUS_SUPORTE AS ENUM('aberto', 'em andamento', 'resolvido', 'fechado', 'cancelado');

CREATE TABLE "suporte" (
    "id_suporte" SERIAL PRIMARY KEY,
    "usuario_id" INT NOT NULL,
    "produto_id" INT NOT NULL,
    "versao_id" INT NOT NULL,
    "tipo" TIPOS_SUPORTES NOT NULL,
    "descricao" TEXT NOT NULL,
    "data_suporte" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" STATUS_SUPORTE NOT NULL,
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
    "versao_id" INT,
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

-- Enum para os tipos de pagamentos aceitos
CREATE TYPE TIPOS_PAGAMENTOS AS ENUM('cartao', 'boleto', 'pix');

CREATE TABLE "tipo_pagamento" (
    "id_tipo_pagamento" SERIAL PRIMARY KEY,
    "nome_tipo" TIPOS_PAGAMENTOS UNIQUE NOT NULL
);

-- Tabela assinatura
-- Representa a assinatura de um usuário a uma versão específica de um produto.

-- Enum para os status das assinaturas
CREATE TYPE STATUS_ASSINATURA AS ENUM('ativa', 'suspensa', 'cancelada', 'expirada', 'teste');

CREATE TABLE "assinatura" (
    "id_assinatura" SERIAL PRIMARY KEY,
    "usuario_id" INT NOT NULL,
    "versao_id" INT NOT NULL,
    "tipo_pagamento_id" INT NOT NULL,
    "data_inicio" DATE NOT NULL,
    "data_termino" DATE NULL,
    "status" STATUS_ASSINATURA NOT NULL,
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

-- Enum para os status das parcelas
CREATE TYPE STATUS_PARCELA AS ENUM('pendente', 'pago', 'atrasado', 'falha', 'estornado');

CREATE TABLE "parcela" (
    "id_parcela" SERIAL PRIMARY KEY,
    "assinatura_id" INT NOT NULL,
    "valor" DECIMAL(10, 2) NOT NULL,
    "data_vencimento" DATE NOT NULL,
    "data_pagamento" DATE,
    "status" STATUS_PARCELA NOT NULL,
    CONSTRAINT "FK_parcela_assinatura_id"
        FOREIGN KEY ("assinatura_id")
            REFERENCES "assinatura"("id_assinatura")
);
