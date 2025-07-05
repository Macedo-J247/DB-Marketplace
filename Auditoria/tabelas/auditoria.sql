-- Tabelas de Auditoria

-- Auditoria para a tabela de assinatura
CREATE TABLE auditoria_assinatura (
    id_auditoria SERIAL PRIMARY KEY,
    id_assinatura INT,
    acao VARCHAR(10),
    usuario_id INT,
    versao_id INT,
    tipo_pagamento_id INT,
    data_inicio DATE,
    data_termino DATE,
    status STATUS_ASSINATURA,
    data_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditoria para a tabela de usuário
CREATE TABLE auditoria_usuario (
    id_auditoria SERIAL PRIMARY KEY,
    id_usuario INT,
    acao VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    nome_usuario VARCHAR(255),
    email VARCHAR(255),
    tipo_usuario TIPOS_USUARIOS,
    data_registro DATE,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditoria para a tabela de desenvolvedor
CREATE TABLE auditoria_desenvolvedor (
    id_auditoria SERIAL PRIMARY KEY,
    id_desenvolvedor INT,
    acao VARCHAR(10),
    nome_dev VARCHAR(255),
    email_dev VARCHAR(255),
    data_cadastro DATE,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditoria para a tabela de produto
CREATE TABLE auditoria_produto (
    id_auditoria SERIAL PRIMARY KEY,
    id_produto INT,
    acao VARCHAR(10),
    desenvolvedor_id INT,
    categoria_id INT,
    nome_produto VARCHAR(255),
    descricao TEXT,
    preco DECIMAL(10,2),
    tipo TIPOS_PRODUTOS,
    status STATUS_PRODUTOS,
    data_publicacao DATE,
    data_atualizacao DATE,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditoria para a tabela de versão
CREATE TABLE auditoria_versao (
    id_auditoria SERIAL PRIMARY KEY,
    id_versao INT,
    acao VARCHAR(10),
    produto_id INT,
    num_versao VARCHAR(50),
    data_lancamento DATE,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditoria para a tabela de suporte
CREATE TABLE auditoria_suporte (
    id_auditoria SERIAL PRIMARY KEY,
    id_suporte INT,
    acao VARCHAR(10),
    usuario_id INT,
    produto_id INT,
    versao_id INT,
    tipo TIPOS_SUPORTES,
    descricao TEXT,
    data_suporte TIMESTAMP,
    status STATUS_SUPORTE,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditoria para a tabela de avaliação
CREATE TABLE auditoria_avaliacao (
    id_auditoria SERIAL PRIMARY KEY,
    id_avaliacao INT,
    acao VARCHAR(10),
    usuario_id INT,
    versao_id INT,
    nota DECIMAL(3,2),
    data_avaliacao DATE,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditoria para a tabela de parcela
CREATE TABLE auditoria_parcela (
    id_auditoria SERIAL PRIMARY KEY,
    id_parcela INT,
    acao VARCHAR(10),
    assinatura_id INT,
    valor DECIMAL(10,2),
    data_vencimento DATE,
    data_pagamento DATE,
    status STATUS_PARCELA,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
