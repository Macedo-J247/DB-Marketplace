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
