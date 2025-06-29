-- Funções
-- 1) INSERIR PARCELA
CREATE OR REPLACE FUNCTION cadastrar_parcela(
    i_assinatura_id   INT,
    i_valor           DECIMAL(10,2),
    i_data_vencimento DATE,
    i_data_pagamento  DATE                 DEFAULT NULL,
    i_status          STATUS_PARCELA
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id INT;
BEGIN
    -- 1.1) Campos obrigatórios
    IF i_assinatura_id IS NULL THEN
        RAISE NOTICE 'Campo "assinatura_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_valor IS NULL OR i_valor < 0 THEN
        RAISE NOTICE 'Campo "valor" deve ser >= 0.';
        RETURN NULL;
    END IF;
    IF i_data_vencimento IS NULL THEN
        RAISE NOTICE 'Campo "data_vencimento" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_status IS NULL THEN
        RAISE NOTICE 'Campo "status" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 1.2) Valida FK assinatura
    IF NOT EXISTS (
        SELECT 1 FROM "assinatura" WHERE "id_assinatura" = i_assinatura_id
    ) THEN
        RAISE NOTICE 'Assinatura ID % não encontrada.', i_assinatura_id;
        RETURN NULL;
    END IF;

    -- 1.3) Evita duplicata na mesma assinatura e vencimento
    IF EXISTS (
        SELECT 1 FROM "parcela"
         WHERE "assinatura_id"   = i_assinatura_id
           AND "data_vencimento" = i_data_vencimento
    ) THEN
        RAISE NOTICE 
          'Já existe parcela para assinatura % com vencimento em %.',
          i_assinatura_id, i_data_vencimento;
        RETURN NULL;
    END IF;

    -- 1.4) Insere
    INSERT INTO "parcela"(
      "assinatura_id", "valor", "data_vencimento",
      "data_pagamento", "status"
    ) VALUES (
      i_assinatura_id, i_valor, i_data_vencimento,
      i_data_pagamento, i_status
    )
    RETURNING "id_parcela" INTO v_id;

    RETURN v_id;
END;
$$;


-- 2) ATUALIZAR PARCELA
CREATE OR REPLACE FUNCTION atualizar_parcela(
    u_id_parcela       INT,
    u_assinatura_id    INT              DEFAULT NULL,
    u_valor            DECIMAL(10,2)    DEFAULT NULL,
    u_data_vencimento  DATE             DEFAULT NULL,
    u_data_pagamento   DATE             DEFAULT NULL,
    u_status           STATUS_PARCELA   DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 2.1) Busca e valida existência
    SELECT * INTO v_old
      FROM "parcela"
     WHERE "id_parcela" = u_id_parcela;
    IF NOT FOUND THEN
        RAISE NOTICE 'Parcela ID % não encontrada.', u_id_parcela;
        RETURN NULL;
    END IF;

    -- 2.2) Define valores finais
    u_assinatura_id   := COALESCE(u_assinatura_id,  v_old.assinatura_id);
    u_valor           := COALESCE(u_valor,          v_old.valor);
    u_data_vencimento := COALESCE(u_data_vencimento, v_old.data_vencimento);
    u_data_pagamento  := COALESCE(u_data_pagamento,  v_old.data_pagamento);
    u_status          := COALESCE(u_status,          v_old.status);

    -- 2.3) Valida FK assinatura se alterado
    IF NOT EXISTS (
        SELECT 1 FROM "assinatura" WHERE "id_assinatura" = u_assinatura_id
    ) THEN
        RAISE NOTICE 'Assinatura ID % não encontrada.', u_assinatura_id;
        RETURN NULL;
    END IF;

    -- 2.4) Valores consistentes
    IF u_valor < 0 THEN
        RAISE NOTICE 'Campo "valor" deve ser >= 0.';
        RETURN NULL;
    END IF;
    IF u_data_vencimento IS NULL THEN
        RAISE NOTICE 'Campo "data_vencimento" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 2.5) Evita duplicata no mesmo vencimento
    IF EXISTS (
        SELECT 1 FROM "parcela"
         WHERE "assinatura_id"   = u_assinatura_id
           AND "data_vencimento" = u_data_vencimento
           AND "id_parcela"      <> u_id_parcela
    ) THEN
        RAISE NOTICE 
          'Já existe outra parcela para assinatura % com vencimento em %.',
          u_assinatura_id, u_data_vencimento;
        RETURN NULL;
    END IF;

    -- 2.6) Atualiza
    UPDATE "parcela"
       SET "assinatura_id"   = u_assinatura_id,
           "valor"           = u_valor,
           "data_vencimento" = u_data_vencimento,
           "data_pagamento"  = u_data_pagamento,
           "status"          = u_status
     WHERE "id_parcela" = u_id_parcela;

    RETURN u_id_parcela;
END;
$$;


-- 3) EXCLUIR PARCELA
CREATE OR REPLACE FUNCTION excluir_parcela(
    d_id_parcela          INT,
    d_data_vencimento     DATE
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 3.1) Busca e valida existência
    SELECT * INTO v_old
      FROM "parcela"
     WHERE "id_parcela" = d_id_parcela;
    IF NOT FOUND THEN
        RETURN format('Parcela ID %s não encontrada.', d_id_parcela);
    END IF;

    -- 3.2) Confere data de vencimento
    IF d_data_vencimento IS NULL
       OR v_old.data_vencimento <> d_data_vencimento THEN
        RETURN format(
          'Data de vencimento informada (%s) não confere com o cadastro (%s).',
          d_data_vencimento, v_old.data_vencimento
        );
    END IF;

    -- 3.3) Bloqueia exclusão de parcela paga
    IF v_old.data_pagamento IS NOT NULL
       OR v_old.status = 'pago' THEN
        RETURN format(
          'Não foi possível excluir: parcela %s já está marcada como paga.',
          d_id_parcela
        );
    END IF;

    -- 3.4) Executa delete
    DELETE FROM "parcela"
     WHERE "id_parcela" = d_id_parcela;

    -- 3.5) Retorna mensagem de sucesso
    RETURN format(
      'Parcela %s com vencimento em %s excluída com sucesso.',
      d_id_parcela, d_data_vencimento
    );
END;
$$;

-- Triggers
