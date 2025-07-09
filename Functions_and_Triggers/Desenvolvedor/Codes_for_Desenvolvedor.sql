-- Funções

-- Inserção automatizada
-- Testada e validada
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

-- Atualização automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION atualizar_desenvolvedor(u_id INT, u_nome VARCHAR, u_email VARCHAR) RETURNS INT AS $$
    DECLARE
        u_exists INT;
    BEGIN
        SELECT 1 INTO u_exists FROM "desenvolvedor"
        WHERE "id_desenvolvedor" = u_id;
        IF NOT FOUND THEN
            RAISE NOTICE 'Desenvolvedor não encontrado no banco de dados pelo ID repassado.';
            RETURN NULL;
        END IF;

        IF EXISTS (
            SELECT 1 FROM "desenvolvedor"
            WHERE LOWER("email_dev") = LOWER(u_email)
            AND "id_desenvolvedor" <> u_id
        ) THEN
            RAISE NOTICE 'O email repassado já está em uso por outro desenvolvedor.';
            RETURN NULL;
        END IF;

        UPDATE "desenvolvedor"
        SET "nome_dev" = u_nome, "email_dev" = u_email
        WHERE "id_desenvolvedor" = u_id;

        RETURN u_id;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION excluir_desenvolvedor(d_id INT, d_nome VARCHAR) RETURNS TEXT AS $$
    DECLARE
        d_old desenvolvedor%ROWTYPE;
    BEGIN
        SELECT * INTO d_old FROM "desenvolvedor"
        WHERE "id_desenvolvedor" = d_id;

        IF NOT FOUND THEN
            RETURN format('Nenhum desenvolvedor com ID %s encontrado.', d_id);
        END IF;

        IF LOWER(d_old.nome_dev) <> LOWER(d_nome) THEN
            RETURN format('Nome informado (%s) não confere com o cadastro (%s).', d_nome, d_old.nome_dev);
        END IF;

        IF EXISTS (
            SELECT 1 FROM "produto"
            WHERE "desenvolvedor_id" = d_id
        ) THEN
            RETURN format('Não foi possível excluir: existem produtos vinculados a %s.', d_old.nome_dev);
        END IF;

        DELETE FROM "desenvolvedor"
        WHERE "id_desenvolvedor" = d_id;

        RETURN format('Desenvolvedor %s, ID %s, excluídos do banco.', d_old.nome_dev, d_id);
    END;
$$ LANGUAGE plpgsql;

-- Busca por Nome
-- Testada e validada
CREATE OR REPLACE FUNCTION buscar_desenvolvedor(b_nome VARCHAR) RETURNS TABLE (id INT, nome VARCHAR, email VARCHAR, dt DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT id_desenvolvedor AS id, nome_dev AS nome, email_dev AS email, data_cadastro AS dt FROM "desenvolvedor"
        WHERE nome_dev ILIKE '%' || b_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Triggers
