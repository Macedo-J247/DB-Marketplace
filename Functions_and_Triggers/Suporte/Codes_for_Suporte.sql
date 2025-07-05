-- Funções

-- Inserção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION cadastrar_suporte(i_usuario_id INT, i_produto_id INT, i_versao_id INT, i_tipo TIPOS_SUPORTES, i_descricao TEXT, i_status STATUS_SUPORTE DEFAULT 'aberto') RETURNS INT AS $$
    DECLARE
        v_id INT;
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM "usuario" WHERE "id_usuario" = i_usuario_id
        ) THEN
            RAISE NOTICE 'Usuário ID % não encontrado.', i_usuario_id;
            RETURN NULL;
        END IF;
        
        IF NOT EXISTS (
            SELECT 1 FROM "produto" WHERE "id_produto" = i_produto_id
        ) THEN
            RAISE NOTICE 'Produto ID % não encontrado.', i_produto_id;
            RETURN NULL;
        END IF;
        
        IF NOT EXISTS (
            SELECT 1 FROM "versao"
            WHERE "id_versao" = i_versao_id AND "produto_id" = i_produto_id
        ) THEN
            RAISE NOTICE 'Versão ID % não encontrada ou não pertence ao produto %.', i_versao_id, i_produto_id;
            RETURN NULL;
        END IF;

        INSERT INTO "suporte"("usuario_id", "produto_id", "versao_id", "tipo", "descricao", "status")
        VALUES (i_usuario_id, i_produto_id, i_versao_id, i_tipo, i_descricao, i_status)
        RETURNING "id_suporte" INTO v_id;

        RETURN v_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
-- Testada e atualizada
CREATE OR REPLACE FUNCTION atualizar_suporte(u_id_suporte INT, u_tipo TIPOS_SUPORTES, u_descricao TEXT, u_status STATUS_SUPORTE) RETURNS INT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "suporte"
        WHERE "id_suporte" = u_id_suporte;
        IF NOT FOUND THEN
            RAISE NOTICE 'Suporte ID % não encontrado.', u_id_suporte;
            RETURN NULL;
        END IF;

        IF u_tipo IS NULL THEN 
            u_tipo := v_old.tipo;
        END IF;
        
        IF u_descricao IS NULL THEN
            u_descricao := v_old.descricao;
        END IF;
        
        IF u_status IS NULL THEN
            u_status := v_old.status;
        END IF;

        UPDATE "suporte"
        SET "tipo" = u_tipo, "descricao" = u_descricao, "status" = u_status
        WHERE "id_suporte" = u_id_suporte;

        RETURN u_id_suporte;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
CREATE OR REPLACE_FUNCTION excluir_suporte(d_id_suporte INT, d_usuario_id INT) RETURNS TEXT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "suporte"
        WHERE "id_suporte" = d_id_suporte;
        IF NOT FOUND THEN
            RETURN format('Suporte ID %s não encontrado.', d_id_suporte);
        END IF;

        IF v_old.usuario_id <> d_usuario_id THEN
            RETURN format('Não confere: o chamado %s não pertence ao usuário %s.', d_id_suporte, d_usuario_id);
        END IF;

        DELETE FROM "suporte"
        WHERE "id_suporte" = d_id_suporte;

        RETURN format('Chamado %s excluído com sucesso.', d_id_suporte);
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION listar_suportes() RETURNS TABLE (id INT, usuario VARCHAR, produto VARCHAR, versao VARCHAR, tipo TIPOS_SUPORTES, status STATUS_SUPORTE, data TIMESTAMP, descricao TEXT) AS $$
    BEGIN
        RETURN QUERY
        SELECT s.id_suporte, u.nome_usuario, p.nome_produto, v.num_versao, s.tipo, s.status, s.data_suporte, s.descricao FROM suporte s
        JOIN usuario u ON u.id_usuario = s.usuario_id
        JOIN produto p ON p.id_produto = s.produto_id
        JOIN versao v ON v.id_versao = s.versao_id;
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION buscar_suporte_por_usuario(p_nome TEXT) RETURNS TABLE (id INT, tipo TIPOS_SUPORTES, status STATUS_SUPORTE, data TIMESTAMP, descricao TEXT) AS $$
    BEGIN
        RETURN QUERY
        SELECT s.id_suporte, s.tipo, s.status, s.data_suporte, s.descricao FROM suporte s
        JOIN usuario u ON u.id_usuario = s.usuario_id
        WHERE u.nome_usuario ILIKE '%' || p_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION listar_suportes_ativos() RETURNS TABLE (id INT, usuario VARCHAR, produto VARCHAR, tipo TIPOS_SUPORTES, status STATUS_SUPORTE, data TIMESTAMP) AS $$
    BEGIN
        RETURN QUERY
        SELECT s.id_suporte, u.nome_usuario, p.nome_produto, s.tipo, s.status, s.data_suporte FROM suporte s
        JOIN usuario u ON u.id_usuario = s.usuario_id
        JOIN produto p ON p.id_produto = s.produto_id
        WHERE s.status IN ('aberto', 'em andamento');
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION contar_suportes_por_status() RETURNS TABLE (status public.status_suporte, total bigint) AS $$
    BEGIN
        RETURN QUERY
        SELECT s.status, COUNT(*) FROM suporte s
        GROUP BY s.status;
    END;
$$ LANGUAGE plpgsql;

-- Triggers
