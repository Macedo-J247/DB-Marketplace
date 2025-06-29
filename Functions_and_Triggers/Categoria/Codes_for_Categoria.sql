-- Funções

-- Inserção automatizada
CREATE OR REPLACE FUNCTION cadastrar_categoria(i_nome VARCHAR, i_descricao VARCHAR DEFAULT NULL) RETURNS INT AS $$
    DECLARE
        i_id INT;
    BEGIN
        IF EXISTS (
            SELECT 1 FROM "categoria" WHERE LOWER(nome_categoria) = LOWER(i_nome)
        ) THEN
            RAISE NOTICE 'A categoria repassada já existe no banco de dados.';
            RETURN NULL;
        END IF;

        INSERT INTO "categoria" (nome_categoria, descricao)
        VALUES (i_nome, i_descricao)
        RETURNING id_categoria INTO i_id;

        RETURN i_id;
    END;
$$ LANGUAGE plpgsql;

-- Busca por nome
CREATE OR REPLACE FUNCTION buscar_categoria(b_nome VARCHAR) RETURNS TABLE (id INT, nome VARCHAR, descricao VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT
            id_categoria AS id,
            nome_categoria AS nome,
            descricao_categoria AS descricao
        FROM "categoria"
        WHERE nome_categoria ILIKE '%' || b_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Triggers