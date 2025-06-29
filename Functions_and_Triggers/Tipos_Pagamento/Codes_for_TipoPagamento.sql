-- Funções
-- 1) INSERIR TIPO DE PAGAMENTO
CREATE OR REPLACE FUNCTION cadastrar_tipo_pagamento(
    i_nome_tipo TIPOS_PAGAMENTOS
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id INT;
BEGIN
    -- valida campo obrigatório
    IF i_nome_tipo IS NULL THEN
        RAISE NOTICE 'O campo "nome_tipo" é obrigatório.';
        RETURN NULL;
    END IF;

    -- checa duplicidade
    IF EXISTS (
        SELECT 1
          FROM "tipo_pagamento"
         WHERE "nome_tipo" = i_nome_tipo
    ) THEN
        RAISE NOTICE 'Já existe tipo de pagamento "%".', i_nome_tipo;
        RETURN NULL;
    END IF;

    -- insere
    INSERT INTO "tipo_pagamento"("nome_tipo")
    VALUES (i_nome_tipo)
    RETURNING "id_tipo_pagamento" INTO v_id;

    RETURN v_id;
END;
$$;


-- 2) ATUALIZAR TIPO DE PAGAMENTO
CREATE OR REPLACE FUNCTION atualizar_tipo_pagamento(
    u_id_tipo_pagamento INT,
    u_nome_tipo         TIPOS_PAGAMENTOS
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- verifica existência
    SELECT * INTO v_old
      FROM "tipo_pagamento"
     WHERE "id_tipo_pagamento" = u_id_tipo_pagamento;
    IF NOT FOUND THEN
        RAISE NOTICE 'Tipo de pagamento ID % não encontrado.', u_id_tipo_pagamento;
        RETURN NULL;
    END IF;

    -- valida novo nome
    IF u_nome_tipo IS NULL THEN
        RAISE NOTICE 'O campo "nome_tipo" é obrigatório.';
        RETURN NULL;
    END IF;
    IF EXISTS (
        SELECT 1
          FROM "tipo_pagamento"
         WHERE "nome_tipo" = u_nome_tipo
           AND "id_tipo_pagamento" <> u_id_tipo_pagamento
    ) THEN
        RAISE NOTICE 'Já existe outro tipo de pagamento "%".', u_nome_tipo;
        RETURN NULL;
    END IF;

    -- atualiza
    UPDATE "tipo_pagamento"
       SET "nome_tipo" = u_nome_tipo
     WHERE "id_tipo_pagamento" = u_id_tipo_pagamento;

    RETURN u_id_tipo_pagamento;
END;
$$;


-- 3) EXCLUIR TIPO DE PAGAMENTO
CREATE OR REPLACE FUNCTION excluir_tipo_pagamento(
    d_id_tipo_pagamento INT,
    d_nome_tipo         TIPOS_PAGAMENTOS
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- busca e valida existência
    SELECT * INTO v_old
      FROM "tipo_pagamento"
     WHERE "id_tipo_pagamento" = d_id_tipo_pagamento;
    IF NOT FOUND THEN
        RETURN format('Tipo de pagamento ID %s não encontrado.', d_id_tipo_pagamento);
    END IF;

    -- confere nome
    IF d_nome_tipo IS NULL
       OR v_old.nome_tipo <> d_nome_tipo THEN
        RETURN format(
          'O nome informado ("%s") não confere com o cadastro ("%s").',
          d_nome_tipo, v_old.nome_tipo
        );
    END IF;

    -- impede exclusão se houver assinaturas
    IF EXISTS (
        SELECT 1
          FROM "assinatura"
         WHERE "tipo_pagamento_id" = d_id_tipo_pagamento
    ) THEN
        RETURN format(
          'Não foi possível excluir: há assinaturas vinculadas ao tipo "%s".',
          v_old.nome_tipo
        );
    END IF;

    -- executa delete
    DELETE FROM "tipo_pagamento"
     WHERE "id_tipo_pagamento" = d_id_tipo_pagamento;

    RETURN format(
      'Tipo de pagamento "%s" (ID %s) excluído com sucesso.',
      v_old.nome_tipo, d_id_tipo_pagamento
    );
END;
$$;

CREATE OR REPLACE FUNCTION listar_tipos_pagamento()
RETURNS TABLE (
    id INT,
    nome TIPOS_PAGAMENTOS
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id_tipo_pagamento,
        nome_tipo
    FROM tipo_pagamento;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION contar_assinaturas_por_tipo_pagamento()
RETURNS TABLE (
    tipo_pagamento TIPOS_PAGAMENTOS,
    total_assinaturas INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        tp.nome_tipo,
        COUNT(a.id_assinatura)
    FROM tipo_pagamento tp
    LEFT JOIN assinatura a ON a.tipo_pagamento_id = tp.id_tipo_pagamento
    GROUP BY tp.nome_tipo;
END;
$$ LANGUAGE plpgsql;


-- Triggers
