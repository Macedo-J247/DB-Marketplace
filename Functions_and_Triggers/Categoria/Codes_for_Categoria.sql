-- Funções

-- Inserção automatizada
-- Testada e validada
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

-- Atualização automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION atualizar_categoria(u_id INT, u_nome VARCHAR, u_descricao VARCHAR) RETURNS INT AS $$
    DECLARE
        u_old RECORD;
    BEGIN
        SELECT * INTO u_old
        FROM "categoria"
        WHERE "id_categoria" = u_id;
    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhuma categoria encontrada com ID %.', u_id;
        RETURN NULL;
    END IF;

    IF u_nome IS NOT NULL AND EXISTS (
        SELECT 1 FROM "categoria"
        WHERE LOWER("nome_categoria") = LOWER(u_nome)
        AND "id_categoria" <> u_id
    ) THEN
        RAISE NOTICE 'Já existe outra categoria com nome "%".', u_nome;
        RETURN NULL;
    END IF;

    UPDATE "categoria"
    SET "nome_categoria" = COALESCE(u_nome, v_old.nome_categoria), "descricao_categoria" = COALESCE(u_descricao, u_old.descricao_categoria)
    WHERE "id_categoria" = u_id;

    RETURN u_id;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
CREATE OR REPLACE FUNCTION excluir_categoria(_id INT, d_nome VARCHAR) RETURNS TEXT AS $$
    DECLARE
        d_old RECORD;
    BEGIN
        SELECT * INTO d_old FROM "categoria"
        WHERE "id_categoria" = d_id;
        IF NOT FOUND THEN
            RETURN format('Nenhuma categoria encontrada com ID %s.', d_id);
        END IF;

        IF i_nome IS NULL OR LOWER(v_old.nome_categoria) <> LOWER(i_nome) THEN
            RETURN format( 'O nome informado ("%s") não confere com o cadastro ("%s").', d_nome, v_old.nome_categoria);
        END IF;

        IF EXISTS (
            SELECT 1 FROM "produto"
            WHERE "categoria_id" = i_id
        ) THEN
            RETURN format('Não foi possível excluir: existem produtos vinculados à categoria "%s".', v_old.nome_categoria);
        END IF;

        DELETE FROM "categoria"
        WHERE "id_categoria" = i_id;

        RETURN format('Categoria "%s" (ID %s) excluída com sucesso.', v_old.nome_categoria, i_id);
    END;
$$ LANGUAGE plpgsql;

-- Busca por nome
-- Testada e validada
CREATE OR REPLACE FUNCTION buscar_categoria(b_nome VARCHAR) RETURNS TABLE (id INT, nome VARCHAR, descricao VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT c.id_categoria AS id, c.nome_categoria AS nome, c.descricao FROM categoria c
        WHERE nome_categoria ILIKE '%' || b_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Função para listar as categorias cadastradas
-- Testada e validada
CREATE OR REPLACE FUNCTION listar_categorias() RETURNS TABLE (id INT, nome VARCHAR, descricao VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT c.id_categoria, c.nome_categoria, c.descricao FROM categoria c;
    END;
$$ LANGUAGE plpgsql;

-- Função para contabilizar os produtos por categoria
-- Testada e validada
CREATE FUNCTION contar_produtos_por_categoria() RETURNS TABLE(categoria_nome VARCHAR, total BIGINT) AS $$
    BEGIN
        RETURN QUERY
        SELECT c.nome_categoria, COUNT(p.id_produto) FROM categoria c
        LEFT JOIN produto p ON c.id_categoria = p.categoria_id
        GROUP BY c.nome_categoria
        ORDER BY COUNT(p.id_produto) DESC;
    END;
$$ LANGUAGE plpgsql;

-- Triggers