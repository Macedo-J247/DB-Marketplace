-- Funções
-- 1) INSERIR SOFTWARE
CREATE OR REPLACE FUNCTION cadastrar_software(
    i_produto_id    INT,
    i_tipo_licenca  VARCHAR
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_id INT;
BEGIN
    -- 1.1) Validar campos
    IF i_produto_id IS NULL THEN
        RAISE NOTICE 'Campo "produto_id" é obrigatório.';
        RETURN NULL;
    END IF;
    IF i_tipo_licenca IS NULL OR trim(i_tipo_licenca) = '' THEN
        RAISE NOTICE 'Campo "tipo_licenca" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 1.2) Verificar produto existe e é do tipo "software"
    IF NOT EXISTS (
        SELECT 1
          FROM "produto"
         WHERE "id_produto" = i_produto_id
           AND "tipo" = 'software'
    ) THEN
        RAISE NOTICE 'Produto ID % não encontrado ou não é do tipo software.', i_produto_id;
        RETURN NULL;
    END IF;

    -- 1.3) Não inserir duas vezes
    IF EXISTS (
        SELECT 1
          FROM "software"
         WHERE "produto_id" = i_produto_id
    ) THEN
        RAISE NOTICE 'Já existe registro em software para o produto %.', i_produto_id;
        RETURN NULL;
    END IF;

    -- 1.4) Insere e retorna
    INSERT INTO "software"("produto_id", "tipo_licenca")
    VALUES (i_produto_id, i_tipo_licenca)
    RETURNING "produto_id" INTO v_id;

    RETURN v_id;
END;
$$;


-- 2) ATUALIZAR SOFTWARE
CREATE OR REPLACE FUNCTION atualizar_software(
    u_produto_id     INT,
    u_tipo_licenca   VARCHAR
) RETURNS INT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 2.1) Busca e valida existência
    SELECT *
      INTO v_old
      FROM "software"
     WHERE "produto_id" = u_produto_id;
    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhum registro em software para o produto % encontrado.', u_produto_id;
        RETURN NULL;
    END IF;

    -- 2.2) Validar novo valor
    IF u_tipo_licenca IS NULL OR trim(u_tipo_licenca) = '' THEN
        RAISE NOTICE 'Campo "tipo_licenca" é obrigatório.';
        RETURN NULL;
    END IF;

    -- 2.3) Executa update
    UPDATE "software"
       SET "tipo_licenca" = u_tipo_licenca
     WHERE "produto_id" = u_produto_id;

    RETURN u_produto_id;
END;
$$;


-- 3) EXCLUIR SOFTWARE
CREATE OR REPLACE FUNCTION excluir_software(
    d_produto_id      INT,
    d_tipo_licenca    VARCHAR
) RETURNS TEXT
LANGUAGE plpgsql AS
$$
DECLARE
    v_old RECORD;
BEGIN
    -- 3.1) Busca e valida existência
    SELECT *
      INTO v_old
      FROM "software"
     WHERE "produto_id" = d_produto_id;
    IF NOT FOUND THEN
        RETURN format('Nenhum registro em software para o produto %s encontrado.', d_produto_id);
    END IF;

    -- 3.2) Conferir tipo_licenca
    IF d_tipo_licenca IS NULL
       OR v_old.tipo_licenca <> d_tipo_licenca THEN
        RETURN format(
          'Licença informada ("%s") não confere com o cadastro ("%s").',
          d_tipo_licenca, v_old.tipo_licenca
        );
    END IF;

    -- 3.3) Executa delete
    DELETE FROM "software"
     WHERE "produto_id" = d_produto_id;

    -- 3.4) Mensagem de sucesso
    RETURN format(
      'Registro software do produto %s excluído (licença="%s").',
      d_produto_id, d_tipo_licenca
    );
END;
$$;

-- Triggers