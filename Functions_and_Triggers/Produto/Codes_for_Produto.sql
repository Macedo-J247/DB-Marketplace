-- Funções
-- 1) INSERIR PRODUTO
CREATE OR REPLACE FUNCTION cadastrar_produto(
    i_desenvolvedor_id INT,
    i_categoria_id     INT,
    i_nome_produto     VARCHAR,
    i_descricao        TEXT    DEFAULT NULL,
    i_preco            DECIMAL(10,2),
    i_tipo             TIPOS_PRODUTOS,
    i_status           STATUS_PRODUTOS,
    i_data_publicacao  DATE
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id INT;
BEGIN
    -- campos obrigatórios
    IF i_desenvolvedor_id IS NULL THEN
        RAISE NOTICE 'Campo "desenvolvedor_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_categoria_id IS NULL THEN
        RAISE NOTICE 'Campo "categoria_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_nome_produto IS NULL OR trim(i_nome_produto) = '' THEN
        RAISE NOTICE 'Campo "nome_produto" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_preco IS NULL OR i_preco < 0 THEN
        RAISE NOTICE 'Campo "preco" deve ser >= 0.';
        RETURN NULL;
    END IF;
    IF i_tipo IS NULL THEN
        RAISE NOTICE 'Campo "tipo" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_status IS NULL THEN
        RAISE NOTICE 'Campo "status" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_data_publicacao IS NULL THEN
        RAISE NOTICE 'Campo "data_publicacao" é obrigatório.';
        RETURN NULL;
    END IF;

    -- valida FKs
    IF NOT EXISTS (SELECT 1 FROM "desenvolvedor" WHERE "id_desenvolvedor" = i_desenvolvedor_id) THEN
        RAISE NOTICE 'Desenvolvedor ID % não encontrado.', i_desenvolvedor_id;
        RETURN NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM "categoria"     WHERE "id_categoria"    = i_categoria_id) THEN
        RAISE NOTICE 'Categoria ID % não encontrado.', i_categoria_id;
        RETURN NULL;
    END IF;

    -- insert
    INSERT INTO "produto"(
      "desenvolvedor_id", "categoria_id",
      "nome_produto", "descricao",
      "preco", "tipo", "status",
      "data_publicacao"
    )
    VALUES (
      i_desenvolvedor_id, i_categoria_id,
      i_nome_produto, i_descricao,
      i_preco, i_tipo, i_status,
      i_data_publicacao
    )
    RETURNING "id_produto" INTO v_id;

    RETURN v_id;
END;
$$;


-- 2) ATUALIZAR PRODUTO
CREATE OR REPLACE FUNCTION atualizar_produto(
    u_id_produto       INT,
    u_desenvolvedor_id INT            DEFAULT NULL,
    u_categoria_id     INT            DEFAULT NULL,
    u_nome_produto     VARCHAR        DEFAULT NULL,
    u_descricao        TEXT           DEFAULT NULL,
    u_preco            DECIMAL(10,2)  DEFAULT NULL,
    u_tipo             TIPOS_PRODUTOS DEFAULT NULL,
    u_status           STATUS_PRODUTOS DEFAULT NULL,
    u_data_publicacao  DATE           DEFAULT NULL,
    u_data_atualizacao DATE           DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 2.1) existe?
    SELECT * INTO v_old
      FROM "produto"
     WHERE "id_produto" = u_id_produto;
    IF NOT FOUND THEN
        RAISE NOTICE 'Produto ID % não encontrado.', u_id_produto;
        RETURN NULL;
    END IF;

    -- 2.2) valida FKs se mudando
    IF u_desenvolvedor_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM "desenvolvedor" WHERE "id_desenvolvedor" = u_desenvolvedor_id)
    THEN
        RAISE NOTICE 'Desenvolvedor ID % não encontrado.', u_desenvolvedor_id;
        RETURN NULL;
    END IF;
    IF u_categoria_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM "categoria" WHERE "id_categoria" = u_categoria_id)
    THEN
        RAISE NOTICE 'Categoria ID % não encontrado.', u_categoria_id;
        RETURN NULL;
    END IF;

    -- 2.3) preço não negativo
    IF u_preco IS NOT NULL AND u_preco < 0 THEN
        RAISE NOTICE 'Campo "preco" deve ser >= 0.';
        RETURN NULL;
    END IF;

    -- 2.4) set defaults
    u_desenvolvedor_id := COALESCE(u_desenvolvedor_id, v_old.desenvolvedor_id);
    u_categoria_id     := COALESCE(u_categoria_id,     v_old.categoria_id);
    u_nome_produto     := COALESCE(u_nome_produto,     v_old.nome_produto);
    u_descricao        := COALESCE(u_descricao,        v_old.descricao);
    u_preco            := COALESCE(u_preco,            v_old.preco);
    u_tipo             := COALESCE(u_tipo,             v_old.tipo);
    u_status           := COALESCE(u_status,           v_old.status);
    u_data_publicacao  := COALESCE(u_data_publicacao,  v_old.data_publicacao);
    u_data_atualizacao := COALESCE(u_data_atualizacao, CURRENT_DATE);

    -- 2.5) update
    UPDATE "produto"
       SET "desenvolvedor_id" = u_desenvolvedor_id,
           "categoria_id"     = u_categoria_id,
           "nome_produto"     = u_nome_produto,
           "descricao"        = u_descricao,
           "preco"            = u_preco,
           "tipo"             = u_tipo,
           "status"           = u_status,
           "data_publicacao"  = u_data_publicacao,
           "data_atualizacao" = u_data_atualizacao
     WHERE "id_produto" = u_id_produto;

    RETURN u_id_produto;
END;
$$;


-- 3) EXCLUIR PRODUTO
CREATE OR REPLACE FUNCTION excluir_produto(
    d_id_produto    INT,
    d_nome_produto  VARCHAR
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 3.1) existe?
    SELECT * INTO v_old
      FROM "produto"
     WHERE "id_produto" = d_id_produto;
    IF NOT FOUND THEN
        RETURN format('Produto ID %s não encontrado.', d_id_produto);
    END IF;

    -- 3.2) confere nome
    IF d_nome_produto IS NULL
       OR LOWER(v_old.nome_produto) <> LOWER(d_nome_produto) THEN
        RETURN format(
          'Nome informado ("%s") não confere com "%s".',
          d_nome_produto, v_old.nome_produto
        );
    END IF;

    -- 3.3) bloqueia se houver filhos
    IF EXISTS (SELECT 1 FROM "versao"     WHERE "produto_id" = d_id_produto)
     OR EXISTS (SELECT 1 FROM "suporte"    WHERE "produto_id" = d_id_produto)
     OR EXISTS (SELECT 1 FROM "assinatura" WHERE "versao_id" IN (
            SELECT "id_versao" FROM "versao" WHERE "produto_id" = d_id_produto
        ))
    THEN
        RETURN format(
          'Não foi possível excluir: existem registros vinculados ao produto "%s".',
          v_old.nome_produto
        );
    END IF;

    -- 3.4) delete
    DELETE FROM "produto"
     WHERE "id_produto" = d_id_produto;

    -- 3.5) mensagem
    RETURN format(
      'Produto "%s" (ID %s) excluído com sucesso.',
      v_old.nome_produto, d_id_produto
    );
END;
$$;

-- Triggers