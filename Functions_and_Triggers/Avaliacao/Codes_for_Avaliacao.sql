-- Funções
-- 1) INSERIR AVALIAÇÃO
CREATE OR REPLACE FUNCTION cadastrar_avaliacao(
    i_usuario_id     INT,
    i_versao_id      INT,
    i_nota           DECIMAL(3,2),
    i_data_avaliacao DATE
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id   INT;
BEGIN
    -- 1.1) Campos obrigatórios
    IF i_usuario_id IS NULL THEN
        RAISE NOTICE 'Campo "usuario_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_versao_id IS NULL THEN
        RAISE NOTICE 'Campo "versao_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_nota IS NULL THEN
        RAISE NOTICE 'Campo "nota" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_data_avaliacao IS NULL THEN
        RAISE NOTICE 'Campo "data_avaliacao" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 1.2) FK existem?
    IF NOT EXISTS (SELECT 1 FROM "usuario" WHERE "id_usuario" = i_usuario_id) THEN
        RAISE NOTICE 'Usuário ID % não encontrado.', i_usuario_id;
        RETURN NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "versao" WHERE "id_versao" = i_versao_id) THEN
        RAISE NOTICE 'Versão ID % não encontrada.', i_versao_id;
        RETURN NULL;
    END IF;

    -- 1.3) Nota válida?
    IF i_nota < 0 OR i_nota > 10 THEN
        RAISE NOTICE 'Campo "nota" deve estar entre 0.00 e 10.00.';
        RETURN NULL;
    END IF;

    -- 1.4) Unicidade por usuário+versão
    IF EXISTS (
        SELECT 1
          FROM "avaliacao"
         WHERE "usuario_id" = i_usuario_id
           AND "versao_id"  = i_versao_id
    ) THEN
        RAISE NOTICE 
          'Usuário % já avaliou a versão %.', 
          i_usuario_id, i_versao_id;
        RETURN NULL;
    END IF;

    -- 1.5) Insere
    INSERT INTO "avaliacao"(
      "usuario_id", "versao_id", "nota", "data_avaliacao"
    ) VALUES (
      i_usuario_id, i_versao_id, i_nota, i_data_avaliacao
    )
    RETURNING "id_avaliacao" INTO v_id;

    RETURN v_id;
END;
$$;


-- 2) ATUALIZAR AVALIAÇÃO
CREATE OR REPLACE FUNCTION atualizar_avaliacao(
    u_id_avaliacao    INT,
    u_nota            DECIMAL(3,2)   DEFAULT NULL,
    u_data_avaliacao  DATE           DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
    v_new_nota DECIMAL(3,2);
    v_new_data DATE;
BEGIN
    -- 2.1) Existe?
    SELECT * INTO v_old
      FROM "avaliacao"
     WHERE "id_avaliacao" = u_id_avaliacao;
    IF NOT FOUND THEN
        RAISE NOTICE 'Avaliação ID % não encontrada.', u_id_avaliacao;
        RETURN NULL;
    END IF;

    -- 2.2) Define valores finais
    v_new_nota := COALESCE(u_nota,           v_old.nota);
    v_new_data := COALESCE(u_data_avaliacao, v_old.data_avaliacao);

    -- 2.3) Validações
    IF v_new_nota < 0 OR v_new_nota > 10 THEN
        RAISE NOTICE 'Campo "nota" deve estar entre 0.00 e 10.00.';
        RETURN NULL;
    END IF;
    IF v_new_data IS NULL THEN
        RAISE NOTICE 'Campo "data_avaliacao" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 2.4) Executa update
    UPDATE "avaliacao"
       SET "nota"           = v_new_nota,
           "data_avaliacao" = v_new_data
     WHERE "id_avaliacao" = u_id_avaliacao;

    RETURN u_id_avaliacao;
END;
$$;


-- 3) EXCLUIR AVALIAÇÃO
CREATE OR REPLACE FUNCTION excluir_avaliacao(
    d_id_avaliacao  INT,
    d_usuario_id    INT
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 3.1) Busca e valida existência
    SELECT * INTO v_old
      FROM "avaliacao"
     WHERE "id_avaliacao" = d_id_avaliacao;
    IF NOT FOUND THEN
        RETURN format('Avaliação ID %s não encontrada.', d_id_avaliacao);
    END IF;
        
        IF v_old.usuario_id <> d_usuario_id THEN
            RETURN format('Não confere: avaliação %s não pertence ao usuário %s.', d_id_avaliacao, d_usuario_id);
        END IF;

        DELETE FROM "avaliacao"
        WHERE "id_avaliacao" = d_id_avaliacao;

        RETURN format('Avaliação %s excluída com sucesso.', d_id_avaliacao);
    END;
$$ LANGUAGE plpgsql;

-- Triggers