-- Funções

-- Inserção
-- Testada e validada
CREATE OR REPLACE FUNCTION cadastrar_avaliacao(i_usuario_id INT, i_versao_id INT, i_nota DECIMAL(3,2)) RETURNS INT AS $$
    DECLARE
        i_id INT;
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM "usuario" WHERE "id_usuario" = i_usuario_id
        ) THEN
            RAISE NOTICE 'Usuário ID % não encontrado.', i_usuario_id;
            RETURN NULL;
        END IF;
    
        IF NOT EXISTS (
            SELECT 1 FROM "versao" WHERE "id_versao" = i_versao_id
        ) THEN
            RAISE NOTICE 'Versão ID % não encontrada.', i_versao_id;
            RETURN NULL;
        END IF;
        
        IF i_nota < 0 OR i_nota > 10 THEN
            RAISE NOTICE 'Campo "nota" deve estar entre 0.00 e 10.00.';
            RETURN NULL;
        END IF;
        
        IF EXISTS (
            SELECT 1 FROM "avaliacao"
            WHERE "usuario_id" = i_usuario_id
            AND "versao_id"  = i_versao_id
        ) THEN
            RAISE NOTICE 'Usuário % já avaliou a versão %.', i_usuario_id, i_versao_id;
            RETURN NULL;
        END IF;

        INSERT INTO "avaliacao"("usuario_id", "versao_id", "nota", "data_avaliacao")
        VALUES (i_usuario_id, i_versao_id, i_nota, CURRENT_TIMESTAMP)
        RETURNING "id_avaliacao" INTO i_id;

        RETURN i_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION atualizar_avaliacao(u_id_avaliacao INT, u_nota DECIMAL(3,2), u_data_avaliacao DATE) RETURNS INT AS $$
    DECLARE
        v_old RECORD;
        v_new_nota DECIMAL(3,2);
        v_new_data DATE;
    BEGIN
        SELECT * INTO v_old
        FROM "avaliacao"
        WHERE "id_avaliacao" = u_id_avaliacao;
        IF NOT FOUND THEN
            RAISE NOTICE 'Avaliação ID % não encontrada.', u_id_avaliacao;
            RETURN NULL;
        END IF;

        v_new_nota := COALESCE(u_nota, v_old.nota);
        v_new_data := COALESCE(u_data_avaliacao, v_old.data_avaliacao);

        IF v_new_nota < 0 OR v_new_nota > 10 THEN
            RAISE NOTICE 'Campo "nota" deve estar entre 0.00 e 10.00.';
            RETURN NULL;
        END IF;
        IF v_new_data IS NULL THEN
            RAISE NOTICE 'Campo "data_avaliacao" é obrigatório.';
            RETURN NULL;
        END IF;

        UPDATE "avaliacao"
        SET "nota" = v_new_nota, "data_avaliacao" = v_new_data
        WHERE "id_avaliacao" = u_id_avaliacao;

        RETURN u_id_avaliacao;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION excluir_avaliacao(d_id_avaliacao INT, d_usuario_id INT) RETURNS TEXT AS $$
    DECLARE
        d_old RECORD;
    BEGIN
        SELECT * INTO d_old FROM "avaliacao"
        WHERE "id_avaliacao" = d_id_avaliacao;  
        IF NOT FOUND THEN
            RETURN format('Avaliação ID %s não encontrada.', d_id_avaliacao);
        END IF;
        
        IF d_old.usuario_id <> d_usuario_id THEN
            RETURN format('Não confere: avaliação %s não pertence ao usuário %s.', d_id_avaliacao, d_usuario_id);
        END IF;

        DELETE FROM "avaliacao"
        WHERE "id_avaliacao" = d_id_avaliacao;

        RETURN format('Avaliação %s excluída com sucesso.', d_id_avaliacao);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listar_avaliacoes() RETURNS TABLE (id INT, usuario VARCHAR, produto VARCHAR, versao VARCHAR, nota DECIMAL(3,2), data DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT a.id_avaliacao, u.nome_usuario, p.nome_produto, v.num_versao, a.nota, a.data_avaliacao FROM avaliacao a
        JOIN usuario u ON u.id_usuario = a.usuario_id
        JOIN versao v ON v.id_versao = a.versao_id
        JOIN produto p ON p.id_produto = v.produto_id;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_avaliacoes_por_produto(p_nome TEXT) RETURNS TABLE (usuario VARCHAR, versao VARCHAR, nota DECIMAL(3,2), data DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT u.nome_usuario, v.num_versao, a.nota, a.data_avaliacao FROM avaliacao a
        JOIN usuario u ON u.id_usuario = a.usuario_id
        JOIN versao v ON v.id_versao = a.versao_id
        JOIN produto p ON p.id_produto = v.produto_id
        WHERE p.nome_produto ILIKE '%' || p_nome || '%';
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION media_avaliacao_por_versao(p_versao_id INT) RETURNS DECIMAL(4,2) AS $$
    DECLARE
        media DECIMAL(4,2);
    BEGIN
        SELECT ROUND(AVG(nota), 2) INTO media FROM avaliacao
        WHERE versao_id = p_versao_id;

        RETURN COALESCE(media, 0);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION contar_avaliacoes_por_produto() RETURNS TABLE (produto VARCHAR, total_avaliacoes INT) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.nome_produto, COUNT(*) AS total_avaliacoes FROM avaliacao a
        JOIN versao v ON v.id_versao = a.versao_id
        JOIN produto p ON p.id_produto = v.produto_id
        GROUP BY p.nome_produto;
    END;
$$ LANGUAGE plpgsql;

-- Triggers