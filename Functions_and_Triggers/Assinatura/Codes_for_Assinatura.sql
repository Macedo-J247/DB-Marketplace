-- Funções

-- Inserção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION cadastrar_assinatura(i_usuario_id INT, i_versao_id INT, i_tipo_pagamento_id INT, i_data_inicio DATE, i_data_termino DATE DEFAULT NULL, i_status STATUS_ASSINATURA DEFAULT 'ativa') RETURNS INT AS $$
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
            SELECT 1 FROM "versao" WHERE "id_versao" = i_versao_id
        ) THEN
            RAISE NOTICE 'Versão ID % não encontrada.', i_versao_id;
            RETURN NULL;
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM "tipo_pagamento" WHERE "id_tipo_pagamento" = i_tipo_pagamento_id
        ) THEN
            RAISE NOTICE 'Tipo de pagamento ID % não encontrado.', i_tipo_pagamento_id;
            RETURN NULL;
        END IF;

        IF i_data_termino IS NOT NULL
        AND i_data_termino < i_data_inicio THEN
            RAISE NOTICE 'Data término não pode ser anterior à data início.';
            RETURN NULL;
        END IF;

        INSERT INTO "assinatura"("usuario_id", "versao_id", "tipo_pagamento_id", "data_inicio", "data_termino", "status")
        VALUES (i_usuario_id, i_versao_id, i_tipo_pagamento_id, i_data_inicio, i_data_termino, i_status)
        RETURNING "id_assinatura" INTO v_id;

        RETURN v_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION atualizar_assinatura(u_id_assinatura INT, u_usuario_id INT, u_versao_id INT, u_tipo_pagamento_id  INT, u_data_inicio DATE, u_data_termino DATE, u_status STATUS_ASSINATURA) RETURNS INT AS $$
    DECLARE
        d_old RECORD;
        v_new_inicio DATE;
        v_new_termino DATE;
    BEGIN
        SELECT * INTO d_old FROM "assinatura"
        WHERE "id_assinatura" = u_id_assinatura;
        IF NOT FOUND THEN
            RAISE NOTICE 'Assinatura ID % não encontrada.', u_id_assinatura;
            RETURN NULL;
        END IF;

        u_usuario_id := COALESCE(u_usuario_id, d_old.usuario_id);
        u_versao_id := COALESCE(u_versao_id, d_old.versao_id);
        u_tipo_pagamento_id := COALESCE(u_tipo_pagamento_id, d_old.tipo_pagamento_id);
        u_data_inicio := COALESCE(u_data_inicio, d_old.data_inicio);
        u_data_termino := COALESCE(u_data_termino, d_old.data_termino);
        u_status := COALESCE(u_status, d_old.status);

        IF NOT EXISTS (
            SELECT 1 FROM "usuario" WHERE "id_usuario" = u_usuario_id
        ) THEN
            RAISE NOTICE 'Usuário ID % não encontrado.', u_usuario_id;
            RETURN NULL;
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM "versao" WHERE "id_versao" = u_versao_id
        ) THEN
            RAISE NOTICE 'Versão ID % não encontrada.', u_versao_id;
            RETURN NULL;
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM "tipo_pagamento" WHERE "id_tipo_pagamento" = u_tipo_pagamento_id
        ) THEN
            RAISE NOTICE 'Tipo de pagamento ID % não encontrado.', u_tipo_pagamento_id;
            RETURN NULL;
        END IF;

        IF u_data_termino IS NOT NULL AND u_data_termino < u_data_inicio THEN
            RAISE NOTICE 'Data término não pode ser anterior à data início.';
            RETURN NULL;
        END IF;

        UPDATE "assinatura"
        SET "usuario_id" = u_usuario_id, "versao_id" = u_versao_id, "tipo_pagamento_id" = u_tipo_pagamento_id, "data_inicio" = u_data_inicio, "data_termino" = u_data_termino, "status" = u_status
        WHERE "id_assinatura" = u_id_assinatura;

        RETURN u_id_assinatura;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
