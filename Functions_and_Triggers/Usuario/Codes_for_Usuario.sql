-- Funções

-- Inserção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION cadastrar_usuario(i_nome_usuario VARCHAR, i_email VARCHAR, i_senha VARCHAR, i_tipo_usuario TIPOS_USUARIOS DEFAULT 'cliente') RETURNS INT AS $$
    DECLARE
        v_id INT;
    BEGIN
        IF EXISTS (
            SELECT 1 FROM "usuario"
            WHERE LOWER("email") = LOWER(i_email)
        ) THEN
            RAISE NOTICE 'Já existe usuário com o e-mail "%".', i_email;
            RETURN NULL;
        END IF;

        INSERT INTO "usuario"("nome_usuario", "email", "senha", "tipo_usuario", "data_registro")
        VALUES (i_nome_usuario, i_email, i_senha, i_tipo_usuario, CURRENT_DATE)
        RETURNING "id_usuario" INTO v_id;

        RETURN v_id;
    END;
$$ LANGUAGE plpgsql;

-- Atualização automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION atualizar_usuario(u_id_usuario INT, u_nome_usuario VARCHAR, u_email VARCHAR, u_senha VARCHAR, u_tipo_usuario TIPOS_USUARIOS) RETURNS INT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "usuario"
        WHERE "id_usuario" = u_id_usuario;
        IF NOT FOUND THEN
            RAISE NOTICE 'Nenhum usuário encontrado com ID %.', u_id_usuario;
            RETURN NULL;
        END IF;

        IF u_email IS NOT NULL AND EXISTS (
            SELECT 1 FROM "usuario"
            WHERE LOWER("email") = LOWER(u_email)
            AND "id_usuario" <> u_id_usuario
        ) THEN
            RAISE NOTICE 'E-mail "%" já está em uso por outro usuário.', u_email;
            RETURN NULL;
        END IF;

        UPDATE "usuario"
        SET "nome_usuario" = COALESCE(u_nome_usuario, v_old.nome_usuario), "email" = COALESCE(u_email, v_old.email), "senha" = COALESCE(u_senha, v_old.senha), "tipo_usuario" = COALESCE(u_tipo_usuario, v_old.tipo_usuario)
        WHERE "id_usuario" = u_id_usuario;

        RETURN u_id_usuario;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION excluir_usuario(d_id_usuario INT, d_nome_usuario VARCHAR) RETURNS TEXT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "usuario"
        WHERE "id_usuario" = d_id_usuario;
        IF NOT FOUND THEN
            RETURN format('Nenhum usuário com ID %s encontrado.', d_id_usuario);
        END IF;

        IF d_nome_usuario IS NULL OR LOWER(v_old.nome_usuario) <> LOWER(d_nome_usuario) THEN
            RETURN format('O nome informado ("%s") não confere com o cadastro ("%s").', d_nome_usuario, v_old.nome_usuario);
        END IF;

        IF EXISTS (
            SELECT 1 FROM "suporte" WHERE "usuario_id" = d_id_usuario
        ) OR EXISTS (
            SELECT 1 FROM "avaliacao" WHERE "usuario_id" = d_id_usuario
        ) OR EXISTS (
            SELECT 1 FROM "assinatura" WHERE "usuario_id" = d_id_usuario
        ) THEN
            RETURN format('Não é possível excluir: usuário "%s" possui dados vinculados.', v_old.nome_usuario);
        END IF;

        DELETE FROM "usuario"
        WHERE "id_usuario" = d_id_usuario;

        RETURN format('Usuário "%s" (ID %s) excluído com sucesso.', v_old.nome_usuario, d_id_usuario);
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION listar_usuarios() RETURNS TABLE (id INT, nome VARCHAR, mail VARCHAR, tipo TIPOS_USUARIOS, dt_registro DATE) AS $$
    BEGIN
        RETURN QUERY
        SELECT id_usuario, nome_usuario, email, tipo_usuario, data_registro FROM usuario;
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION buscar_usuario_por_nome(p_nome VARCHAR) RETURNS TABLE (id INT, nome VARCHAR, mail VARCHAR, tipo TIPOS_USUARIOS) AS $$
    BEGIN
        RETURN QUERY
        SELECT id_usuario, nome_usuario, email, tipo_usuario FROM usuario
        WHERE nome_usuario ILIKE '%' || p_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- Testada e validada
CREATE OR REPLACE FUNCTION contar_usuarios_por_tipo() RETURNS TABLE(tipo public.tipos_usuarios, total bigint) AS $$
    BEGIN
        RETURN QUERY
        SELECT tipo_usuario, COUNT(*) as total FROM usuario
        GROUP BY tipo_usuario
        ORDER BY total DESC;
    END;
$$ LANGUAGE plpgsql;

-- Triggers

-- função para normalizar emails
CREATE OR REPLACE FUNCTION trigger_normalizar_email()
RETURNS TRIGGER AS $$
BEGIN
    NEW.email := LOWER(TRIM(NEW.email));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalizar_email
BEFORE INSERT OR UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION trigger_normalizar_email();

-- trigger para evitar senhas muito fracas
CREATE OR REPLACE FUNCTION trigger_verificar_senha_fraca()
RETURNS TRIGGER AS $$
BEGIN
    IF LENGTH(NEW.senha) < 8 THEN
        RAISE EXCEPTION 'Senha muito curta. Mínimo de 8 caracteres.';
    END IF;

    IF NEW.senha ~* '^(.)\1+$' THEN
        RAISE EXCEPTION 'Senha muito fraca. Não repita o mesmo caractere.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
