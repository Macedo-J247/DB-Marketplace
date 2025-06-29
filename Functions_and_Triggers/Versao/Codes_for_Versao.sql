-- Funções
-- Inserção automatizada
CREATE OR REPLACE FUNCTION cadastrar_versao(
    i_produto_id      INT,
    i_num_versao      VARCHAR,
    i_data_lancamento DATE
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id INT;
    v_max_data DATE;
BEGIN
    -- 1.1) Campos obrigatórios
    IF i_produto_id IS NULL THEN
        RAISE NOTICE 'O campo "produto_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_num_versao IS NULL OR trim(i_num_versao) = '' THEN
        RAISE NOTICE 'O campo "num_versao" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_data_lancamento IS NULL THEN
        RAISE NOTICE 'O campo "data_lancamento" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 1.2) Produto existe?
    IF NOT EXISTS (
      SELECT 1 FROM "produto" WHERE "id_produto" = i_produto_id
    ) THEN
        RAISE NOTICE 'Produto com ID % não encontrado.', i_produto_id;
        RETURN NULL;
    END IF;

    -- 1.3) Unicidade de versão
    IF EXISTS (
      SELECT 1
        FROM "versao"
       WHERE "produto_id" = i_produto_id
         AND LOWER("num_versao") = LOWER(i_num_versao)
    ) THEN
        RAISE NOTICE 
          'Já existe a versão "%" para o produto ID %.',
          i_num_versao, i_produto_id;
        RETURN NULL;
    END IF;

    -- 1.4) Data crescente
    SELECT MAX("data_lancamento") INTO v_max_data
      FROM "versao"
     WHERE "produto_id" = i_produto_id;
    IF v_max_data IS NOT NULL AND i_data_lancamento <= v_max_data THEN
        RAISE NOTICE 
          'A data_lancamento deve ser posterior a %.', v_max_data;
        RETURN NULL;
    END IF;

    -- 1.5) Insere
    INSERT INTO "versao"(
      "produto_id", "num_versao", "data_lancamento"
    )
    VALUES (
      i_produto_id, i_num_versao, i_data_lancamento
    )
    RETURNING "id_versao" INTO v_id;

    RETURN v_id;
END;
$$;

-- Atualização automatizada
CREATE OR REPLACE FUNCTION atualizar_versao(
    u_id_versao       INT,
    u_produto_id      INT         DEFAULT NULL,
    u_num_versao      VARCHAR     DEFAULT NULL,
    u_data_lancamento DATE        DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
    v_max_date DATE;
BEGIN
    -- 2.1) Busca e valida existência
    SELECT * INTO v_old
      FROM "versao"
     WHERE "id_versao" = u_id_versao;
    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhuma versão encontrada com ID %.', u_id_versao;
        RETURN NULL;
    END IF;

    -- 2.2) Se trocar produto, valida existência
    IF u_produto_id IS NOT NULL
       AND NOT EXISTS (
         SELECT 1 FROM "produto" WHERE "id_produto" = u_produto_id
       )
    THEN
        RAISE NOTICE 'Produto com ID % não encontrado.', u_produto_id;
        RETURN NULL;
    END IF;

    -- define valores finais
    u_produto_id      := COALESCE(u_produto_id, v_old.produto_id);
    u_num_versao      := COALESCE(u_num_versao, v_old.num_versao);
    u_data_lancamento := COALESCE(u_data_lancamento, v_old.data_lancamento);

    -- 2.3) Unicidade de versão
    IF EXISTS (
      SELECT 1
        FROM "versao"
       WHERE "produto_id" = u_produto_id
         AND LOWER("num_versao") = LOWER(u_num_versao)
         AND "id_versao" <> u_id_versao
    ) THEN
        RAISE NOTICE 
          'Já existe a versão "%" para o produto ID %.',
          u_num_versao, u_produto_id;
        RETURN NULL;
    END IF;

    -- 2.4) Data crescente se alterada
    IF u_data_lancamento <> v_old.data_lancamento THEN
        SELECT MAX("data_lancamento") INTO v_max_date
          FROM "versao"
         WHERE "produto_id" = u_produto_id
           AND "id_versao" <> u_id_versao;
        IF v_max_date IS NOT NULL AND u_data_lancamento <= v_max_date THEN
            RAISE NOTICE 
              'A data_lancamento deve ser posterior a %.', v_max_date;
            RETURN NULL;
        END IF;
    END IF;

    -- 2.5) Executa update
    UPDATE "versao"
       SET "produto_id"      = u_produto_id,
           "num_versao"      = u_num_versao,
           "data_lancamento" = u_data_lancamento
     WHERE "id_versao" = u_id_versao;

    RETURN u_id_versao;
END;
$$;

-- Remoção automatizada
CREATE OR REPLACE FUNCTION excluir_versao(
    d_id_versao   INT,
    d_num_versao  VARCHAR
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 3.1) Busca e valida existência
    SELECT * INTO v_old
      FROM "versao"
     WHERE "id_versao" = d_id_versao;
    IF NOT FOUND THEN
        RETURN format('Nenhuma versão com ID %s encontrada.', d_id_versao);
    END IF;

    -- 3.2) Confere número de versão
    IF d_num_versao IS NULL
       OR LOWER(v_old.num_versao) <> LOWER(d_num_versao) THEN
        RETURN format(
          'O número informado ("%s") não confere com o cadastro ("%s").',
          d_num_versao, v_old.num_versao
        );
    END IF;

    -- 3.3) Impede exclusão se houver dados filhos
    IF EXISTS (SELECT 1 FROM "suporte"    WHERE "versao_id" = d_id_versao)
     OR EXISTS (SELECT 1 FROM "avaliacao"  WHERE "versao_id" = d_id_versao)
     OR EXISTS (SELECT 1 FROM "assinatura" WHERE "versao_id" = d_id_versao)
    THEN
        RETURN format(
          'Não é possível excluir: existem registros vinculados à versão "%s".',
          v_old.num_versao
        );
    END IF;

    -- 3.4) Executa DELETE
    DELETE FROM "versao"
     WHERE "id_versao" = d_id_versao;

    -- 3.5) Retorna mensagem
    RETURN format(
      'Versão "%s" (ID %s) excluída com sucesso.',
      v_old.num_versao, d_id_versao
    );
END;
$$;



-- Triggers