CREATE OR REPLACE FUNCTION excluir_assinatura(d_id_assinatura INT, d_usuario_id INT) RETURNS TEXT AS $$
    DECLARE
        d_old RECORD;
    BEGIN
        SELECT * INTO d_old FROM "assinatura"
        WHERE "id_assinatura" = d_id_assinatura;
        IF NOT FOUND THEN
            RETURN format('Assinatura ID %s não encontrada.', d_id_assinatura);
        END IF;

        IF d_old.usuario_id <> d_usuario_id THEN
            RETURN format('Não confere: a assinatura %s não pertence ao usuário %s.', d_id_assinatura, d_usuario_id);
        END IF;

        IF EXISTS (
            SELECT 1 FROM "parcela"
            WHERE "assinatura_id" = d_id_assinatura
        ) THEN
            RETURN format('Não foi possível excluir: existem parcelas vinculadas à assinatura %s.', d_id_assinatura);
        END IF;

        DELETE FROM "assinatura"
        WHERE "id_assinatura" = d_id_assinatura;

        RETURN format('Assinatura %s do usuário %s excluída com sucesso.', d_id_assinatura, d_usuario_id);
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION listar_assinaturas() RETURNS TABLE (id INT, usuario VARCHAR, produto VARCHAR, versao VARCHAR, status STATUS_ASSINATURA, tipo_pagamento TIPOS_PAGAMENTOS, data_inicio DATE, data_termino DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT a.id_assinatura, u.nome_usuario, p.nome_produto, v.num_versao, a.status, tp.nome_tipo, a.data_inicio, a.data_termino FROM assinatura a
        JOIN usuario u ON u.id_usuario = a.usuario_id
        JOIN versao v ON v.id_versao = a.versao_id
        JOIN produto p ON p.id_produto = v.produto_id
        JOIN tipo_pagamento tp ON tp.id_tipo_pagamento = a.tipo_pagamento_id;
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION buscar_assinaturas_por_usuario(p_usuario_id INT)
RETURNS TABLE (id INT, nome_produto VARCHAR, versao VARCHAR, status STATUS_ASSINATURA, data_inicio DATE, data_termino DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT a.id_assinatura, p.nome_produto, v.num_versao, a.status, a.data_inicio, a.data_termino FROM assinatura a
        JOIN versao v ON v.id_versao = a.versao_id
        JOIN produto p ON p.id_produto = v.produto_id
        WHERE a.usuario_id = p_usuario_id;
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION listar_assinaturas_ativas() RETURNS TABLE (id INT, usuario VARCHAR, produto VARCHAR, versao VARCHAR, data_inicio DATE, data_termino DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT a.id_assinatura, u.nome_usuario, p.nome_produto, v.num_versao, a.data_inicio, a.data_termino FROM assinatura a
        JOIN usuario u ON u.id_usuario = a.usuario_id
        JOIN versao v ON v.id_versao = a.versao_id
        JOIN produto p ON p.id_produto = v.produto_id
        WHERE a.status = 'ativa';
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION contar_assinaturas_por_status() RETURNS TABLE (status public.STATUS_ASSINATURA, total bigint) AS $$
    BEGIN
        RETURN QUERY
        SELECT a.status, COUNT(*) FROM assinatura a
        GROUP BY a.status;
    END;
$$ LANGUAGE plpgsql;

-- listar por preço
-- Testada e validada
CREATE FUNCTION listar_assinaturas_por_preco() RETURNS TABLE (id_assinatura INTEGER, nome_usuario VARCHAR, nome_produto VARCHAR, num_versao VARCHAR, preco NUMERIC, status public.status_assinatura) AS $$
    BEGIN
        RETURN QUERY
        SELECT a.id_assinatura, u.nome_usuario, p.nome_produto, v.num_versao, p.preco, a.status FROM  assinatura a
        JOIN usuario u ON a.usuario_id = u.id_usuario
        JOIN versao v ON a.versao_id = v.id_versao
        JOIN produto p ON v.produto_id = p.id_produto
        ORDER BY p.preco ASC;
    END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE OR REPLACE FUNCTION impedir_assinatura_duplicada()
RETURNS TRIGGER AS $$
    BEGIN
        IF EXISTS (
            SELECT 1 FROM assinatura
            WHERE usuario_id = NEW.usuario_id AND versao_id = NEW.versao_id
        ) THEN
            RAISE EXCEPTION 'Usuário já possui assinatura para esta versão.';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_impedir_assinatura_duplicada
BEFORE INSERT ON assinatura
FOR EACH ROW
EXECUTE FUNCTION impedir_assinatura_duplicada();

CREATE OR REPLACE FUNCTION atualizar_status_assinatura()
RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.data_termino IS NOT NULL AND NEW.data_termino < CURRENT_DATE THEN
            NEW.status := 'expirada';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_status_assinatura
BEFORE INSERT OR UPDATE ON assinatura
FOR EACH ROW
EXECUTE FUNCTION atualizar_status_assinatura();
