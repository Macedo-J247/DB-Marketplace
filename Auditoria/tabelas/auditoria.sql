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
