-- Funções

-- Inserção automatizada
CREATE OR REPLACE FUNCTION cadastrar_versao(i_produto_id INT, i_num_versao VARCHAR, i_data_lancamento DATE) RETURNS INT AS $$
    DECLARE
        v_id INT;
        v_max_data DATE;
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM "produto" WHERE "id_produto" = i_produto_id
        ) THEN
            RAISE NOTICE 'Produto com ID % não encontrado.', i_produto_id;
            RETURN NULL;
        END IF;

        IF EXISTS (
            SELECT 1 FROM "versao"
            WHERE "produto_id" = i_produto_id AND LOWER("num_versao") = LOWER(i_num_versao)
        ) THEN
            RAISE NOTICE 'Já existe a versão "%" para o produto ID %.', i_num_versao, i_produto_id;
            RETURN NULL;
        END IF;

        SELECT MAX("data_lancamento") INTO v_max_data FROM "versao"
        WHERE "produto_id" = i_produto_id;
        IF v_max_data IS NOT NULL AND i_data_lancamento <= v_max_data THEN
            RAISE NOTICE 
            'A data_lancamento deve ser posterior a %.', v_max_data;
            RETURN NULL;
        END IF;

        INSERT INTO "versao"("produto_id", "num_versao", "data_lancamento")
        VALUES (i_produto_id, i_num_versao, i_data_lancamento)
        RETURNING "id_versao" INTO v_id;

        RETURN v_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
CREATE OR REPLACE FUNCTION atualizar_versao(u_id_versao INT, u_produto_id INT DEFAULT NULL, u_num_versao VARCHAR DEFAULT NULL, u_data_lancamento DATE DEFAULT NULL) RETURNS INT AS $$
    DECLARE
        v_old RECORD;
        v_max_date DATE;
    BEGIN
        SELECT * INTO v_old FROM "versao"
        WHERE "id_versao" = u_id_versao;
        IF NOT FOUND THEN
            RAISE NOTICE 'Nenhuma versão encontrada com ID %.', u_id_versao;
            RETURN NULL;
        END IF;

        IF u_produto_id IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM "produto" WHERE "id_produto" = u_produto_id
        )
        THEN
            RAISE NOTICE 'Produto com ID % não encontrado.', u_produto_id;
            RETURN NULL;
        END IF;

        u_produto_id := COALESCE(u_produto_id, v_old.produto_id);
        u_num_versao := COALESCE(u_num_versao, v_old.num_versao);
        u_data_lancamento := COALESCE(u_data_lancamento, v_old.data_lancamento);

        IF EXISTS (
            SELECT 1 FROM "versao"
            WHERE "produto_id" = u_produto_id AND LOWER("num_versao") = LOWER(u_num_versao) AND "id_versao" <> u_id_versao
        ) THEN
            RAISE NOTICE 'Já existe a versão "%" para o produto ID %.', u_num_versao, u_produto_id;
            RETURN NULL;
        END IF;

        IF u_data_lancamento <> v_old.data_lancamento THEN
            SELECT MAX("data_lancamento") INTO v_max_date FROM "versao"
            WHERE "produto_id" = u_produto_id AND "id_versao" <> u_id_versao;
            
            IF v_max_date IS NOT NULL AND u_data_lancamento <= v_max_date THEN
                RAISE NOTICE 'A data_lancamento deve ser posterior a %.', v_max_date;
                RETURN NULL;
            END IF;
        END IF;

        UPDATE "versao"
        SET "produto_id" = u_produto_id, "num_versao" = u_num_versao, "data_lancamento" = u_data_lancamento
        WHERE "id_versao" = u_id_versao;

        RETURN u_id_versao;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
CREATE OR REPLACE FUNCTION excluir_versao(d_id_versao INT, d_num_versao VARCHAR) RETURNS TEXT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "versao"
        WHERE "id_versao" = d_id_versao;
        IF NOT FOUND THEN
            RETURN format('Nenhuma versão com ID %s encontrada.', d_id_versao);
        END IF;

        IF d_num_versao IS NULL OR LOWER(v_old.num_versao) <> LOWER(d_num_versao) THEN
            RETURN format('O número informado ("%s") não confere com o cadastro ("%s").', d_num_versao, v_old.num_versao);
        END IF;

        -- 3.3) Impede exclusão se houver dados filhos
        IF EXISTS (
            SELECT 1 FROM "suporte" WHERE "versao_id" = d_id_versao
        ) OR EXISTS (
            SELECT 1 FROM "avaliacao" WHERE "versao_id" = d_id_versao
        ) OR EXISTS (
            SELECT 1 FROM "assinatura" WHERE "versao_id" = d_id_versao
        )
        THEN
            RETURN format('Não é possível excluir: existem registros vinculados à versão "%s".', v_old.num_versao);
        END IF;

        DELETE FROM "versao"
        WHERE "id_versao" = d_id_versao;

        RETURN format('Versão "%s" (ID %s) excluída com sucesso.', v_old.num_versao, d_id_versao);
    END;
$$ LANGUAGE plpgsql;

-- Listar todas as versões cadastradas
CREATE OR REPLACE FUNCTION listar_versoes() RETURNS TABLE (id INT, produto_id INT, nome_produto VARCHAR, num_versao VARCHAR, data_lancamento DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT v.id_versao, v.produto_id, p.nome_produto, v.num_versao, v.data_lancamento FROM versao v
        JOIN produto p ON p.id_produto = v.produto_id;
    END;
$$ LANGUAGE plpgsql;

-- Buscar as versões pelo nome do produto
CREATE OR REPLACE FUNCTION buscar_versoes_por_nome_produto(p_nome TEXT) RETURNS TABLE (id INT, nome_produto VARCHAR, num_versao VARCHAR, data_lancamento DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT v.id_versao, p.nome_produto, v.num_versao, v.data_lancamento FROM versao v
        JOIN produto p ON p.id_produto = v.produto_id
        WHERE p.nome_produto ILIKE '%' || p_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Função para buscar a última versão de um produto
CREATE OR REPLACE FUNCTION buscar_ultima_versao(p_produto_id INT) RETURNS TABLE (id INT, num_versao VARCHAR, data_lancamento DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT id_versao, num_versao, data_lancamento FROM versao
        WHERE produto_id = p_produto_id
        ORDER BY data_lancamento DESC
        LIMIT 1;
    END;
$$ LANGUAGE plpgsql;

-- Função para contar o número de versões de cada produto
CREATE OR REPLACE FUNCTION contar_versoes_por_produto() RETURNS TABLE (produto_id INT, nome_produto VARCHAR, total_versoes INT) AS $$
    BEGIN
        RETURN QUERY
        SELECT v.produto_id, p.nome_produto, COUNT(*) AS total_versoes FROM versao v
        JOIN produto p ON p.id_produto = v.produto_id
        GROUP BY v.produto_id, p.nome_produto;
    END;
$$ LANGUAGE plpgsql;

-- Triggers