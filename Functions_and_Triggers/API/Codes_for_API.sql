-- Funções
-- 4) INSERIR API
CREATE OR REPLACE FUNCTION cadastrar_api(
    i_produto_id    INT,
    i_endpoint_url  VARCHAR
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id INT;
BEGIN
    -- 4.1) Validar campos
    IF i_produto_id IS NULL THEN
        RAISE NOTICE 'Campo "produto_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_endpoint_url IS NULL OR trim(i_endpoint_url) = '' THEN
        RAISE NOTICE 'Campo "endpoint_url" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 4.2) Verificar produto existe e é do tipo "api"
    IF NOT EXISTS (
        SELECT 1
          FROM "produto"
         WHERE "id_produto" = i_produto_id
           AND "tipo" = 'api'
    ) THEN
        RAISE NOTICE 'Produto ID % não encontrado ou não é do tipo api.', i_produto_id;
        RETURN NULL;
    END IF;

    -- 4.3) Não inserir duplicata
    IF EXISTS (
        SELECT 1
          FROM "api"
         WHERE "produto_id" = i_produto_id
    ) THEN
        RAISE NOTICE 'Já existe registro em api para o produto %.', i_produto_id;
        RETURN NULL;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM "api"
         WHERE LOWER("endpoint_url") = LOWER(i_endpoint_url)
    ) THEN
        RAISE NOTICE 'Já existe registro em api com endpoint "%".', i_endpoint_url;
        RETURN NULL;
    END IF;

    -- 4.4) Insere e retorna
    INSERT INTO "api"("produto_id", "endpoint_url")
    VALUES (i_produto_id, i_endpoint_url)
    RETURNING "produto_id" INTO v_id;

    RETURN v_id;
END;
$$;


-- 5) ATUALIZAR API
CREATE OR REPLACE FUNCTION atualizar_api(
    u_produto_id     INT,
    u_endpoint_url   VARCHAR
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 5.1) Busca e valida existência
    SELECT *
      INTO v_old
      FROM "api"
     WHERE "produto_id" = u_produto_id;
    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhum registro em api para o produto % encontrado.', u_produto_id;
        RETURN NULL;
    END IF;

    -- 5.2) Validar novo URL e unicidade
    IF u_endpoint_url IS NULL OR trim(u_endpoint_url) = '' THEN
        RAISE NOTICE 'Campo "endpoint_url" é obrigatório.';
        RETURN NULL;
    END IF;
    IF EXISTS (
        SELECT 1
          FROM "api"
         WHERE LOWER("endpoint_url") = LOWER(u_endpoint_url)
           AND "produto_id" <> u_produto_id
    ) THEN
        RAISE NOTICE 'Já existe outro registro em api com endpoint "%".', u_endpoint_url;
        RETURN NULL;
    END IF;

    -- 5.3) Executa update
    UPDATE "api"
       SET "endpoint_url" = u_endpoint_url
     WHERE "produto_id"   = u_produto_id;

    RETURN u_produto_id;
END;
$$;


-- 6) EXCLUIR API
CREATE OR REPLACE FUNCTION excluir_api(
    d_produto_id     INT,
    d_endpoint_url   VARCHAR
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 6.1) Busca e valida existência
    SELECT *
      INTO v_old
      FROM "api"
     WHERE "produto_id" = d_produto_id;
    IF NOT FOUND THEN
        RETURN format('Nenhum registro em api para o produto %s encontrado.', d_produto_id);
    END IF;

    -- 6.2) Conferir endpoint_url
    IF d_endpoint_url IS NULL
       OR v_old.endpoint_url <> d_endpoint_url THEN
        RETURN format(
          'Endpoint informado ("%s") não confere com o cadastro ("%s").',
          d_endpoint_url, v_old.endpoint_url
        );
    END IF;

    -- 6.3) Executa delete
    DELETE FROM "api"
     WHERE "produto_id" = d_produto_id;

    -- 6.4) Mensagem de sucesso
    RETURN format(
      'Registro api do produto %s excluído (endpoint="%s").',
      d_produto_id, d_endpoint_url
    );
END;
$$;

-- Triggers