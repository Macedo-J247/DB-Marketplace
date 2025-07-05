-- Funções

-- Inserção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION cadastrar_produto(i_desenvolvedor_id INT, i_categoria_id INT, i_nome_produto VARCHAR, i_descricao TEXT, i_preco DECIMAL(10,2), i_tipo TIPOS_PRODUTOS, i_status STATUS_PRODUTOS, i_data_publicacao DATE) RETURNS INT AS $$
    DECLARE
        v_id INT;
    BEGIN
        IF i_preco IS NULL OR i_preco < 0 THEN
            RAISE NOTICE 'Campo "preco" deve ser >= 0.';
            RETURN NULL;
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM "desenvolvedor" WHERE "id_desenvolvedor" = i_desenvolvedor_id
        ) THEN
            RAISE NOTICE 'Desenvolvedor ID % não encontrado.', i_desenvolvedor_id;
            RETURN NULL;
        END IF;
        
        IF NOT EXISTS (
            SELECT 1 FROM "categoria" WHERE "id_categoria" = i_categoria_id
        ) THEN
            RAISE NOTICE 'Categoria ID % não encontrado.', i_categoria_id;
            RETURN NULL;
        END IF;

        INSERT INTO "produto"("desenvolvedor_id", "categoria_id", "nome_produto", "descricao", "preco", "tipo", "status", "data_publicacao")
        VALUES (i_desenvolvedor_id, i_categoria_id, i_nome_produto, i_descricao, i_preco, i_tipo, i_status, i_data_publicacao)
        RETURNING "id_produto" INTO v_id;

        RETURN v_id;
    END;
$$ LANGUAGE plpgsql;

--  Atualização automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION atualizar_produto(u_id_produto INT, u_desenvolvedor_id INT, u_categoria_id INT, u_nome_produto VARCHAR, u_descricao TEXT, u_preco DECIMAL(10,2) , u_tipo TIPOS_PRODUTOS, u_status STATUS_PRODUTOS, u_data_publicacao DATE, u_data_atualizacao DATE) RETURNS INT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "produto"
        WHERE "id_produto" = u_id_produto;
        IF NOT FOUND THEN
            RAISE NOTICE 'Produto ID % não encontrado.', u_id_produto;
            RETURN NULL;
        END IF;

        IF u_desenvolvedor_id IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM "desenvolvedor" WHERE "id_desenvolvedor" = u_desenvolvedor_id
        ) THEN
            RAISE NOTICE 'Desenvolvedor ID % não encontrado.', u_desenvolvedor_id;
            RETURN NULL;
        END IF;
        
        IF u_categoria_id IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM "categoria" WHERE "id_categoria" = u_categoria_id
        ) THEN
            RAISE NOTICE 'Categoria ID % não encontrado.', u_categoria_id;
            RETURN NULL;
        END IF;

        IF u_preco IS NOT NULL AND u_preco < 0 THEN
            RAISE NOTICE 'Campo "preco" deve ser >= 0.';
            RETURN NULL;
        END IF;

        u_desenvolvedor_id := COALESCE(u_desenvolvedor_id, v_old.desenvolvedor_id);
        u_categoria_id := COALESCE(u_categoria_id, v_old.categoria_id);
        u_nome_produto := COALESCE(u_nome_produto, v_old.nome_produto);
        u_descricao := COALESCE(u_descricao, v_old.descricao);
        u_preco := COALESCE(u_preco, v_old.preco);
        u_tipo := COALESCE(u_tipo, v_old.tipo);
        u_status := COALESCE(u_status, v_old.status);
        u_data_publicacao := COALESCE(u_data_publicacao, v_old.data_publicacao);
        u_data_atualizacao := COALESCE(u_data_atualizacao, CURRENT_DATE);

        UPDATE "produto"
        SET "desenvolvedor_id" = u_desenvolvedor_id, "categoria_id" = u_categoria_id, "nome_produto" = u_nome_produto, "descricao" = u_descricao, "preco" = u_preco, "tipo" = u_tipo, "status" = u_status, "data_publicacao"  = u_data_publicacao, "data_atualizacao" = u_data_atualizacao
        WHERE "id_produto" = u_id_produto;

        RETURN u_id_produto;
    END;
$$ LANGUAGE plpgsql;

