-- Funções

-- Inserção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION cadastrar_software(i_produto_id INT, i_tipo_licenca VARCHAR) RETURNS INT AS $$
    DECLARE
        i_id INT;
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM "produto"
            WHERE "id_produto" = i_produto_id
            AND "tipo" = 'software'
        ) THEN
            RAISE NOTICE 'Produto ID % não encontrado ou não é do tipo software.', i_produto_id;
            RETURN NULL;
        END IF;

        IF EXISTS (
            SELECT 1 FROM "software"
            WHERE "produto_id" = i_produto_id
        ) THEN
            RAISE NOTICE 'Já existe registro em software para o produto %.', i_produto_id;
            RETURN NULL;
        END IF;

        INSERT INTO "software"("produto_id", "tipo_licenca")
        VALUES (i_produto_id, i_tipo_licenca)
        RETURNING "produto_id" INTO i_id;

        RETURN i_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
CREATE OR REPLACE FUNCTION atualizar_software(u_produto_id INT, u_tipo_licenca VARCHAR) RETURNS INT AS $$
    DECLARE
        u_old RECORD;
    BEGIN
        SELECT * INTO u_old FROM "software"
        WHERE "produto_id" = u_produto_id;
        IF NOT FOUND THEN
            RAISE NOTICE 'Nenhum registro em software para o produto % encontrado.', u_produto_id;
            RETURN NULL;
        END IF;

        IF u_tipo_licenca IS NULL OR trim(u_tipo_licenca) = '' THEN
            RAISE NOTICE 'Campo "tipo_licenca" é obrigatório.';
            RETURN NULL;
        END IF;

        UPDATE "software"
        SET "tipo_licenca" = u_tipo_licenca
        WHERE "produto_id" = u_produto_id;

        RETURN u_produto_id;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
CREATE OR REPLACE FUNCTION excluir_software(d_produto_id INT, d_tipo_licenca VARCHAR) RETURNS TEXT AS $$
    DECLARE
        d_old RECORD;
    BEGIN
        SELECT * INTO d_old FROM "software"
        WHERE "produto_id" = d_produto_id;
        IF NOT FOUND THEN
            RETURN format('Nenhum registro em software para o produto %s encontrado.', d_produto_id);
        END IF;

        IF d_tipo_licenca IS NULL OR d_old.tipo_licenca <> d_tipo_licenca THEN
            RETURN format('Licença informada ("%s") não confere com o cadastro ("%s").', d_tipo_licenca, d_old.tipo_licenca);
        END IF;

        DELETE FROM "software"
        WHERE "produto_id" = d_produto_id;

        RETURN format('Registro software do produto %s excluído (licença="%s").', d_produto_id, d_tipo_licenca);
    END;
$$ LANGUAGE plpgsql;

-- Listar softwares
CREATE OR REPLACE FUNCTION listar_softwares() RETURNS TABLE (id INT, nome VARCHAR, descricao TEXT, preco NUMERIC, status STATUS_PRODUTOS, tipo_licenca VARCHAR, data_publicacao DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, p.descricao, p.preco, p.status, s.tipo_licenca, p.data_publicacao FROM produto p
        JOIN software s ON s.produto_id = p.id_produto;
    END;
$$ LANGUAGE plpgsql;

-- buscar por nome
CREATE OR REPLACE FUNCTION buscar_softwares_por_nome(p_nome TEXT) RETURNS TABLE (id INT, nome VARCHAR, tipo_licenca VARCHAR, status STATUS_PRODUTOS) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, s.tipo_licenca, p.status FROM produto p
        JOIN software s ON s.produto_id = p.id_produto
        WHERE p.nome_produto ILIKE '%' || p_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Listar por licença
CREATE OR REPLACE FUNCTION listar_softwares_por_licenca(p_licenca TEXT) RETURNS TABLE (id INT, nome VARCHAR, descricao TEXT, preco NUMERIC, status STATUS_PRODUTOS) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, p.descricao, p.preco, p.status FROM produto p
        JOIN software s ON s.produto_id = p.id_produto
        WHERE s.tipo_licenca ILIKE '%' || p_licenca || '%';
    END;
$$ LANGUAGE plpgsql;

-- listar ativos
CREATE OR REPLACE FUNCTION listar_softwares_ativos() RETURNS TABLE (id INT, nome VARCHAR, tipo_licenca VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, s.tipo_licenca FROM produto p
        JOIN software s ON s.produto_id = p.id_produto
        WHERE p.status = 'ativo';
    END;
$$ LANGUAGE plpgsql;

-- Triggers

-- validar
CREATE OR REPLACE FUNCTION verificar_tipo_produto_software() RETURNS TRIGGER AS $$
    DECLARE
        tipo_prod TIPOS_PRODUTOS;
    BEGIN
        SELECT tipo INTO tipo_prod FROM produto
        WHERE id_produto = NEW.produto_id;

        IF tipo_prod IS DISTINCT FROM 'software' THEN
            RAISE EXCEPTION 'O produto associado não é do tipo SOFTWARE.';
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_tipo_software
BEFORE INSERT OR UPDATE ON software
FOR EACH ROW
EXECUTE FUNCTION verificar_tipo_produto_software();
