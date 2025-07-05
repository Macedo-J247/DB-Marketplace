-- Funções

-- Inserção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION cadastrar_api(i_produto_id INT, i_endpoint_url VARCHAR) RETURNS INT AS $$
    DECLARE
        v_id INT;
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM "produto"
            WHERE "id_produto" = i_produto_id
            AND "tipo" = 'api'
        ) THEN
            RAISE NOTICE 'Produto ID % não encontrado ou não é do tipo api.', i_produto_id;
            RETURN NULL;
        END IF;

        IF EXISTS (
            SELECT 1 FROM "api"
            WHERE "produto_id" = i_produto_id
        ) THEN
            RAISE NOTICE 'Já existe registro em api para o produto %.', i_produto_id;
            RETURN NULL;
        END IF;

        IF EXISTS (
            SELECT 1 FROM "api"
            WHERE LOWER("endpoint_url") = LOWER(i_endpoint_url)
        ) THEN
            RAISE NOTICE 'Já existe registro em api com endpoint "%".', i_endpoint_url;
            RETURN NULL;
        END IF;

        INSERT INTO "api"("produto_id", "endpoint_url")
        VALUES (i_produto_id, i_endpoint_url)
        RETURNING "produto_id" INTO v_id;

        RETURN v_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
CREATE OR REPLACE FUNCTION atualizar_api(u_produto_id INT, u_endpoint_url VARCHAR) RETURNS INT AS $$
    DECLARE
        u_old RECORD;
    BEGIN
        SELECT * INTO u_old FROM "api"
        WHERE "produto_id" = u_produto_id;
        IF NOT FOUND THEN
            RAISE NOTICE 'Nenhum registro em api para o produto % encontrado.', u_produto_id;
            RETURN NULL;
        END IF;

        IF EXISTS (
            SELECT 1 FROM "api"
            WHERE LOWER("endpoint_url") = LOWER(u_endpoint_url)
            AND "produto_id" <> u_produto_id
        ) THEN
            RAISE NOTICE 'Já existe outro registro em api com endpoint "%".', u_endpoint_url;
            RETURN NULL;
        END IF;

        UPDATE "api"
        SET "endpoint_url" = u_endpoint_url
        WHERE "produto_id"   = u_produto_id;

        RETURN u_produto_id;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
CREATE OR REPLACE FUNCTION excluir_api(d_produto_id INT, d_endpoint_url VARCHAR) RETURNS TEXT AS $$
    DECLARE
        d_old RECORD;
    BEGIN
        SELECT * INTO d_old FROM "api"
        WHERE "produto_id" = d_produto_id;
        IF NOT FOUND THEN
            RETURN format('Nenhum registro em api para o produto %s encontrado.', d_produto_id);
        END IF;

        IF d_endpoint_url IS NULL OR d_old.endpoint_url <> d_endpoint_url THEN
            RETURN format('Endpoint informado ("%s") não confere com o cadastro ("%s").', d_endpoint_url, d_old.endpoint_url);
        END IF;

        DELETE FROM "api"
        WHERE "produto_id" = d_produto_id;

        RETURN format('Registro api do produto %s excluído (endpoint="%s").', d_produto_id, d_endpoint_url);
    END;
$$ LANGUAGE plpgsql;

-- Listar API
-- Testada e validada
CREATE OR REPLACE FUNCTION listar_apis() RETURNS TABLE (id INT, nome VARCHAR, descricao TEXT, preco NUMERIC, status STATUS_PRODUTOS, url VARCHAR, data_publicacao DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto AS id, p.nome_produto AS nome, p.descricao, p.preco, p.status, a.endpoint_url AS url, p.data_publicacao FROM produto p
        JOIN api a ON a.produto_id = p.id_produto;
    END;
$$ LANGUAGE plpgsql;

-- Busca por nome
-- Testada e validada
CREATE OR REPLACE FUNCTION buscar_apis_por_nome(p_nome TEXT) RETURNS TABLE (id INT, nome VARCHAR, url VARCHAR, status STATUS_PRODUTOS) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, a.endpoint_url, p.status FROM produto p
        JOIN api a ON a.produto_id = p.id_produto
        WHERE p.nome_produto ILIKE '%' || p_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Listar ativas
-- Testada e validada
CREATE OR REPLACE FUNCTION listar_apis_ativas() RETURNS TABLE (id INT, nome VARCHAR, url VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, a.endpoint_url FROM produto p
        JOIN api a ON a.produto_id = p.id_produto
        WHERE p.status = 'ativo';
    END;
$$ LANGUAGE plpgsql;

-- listar por preço
-- Testada e validada
CREATE FUNCTION listar_apis_por_preco() RETURNS TABLE(id integer, nome character varying, preco numeric, url character varying) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, p.preco, a.endpoint_url
        FROM produto p
        JOIN api a ON a.produto_id = p.id_produto
        ORDER BY p.preco;
    END;
$$ LANGUAGE plpgsql;

-- Triggers

-- endpoint duplicado
CREATE OR REPLACE FUNCTION normalizar_endpoint_url() RETURNS TRIGGER AS $$
    BEGIN
        NEW.endpoint_url := LOWER(TRIM(NEW.endpoint_url));
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalizar_endpoint_url
BEFORE INSERT OR UPDATE ON api
FOR EACH ROW
EXECUTE FUNCTION normalizar_endpoint_url();

-- Verificar tipo
CREATE OR REPLACE FUNCTION verificar_tipo_produto_api() RETURNS TRIGGER AS $$
    DECLARE
        tipo_prod TIPOS_PRODUTOS;
    BEGIN
        SELECT tipo INTO tipo_prod FROM produto
        WHERE id_produto = NEW.produto_id;

        IF tipo_prod IS DISTINCT FROM 'api' THEN
            RAISE EXCEPTION 'O produto associado não é do tipo API.';
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_tipo_api
BEFORE INSERT OR UPDATE ON api
FOR EACH ROW
EXECUTE FUNCTION verificar_tipo_produto_api();