-- Remoção automatizada
-- Testada e validada
CREATE OR REPLACE FUNCTION excluir_produto(d_id_produto INT, d_nome_produto VARCHAR) RETURNS TEXT AS $$
    DECLARE
        v_old RECORD;
    BEGIN
        SELECT * INTO v_old FROM "produto"
        WHERE "id_produto" = d_id_produto;
        IF NOT FOUND THEN
            RETURN format('Produto ID %s não encontrado.', d_id_produto);
        END IF;

        IF d_nome_produto IS NULL OR LOWER(v_old.nome_produto) <> LOWER(d_nome_produto) THEN
            RETURN format('Nome informado ("%s") não confere com "%s".', d_nome_produto, v_old.nome_produto);
        END IF;

        IF EXISTS (
            SELECT 1 FROM "versao" WHERE "produto_id" = d_id_produto
        ) OR EXISTS (
            SELECT 1 FROM "suporte" WHERE "produto_id" = d_id_produto
        ) OR EXISTS (
            SELECT 1 FROM "assinatura" WHERE "versao_id" IN (
                SELECT "id_versao" FROM "versao" WHERE "produto_id" = d_id_produto
            )
        ) THEN
            RETURN format('Não foi possível excluir: existem registros vinculados ao produto "%s".', v_old.nome_produto);
        END IF;

        DELETE FROM "produto"
        WHERE "id_produto" = d_id_produto;

        RETURN format('Produto "%s" (ID %s) excluído com sucesso.', v_old.nome_produto, d_id_produto);
    END;
$$ LANGUAGE plpgsql;

-- listar devs e produtos
CREATE OR REPLACE FUNCTION listar_produtos()
RETURNS TABLE (id INT, nome VARCHAR, descricao TEXT, preco NUMERIC, tipo TIPOS_PRODUTOS, status STATUS_PRODUTOS, data_publicacao DATE, data_atualizacao DATE, nome_desenvolvedor VARCHAR, nome_categoria VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.id_produto, p.nome_produto, p.descricao, p.preco, p.tipo, p.status, p.data_publicacao, p.data_atualizacao, d.nome_dev, c.nome_categoria FROM produto p
        JOIN desenvolvedor d ON d.id_desenvolvedor = p.desenvolvedor_id
        JOIN categoria c ON c.id_categoria = p.categoria_id;
    END;
$$ LANGUAGE plpgsql;

-- busca por nome
CREATE OR REPLACE FUNCTION buscar_produtos_por_nome(p_nome TEXT) RETURNS TABLE (id INT, nome VARCHAR, tipo TIPOS_PRODUTOS, status STATUS_PRODUTOS, preco NUMERIC) AS $$
    BEGIN
        RETURN QUERY
        SELECT id_produto, nome_produto, tipo, status, preco FROM produto
        WHERE nome_produto ILIKE '%' || p_nome || '%';
    END;
$$ LANGUAGE plpgsql;

-- listar por status da categoria
CREATE OR REPLACE FUNCTION listar_produtos_por_categoria_status(p_categoria_id INT DEFAULT NULL, p_status STATUS_PRODUTOS DEFAULT NULL) RETURNS TABLE (id INT, nome VARCHAR, status STATUS_PRODUTOS, tipo TIPOS_PRODUTOS, categoria_id INT) AS $$
    BEGIN
        RETURN QUERY
        SELECT id_produto, nome_produto, status, tipo, categoria_id FROM produto
        WHERE (p_categoria_id IS NULL OR categoria_id = p_categoria_id) AND (p_status IS NULL OR status = p_status);
    END;
$$ LANGUAGE plpgsql;

-- contar
CREATE OR REPLACE FUNCTION contar_produtos_por_tipo() RETURNS TABLE (tipo TIPOS_PRODUTOS, quantidade INT) AS $$
    BEGIN
        RETURN QUERY
        SELECT tipo, COUNT(*) AS quantidade FROM produto
        GROUP BY tipo;
    END;
$$ LANGUAGE plpgsql;


-- Triggers

-- atualizar data
CREATE OR REPLACE FUNCTION atualizar_data_modificacao() RETURNS TRIGGER AS $$
    BEGIN
        NEW.data_atualizacao := CURRENT_DATE;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_data_modificacao
BEFORE UPDATE ON produto
FOR EACH ROW
EXECUTE FUNCTION atualizar_data_modificacao();

-- impedir ativação de produto sem versão
CREATE OR REPLACE FUNCTION verificar_versao_antes_ativar() RETURNS TRIGGER AS $$
    DECLARE
        versao_existe BOOLEAN;
    BEGIN
        IF NEW.status = 'ativo' AND OLD.status IS DISTINCT FROM 'ativo' THEN
            SELECT EXISTS (
                SELECT 1 FROM versao WHERE produto_id = NEW.id_produto
            ) INTO versao_existe;

            IF NOT versao_existe THEN
                RAISE EXCEPTION 'Produto não pode ser ativado sem ao menos uma versão publicada.';
            END IF;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_versao_antes_ativar
BEFORE UPDATE ON produto
FOR EACH ROW
EXECUTE FUNCTION verificar_versao_antes_ativar();

-- Função: validar_nome_produto_unico
-- Objetivo: Garante que o nome do produto seja único, ignorando maiúsculas/minúsculas.
CREATE OR REPLACE FUNCTION validar_nome_produto_unico() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM produto
        WHERE LOWER(nome_produto) = LOWER(NEW.nome_produto)
        AND id_produto IS DISTINCT FROM COALESCE(OLD.id_produto, 0) -- Permite update do próprio registro
    ) THEN
        RAISE EXCEPTION 'Já existe um produto com o nome "%". Nomes de produtos devem ser únicos (ignorando maiúsculas/minúsculas).', NEW.nome_produto;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função: validar_data_publicacao_produto
