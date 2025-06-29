-- Funções
-- 1) INSERIR ASSINATURA
CREATE OR REPLACE FUNCTION cadastrar_assinatura(
    i_usuario_id         INT,
    i_versao_id          INT,
    i_tipo_pagamento_id  INT,
    i_data_inicio        DATE,
    i_data_termino       DATE                DEFAULT NULL,
    i_status             STATUS_ASSINATURA   DEFAULT 'ativa'
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id INT;
BEGIN
    -- campos obrigatórios
    IF i_usuario_id IS NULL THEN
        RAISE NOTICE 'Campo "usuario_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_versao_id IS NULL THEN
        RAISE NOTICE 'Campo "versao_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_tipo_pagamento_id IS NULL THEN
        RAISE NOTICE 'Campo "tipo_pagamento_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_data_inicio IS NULL THEN
        RAISE NOTICE 'Campo "data_inicio" é obrigatório.';
        RETURN NULL;
    END IF;

    -- validações de FK
    IF NOT EXISTS (SELECT 1 FROM "usuario" WHERE "id_usuario" = i_usuario_id) THEN
        RAISE NOTICE 'Usuário ID % não encontrado.', i_usuario_id;
        RETURN NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "versao" WHERE "id_versao" = i_versao_id) THEN
        RAISE NOTICE 'Versão ID % não encontrada.', i_versao_id;
        RETURN NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "tipo_pagamento" WHERE "id_tipo_pagamento" = i_tipo_pagamento_id) THEN
        RAISE NOTICE 'Tipo de pagamento ID % não encontrado.', i_tipo_pagamento_id;
        RETURN NULL;
    END IF;

    -- opcional: data_termino posterior a data_inicio
    IF i_data_termino IS NOT NULL
       AND i_data_termino < i_data_inicio THEN
        RAISE NOTICE 'Data término não pode ser anterior à data início.';
        RETURN NULL;
    END IF;

    -- insere
    INSERT INTO "assinatura"(
      "usuario_id", "versao_id", "tipo_pagamento_id",
      "data_inicio", "data_termino", "status"
    )
    VALUES (
      i_usuario_id, i_versao_id, i_tipo_pagamento_id,
      i_data_inicio, i_data_termino, i_status
    )
    RETURNING "id_assinatura" INTO v_id;

    RETURN v_id;
END;
$$;


-- 2) ATUALIZAR ASSINATURA
CREATE OR REPLACE FUNCTION atualizar_assinatura(
    u_id_assinatura      INT,
    u_usuario_id         INT                  DEFAULT NULL,
    u_versao_id          INT                  DEFAULT NULL,
    u_tipo_pagamento_id  INT                  DEFAULT NULL,
    u_data_inicio        DATE                 DEFAULT NULL,
    u_data_termino       DATE                 DEFAULT NULL,
    u_status             STATUS_ASSINATURA    DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
    v_new_inicio DATE;
    v_new_termino DATE;
BEGIN
    -- 2.1) existe?
    SELECT * INTO v_old
      FROM "assinatura"
     WHERE "id_assinatura" = u_id_assinatura;
    IF NOT FOUND THEN
        RAISE NOTICE 'Assinatura ID % não encontrada.', u_id_assinatura;
        RETURN NULL;
    END IF;

    -- define os valores finais
    u_usuario_id        := COALESCE(u_usuario_id,       v_old.usuario_id);
    u_versao_id         := COALESCE(u_versao_id,        v_old.versao_id);
    u_tipo_pagamento_id := COALESCE(u_tipo_pagamento_id, v_old.tipo_pagamento_id);
    u_data_inicio       := COALESCE(u_data_inicio,      v_old.data_inicio);
    u_data_termino      := COALESCE(u_data_termino,     v_old.data_termino);
    u_status            := COALESCE(u_status,           v_old.status);

    -- 2.2) validações de FK
    IF NOT EXISTS (SELECT 1 FROM "usuario" WHERE "id_usuario" = u_usuario_id) THEN
        RAISE NOTICE 'Usuário ID % não encontrado.', u_usuario_id;
        RETURN NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "versao" WHERE "id_versao" = u_versao_id) THEN
        RAISE NOTICE 'Versão ID % não encontrada.', u_versao_id;
        RETURN NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "tipo_pagamento" WHERE "id_tipo_pagamento" = u_tipo_pagamento_id) THEN
        RAISE NOTICE 'Tipo de pagamento ID % não encontrado.', u_tipo_pagamento_id;
        RETURN NULL;
    END IF;

    -- 2.3) data término depois de início
    IF u_data_termino IS NOT NULL
       AND u_data_termino < u_data_inicio THEN
        RAISE NOTICE 'Data término não pode ser anterior à data início.';
        RETURN NULL;
    END IF;

    -- 2.4) executa update
    UPDATE "assinatura"
       SET "usuario_id"        = u_usuario_id,
           "versao_id"         = u_versao_id,
           "tipo_pagamento_id" = u_tipo_pagamento_id,
           "data_inicio"       = u_data_inicio,
           "data_termino"      = u_data_termino,
           "status"            = u_status
     WHERE "id_assinatura" = u_id_assinatura;

    RETURN u_id_assinatura;
END;
$$;


-- 3) EXCLUIR ASSINATURA
CREATE OR REPLACE FUNCTION excluir_assinatura(
    d_id_assinatura   INT,
    d_usuario_id      INT
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 3.1) existe?
    SELECT * INTO v_old
      FROM "assinatura"
     WHERE "id_assinatura" = d_id_assinatura;
    IF NOT FOUND THEN
        RETURN format('Assinatura ID %s não encontrada.', d_id_assinatura);
    END IF;

    -- 3.2) confere usuário
    IF v_old.usuario_id <> d_usuario_id THEN
        RETURN format(
          'Não confere: a assinatura %s não pertence ao usuário %s.',
          d_id_assinatura, d_usuario_id
        );
    END IF;

    -- 3.3) bloqueia se houver parcelas
    IF EXISTS (
        SELECT 1 FROM "parcela"
         WHERE "assinatura_id" = d_id_assinatura
    ) THEN
        RETURN format(
          'Não foi possível excluir: existem parcelas vinculadas à assinatura %s.',
          d_id_assinatura
        );
    END IF;

    -- 3.4) exclui
    DELETE FROM "assinatura"
     WHERE "id_assinatura" = d_id_assinatura;

    -- 3.5) mensagem
    RETURN format(
      'Assinatura %s do usuário %s excluída com sucesso.',
      d_id_assinatura, d_usuario_id
    );
END;
$$;

-- Triggers