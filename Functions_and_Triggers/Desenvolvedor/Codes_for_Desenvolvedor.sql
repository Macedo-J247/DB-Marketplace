-- Funções

-- Inserção automatizada
CREATE OR REPLACE FUNCTION cadastrar_desenvolvedor(i_nome VARCHAR, i_email VARCHAR) RETURNS INT AS $$
    DECLARE
        i_id INT;
    BEGIN
        IF EXISTS (
            SELECT 1 FROM "desenvolvedor" WHERE LOWER(email_dev) = LOWER(i_email)
        ) THEN
            RAISE NOTICE 'O email do desenvolvedor repassado já existe no banco de dados.';
            RETURN NULL;
        END IF;
        
        INSERT INTO "desenvolvedor" ("nome_dev", "email_dev", "data_cadastro")
        VALUES (i_nome, i_email, CURRENT_DATE)
        RETURNING "id_desenvolvedor" INTO i_id;

        RETURN i_id;
    END;
$$ LANGUAGE plpgsql;

-- Busca por Nome
CREATE OR REPLACE FUNCTION buscar_desenvolvedor(b_nome VARCHAR) RETURNS TABLE (id INT, nome VARCHAR, email VARCHAR, dt DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT
            id_desenvolvedor AS id,
            nome_dev AS nome,
            email_dev AS email,
            data_cadastro AS dt
        FROM "desenvolvedor"
        WHERE nome_dev ILIKE '%' || b_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Busca por data de cadastro

-- Triggers