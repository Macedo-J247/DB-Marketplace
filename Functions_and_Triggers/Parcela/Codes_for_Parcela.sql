-- Funções

-- Inserção automatizada
CREATE OR REPLACE FUNCTION cadastrar_parcela(i_assinatura_id INT, i_valor DECIMAL(10,2), i_data_vencimento DATE, i_data_pagamento DATE DEFAULT NULL, i_status STATUS_PARCELA) RETURNS INT AS $$
    DECLARE
        v_id INT;
    BEGIN
        IF i_valor IS NULL OR i_valor < 0 THEN
            RAISE NOTICE 'Campo "valor" deve ser >= 0.';
            RETURN NULL;
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM "assinatura" WHERE "id_assinatura" = i_assinatura_id
        ) THEN
            RAISE NOTICE 'Assinatura ID % não encontrada.', i_assinatura_id;
            RETURN NULL;
        END IF;

        IF EXISTS (
            SELECT 1 FROM "parcela"
            WHERE "assinatura_id"   = i_assinatura_id
            AND "data_vencimento" = i_data_vencimento
        ) THEN
            RAISE NOTICE 'Já existe parcela para assinatura % com vencimento em %.', i_assinatura_id, i_data_vencimento;
            RETURN NULL;
        END IF;

        INSERT INTO "parcela"("assinatura_id", "valor", "data_vencimento", "data_pagamento", "status")
        VALUES (i_assinatura_id, i_valor, i_data_vencimento, i_data_pagamento, i_status)
        RETURNING "id_parcela" INTO v_id;

        RETURN v_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
CREATE OR REPLACE FUNCTION atualizar_parcela(u_id_parcela INT, u_assinatura_id INT DEFAULT NULL, u_valor DECIMAL(10,2) DEFAULT NULL, u_data_vencimento DATE DEFAULT NULL, u_data_pagamento DATE DEFAULT NULL, u_status STATUS_PARCELA DEFAULT NULL) RETURNS INT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "parcela"
        WHERE "id_parcela" = u_id_parcela;
        IF NOT FOUND THEN
            RAISE NOTICE 'Parcela ID % não encontrada.', u_id_parcela;
            RETURN NULL;
        END IF;

        u_assinatura_id := COALESCE(u_assinatura_id, v_old.assinatura_id);
        u_valor := COALESCE(u_valor, v_old.valor);
        u_data_vencimento := COALESCE(u_data_vencimento, v_old.data_vencimento);
        u_data_pagamento := COALESCE(u_data_pagamento, v_old.data_pagamento);
        u_status := COALESCE(u_status, v_old.status);

        IF NOT EXISTS (
            SELECT 1 FROM "assinatura" WHERE "id_assinatura" = u_assinatura_id
        ) THEN
            RAISE NOTICE 'Assinatura ID % não encontrada.', u_assinatura_id;
            RETURN NULL;
        END IF;

        IF u_valor < 0 THEN
            RAISE NOTICE 'Campo "valor" deve ser >= 0.';
            RETURN NULL;
        END IF;
        
        IF EXISTS (
            SELECT 1 FROM "parcela"
            WHERE "assinatura_id" = u_assinatura_id AND "data_vencimento" = u_data_vencimento AND "id_parcela" <> u_id_parcela
        ) THEN
            RAISE NOTICE 'Já existe outra parcela para assinatura % com vencimento em %.', u_assinatura_id, u_data_vencimento;
            RETURN NULL;
        END IF;

        UPDATE "parcela"
        SET "assinatura_id" = u_assinatura_id, "valor" = u_valor, "data_vencimento" = u_data_vencimento, "data_pagamento" = u_data_pagamento, "status" = u_status
        WHERE "id_parcela" = u_id_parcela;

        RETURN u_id_parcela;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