-- Objetivo: Garante que a data de publicação de um produto não seja futura.
CREATE OR REPLACE FUNCTION validar_data_publicacao_produto() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.data_publicacao > CURRENT_DATE THEN
        RAISE EXCEPTION 'A data de publicação do produto ("%") não pode ser futura.', NEW.data_publicacao;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função: impedir_exclusao_produto_com_dependencias
-- Objetivo: Impede a exclusão de um produto se ele tiver versões, suportes ou assinaturas vinculadas.
--           Esta função complementa as FKs (ON DELETE RESTRICT) e oferece uma mensagem mais específica.
CREATE OR REPLACE FUNCTION impedir_exclusao_produto_com_dependencias() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM versao WHERE produto_id = OLD.id_produto) THEN
        RAISE EXCEPTION 'Não é possível excluir o produto "%" (ID: %) porque existem versões vinculadas a ele.', OLD.nome_produto, OLD.id_produto;
    END IF;
    IF EXISTS (SELECT 1 FROM suporte WHERE produto_id = OLD.id_produto) THEN
        RAISE EXCEPTION 'Não é possível excluir o produto "%" (ID: %) porque existem solicitações de suporte vinculadas a ele.', OLD.nome_produto, OLD.id_produto;
    END IF;
    -- A verificação de assinatura via versao_id já está na função excluir_produto,
    -- mas se a FK não for RESTRICT, um trigger aqui seria vital.
    -- Assumindo que as FKs já estão com ON DELETE RESTRICT, este trigger é mais para uma mensagem customizada.
    RETURN OLD; -- Permite a operação se não houver dependências ativas
END;
$$ LANGUAGE plpgsql;


-- Trigger: trg_verificar_versao_antes_ativar (já existia no seu código)
-- Objetivo: Chama a função verificar_versao_antes_ativar para impedir a ativação de produtos sem versão.
-- Disparo: Antes de ATUALIZAR registros na tabela 'produto'.
CREATE TRIGGER trg_verificar_versao_antes_ativar
BEFORE UPDATE ON produto
FOR EACH ROW
EXECUTE FUNCTION verificar_versao_antes_ativar();

-- NOVO Trigger: trg_validar_preco_produto
-- Objetivo: Chama a função validar_preco_produto para garantir que o preço seja válido.
-- Disparo: Antes de INSERIR ou ATUALIZAR registros na tabela 'produto'.
CREATE TRIGGER trg_validar_preco_produto
BEFORE INSERT OR UPDATE ON produto
FOR EACH ROW
EXECUTE FUNCTION validar_preco_produto();

-- NOVO Trigger: trg_validar_nome_produto_unico
-- Objetivo: Chama a função validar_nome_produto_unico para garantir que o nome do produto seja único.
-- Disparo: Antes de INSERIR ou ATUALIZAR registros na tabela 'produto'.
CREATE TRIGGER trg_validar_nome_produto_unico
BEFORE INSERT OR UPDATE ON produto
FOR EACH ROW
EXECUTE FUNCTION validar_nome_produto_unico();

-- NOVO Trigger: trg_validar_data_publicacao_produto
-- Objetivo: Chama a função validar_data_publicacao_produto para garantir que a data de publicação não seja futura.
-- Disparo: Antes de INSERIR ou ATUALIZAR registros na tabela 'produto'.
CREATE TRIGGER trg_validar_data_publicacao_produto
BEFORE INSERT OR UPDATE ON produto
FOR EACH ROW
EXECUTE FUNCTION validar_data_publicacao_produto();

-- NOVO Trigger: trg_impedir_exclusao_produto_com_dependencias
-- Objetivo: Chama a função impedir_exclusao_produto_com_dependencias para evitar a exclusão de produtos com dependências.
-- Disparo: Antes de DELETAR registros na tabela 'produto'.
CREATE TRIGGER trg_impedir_exclusao_produto_com_dependencias
BEFORE DELETE ON produto
FOR EACH ROW
EXECUTE FUNCTION impedir_exclusao_produto_com_dependencias();