CREATE OR REPLACE FUNCTION excluir_parcela(d_id_parcela INT, d_data_vencimento DATE) RETURNS TEXT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "parcela"
        WHERE "id_parcela" = d_id_parcela;
        IF NOT FOUND THEN
            RETURN format('Parcela ID %s não encontrada.', d_id_parcela);
        END IF;

        IF d_data_vencimento IS NULL OR v_old.data_vencimento <> d_data_vencimento THEN
            RETURN format('Data de vencimento informada (%s) não confere com o cadastro (%s).', d_data_vencimento, v_old.data_vencimento);
        END IF;

        IF v_old.data_pagamento IS NOT NULL OR v_old.status = 'pago' THEN
            RETURN format('Não foi possível excluir: parcela %s já está marcada como paga.', d_id_parcela);
        END IF;

        DELETE FROM "parcela"
        WHERE "id_parcela" = d_id_parcela;

        RETURN format('Parcela %s com vencimento em %s excluída com sucesso.', d_id_parcela, d_data_vencimento);
    END;
$$ LANGUAGE plpgsql;

-- Listar as parcelas cadastradas
CREATE OR REPLACE FUNCTION listar_parcelas() RETURNS TABLE (id INT, valor NUMERIC, vencimento DATE, pagamento DATE, status STATUS_PARCELA, nome_usuario VARCHAR, nome_produto VARCHAR, num_versao VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_parcela, p.valor, p.data_vencimento, p.data_pagamento, p.status, u.nome_usuario, pr.nome_produto, v.num_versao FROM parcela p
        JOIN assinatura a ON a.id_assinatura = p.assinatura_id
        JOIN usuario u ON u.id_usuario = a.usuario_id
        JOIN versao v ON v.id_versao = a.versao_id
        JOIN produto pr ON pr.id_produto = v.produto_id;
    END;
$$ LANGUAGE plpgsql;

-- Listar as parcelas por status
CREATE OR REPLACE FUNCTION listar_parcelas_por_status(p_status STATUS_PARCELA) RETURNS TABLE (id INT, valor NUMERIC, vencimento DATE, status STATUS_PARCELA, usuario VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_parcela, p.valor, p.data_vencimento, p.status, u.nome_usuario FROM parcela p
        JOIN assinatura a ON a.id_assinatura = p.assinatura_id
        JOIN usuario u ON u.id_usuario = a.usuario_id
        WHERE p.status = p_status;
    END;
$$ LANGUAGE plpgsql;

-- Listar as parcelas com status "em atraso"
CREATE OR REPLACE FUNCTION listar_parcelas_em_atraso() RETURNS TABLE (id INT, valor NUMERIC, vencimento DATE, status STATUS_PARCELA, usuario VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_parcela, p.valor, p.data_vencimento, p.status, u.nome_usuario FROM parcela p
        JOIN assinatura a ON a.id_assinatura = p.assinatura_id
        JOIN usuario u ON u.id_usuario = a.usuario_id
        WHERE p.status = 'pendendte' AND p.data_vencimento < CURRENT_DATE;
    END;
$$ LANGUAGE plpgsql;

-- Exibir o total pago por nome de usuário
CREATE OR REPLACE FUNCTION total_pago_por_usuario(p_usuario_id INT) RETURNS NUMERIC AS $$
    DECLARE
        total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(p.valor), 0) INTO total FROM parcela p
        JOIN assinatura a ON a.id_assinatura = p.assinatura_id
        WHERE a.usuario_id = p_usuario_id AND p.status = 'pago';

        RETURN total;
    END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE OR REPLACE FUNCTION atualizar_status_atrasado() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.status = 'pendendte' AND NEW.data_vencimento < CURRENT_DATE THEN
            NEW.status := 'atrasado';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_status_atraso
BEFORE INSERT OR UPDATE ON parcela
FOR EACH ROW
EXECUTE FUNCTION atualizar_status_atrasado();

CREATE OR REPLACE FUNCTION validar_valor_parcela() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.valor <= 0 THEN
            RAISE EXCEPTION 'O valor da parcela deve ser maior que zero.';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_valor_parcela
BEFORE INSERT OR UPDATE ON parcela
FOR EACH ROW
EXECUTE FUNCTION validar_valor_parcela();
