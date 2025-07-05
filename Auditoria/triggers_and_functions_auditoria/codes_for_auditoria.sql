-- Triggers
-- Testados e validados

-- Trigger para preenchimento da tabela de auditoria referente à tabela assinatura
CREATE OR REPLACE FUNCTION log_auditoria_assinatura() RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO auditoria_assinatura(id_assinatura, acao, usuario_id, versao_id, tipo_pagamento_id, data_inicio, data_termino, status)
            VALUES (NEW.id_assinatura, 'INSERT', NEW.usuario_id, NEW.versao_id, NEW.tipo_pagamento_id, NEW.data_inicio, NEW.data_termino, NEW.status);

            RETURN NEW;
        
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO auditoria_assinatura(id_assinatura, acao, usuario_id, versao_id, tipo_pagamento_id, data_inicio, data_termino, status)
            VALUES (NEW.id_assinatura, 'UPDATE', NEW.usuario_id, NEW.versao_id, NEW.tipo_pagamento_id, NEW.data_inicio, NEW.data_termino, NEW.status);

            RETURN NEW;

        ELSIF (TG_OP = 'DELETE') THEN
            INSERT INTO auditoria_assinatura(id_assinatura, acao, usuario_id, versao_id, tipo_pagamento_id, data_inicio, data_termino, status)
            VALUES (OLD.id_assinatura, 'DELETE', OLD.usuario_id, OLD.versao_id, OLD.tipo_pagamento_id, OLD.data_inicio, OLD.data_termino, OLD.status);

            RETURN OLD;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_assinatura
AFTER INSERT OR UPDATE OR DELETE ON assinatura
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_assinatura();

-- Trigger para preenchimento da tabela de auditoria referente à tabela assinatura
CREATE OR REPLACE FUNCTION log_auditoria_usuario() RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO auditoria_usuario(id_usuario, acao, nome_usuario, email, tipo_usuario, data_registro)
            VALUES (NEW.id_usuario, 'INSERT', NEW.nome_usuario, NEW.email, NEW.tipo_usuario, NEW.data_registro);
            RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO auditoria_usuario(id_usuario, acao, nome_usuario, email, tipo_usuario, data_registro)
            VALUES (NEW.id_usuario, 'UPDATE', NEW.nome_usuario, NEW.email, NEW.tipo_usuario, NEW.data_registro);
            RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
            INSERT INTO auditoria_usuario(id_usuario, acao, nome_usuario, email, tipo_usuario, data_registro)
            VALUES (OLD.id_usuario, 'DELETE', OLD.nome_usuario, OLD.email, OLD.tipo_usuario, OLD.data_registro);
            RETURN OLD;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_usuario
AFTER INSERT OR UPDATE OR DELETE ON usuario
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_usuario();

-- Trigger para preenchimento da tabela de auditoria referente à tabela desenvolvimento
CREATE OR REPLACE FUNCTION log_auditoria_desenvolvedor() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_desenvolvedor(id_desenvolvedor, acao, nome_dev, email_dev, data_cadastro)
        VALUES (NEW.id_desenvolvedor, 'INSERT', NEW.nome_dev, NEW.email_dev, NEW.data_cadastro);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_desenvolvedor(id_desenvolvedor, acao, nome_dev, email_dev, data_cadastro)
        VALUES (NEW.id_desenvolvedor, 'UPDATE', NEW.nome_dev, NEW.email_dev, NEW.data_cadastro);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_desenvolvedor(id_desenvolvedor, acao, nome_dev, email_dev, data_cadastro)
        VALUES (OLD.id_desenvolvedor, 'DELETE', OLD.nome_dev, OLD.email_dev, OLD.data_cadastro);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_desenvolvedor
AFTER INSERT OR UPDATE OR DELETE ON desenvolvedor
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_desenvolvedor();

-- Trigger para preenchimento da tabela de auditoria referente à tabela produto
CREATE OR REPLACE FUNCTION log_auditoria_produto() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_produto(id_produto, acao, desenvolvedor_id, categoria_id, nome_produto, descricao, preco, tipo, status, data_publicacao, data_atualizacao)
        VALUES (NEW.id_produto, 'INSERT', NEW.desenvolvedor_id, NEW.categoria_id, NEW.nome_produto, NEW.descricao, NEW.preco, NEW.tipo, NEW.status, NEW.data_publicacao, NEW.data_atualizacao);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_produto(id_produto, acao, desenvolvedor_id, categoria_id, nome_produto, descricao, preco, tipo, status, data_publicacao, data_atualizacao)
        VALUES (NEW.id_produto, 'UPDATE', NEW.desenvolvedor_id, NEW.categoria_id, NEW.nome_produto, NEW.descricao, NEW.preco, NEW.tipo, NEW.status, NEW.data_publicacao, NEW.data_atualizacao);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_produto(id_produto, acao, desenvolvedor_id, categoria_id, nome_produto, descricao, preco, tipo, status, data_publicacao, data_atualizacao)
        VALUES (OLD.id_produto, 'DELETE', OLD.desenvolvedor_id, OLD.categoria_id, OLD.nome_produto, OLD.descricao, OLD.preco, OLD.tipo, OLD.status, OLD.data_publicacao, OLD.data_atualizacao);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_produto
AFTER INSERT OR UPDATE OR DELETE ON produto
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_produto();

-- Trigger para preenchimento da tabela de auditoria referente à tabela versão
CREATE OR REPLACE FUNCTION log_auditoria_versao() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_versao(id_versao, acao, produto_id, num_versao, data_lancamento)
        VALUES (NEW.id_versao, 'INSERT', NEW.produto_id, NEW.num_versao, NEW.data_lancamento);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_versao(id_versao, acao, produto_id, num_versao, data_lancamento)
        VALUES (NEW.id_versao, 'UPDATE', NEW.produto_id, NEW.num_versao, NEW.data_lancamento);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_versao(id_versao, acao, produto_id, num_versao, data_lancamento)
        VALUES (OLD.id_versao, 'DELETE', OLD.produto_id, OLD.num_versao, OLD.data_lancamento);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_versao
AFTER INSERT OR UPDATE OR DELETE ON versao
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_versao();

-- Trigger para preenchimento da tabela de auditoria referente à tabela suporte
CREATE OR REPLACE FUNCTION log_auditoria_suporte() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_suporte(id_suporte, acao, usuario_id, produto_id, versao_id, tipo, descricao, data_suporte, status)
        VALUES (NEW.id_suporte, 'INSERT', NEW.usuario_id, NEW.produto_id, NEW.versao_id, NEW.tipo, NEW.descricao, NEW.data_suporte, NEW.status);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_suporte(id_suporte, acao, usuario_id, produto_id, versao_id, tipo, descricao, data_suporte, status)
        VALUES (NEW.id_suporte, 'UPDATE', NEW.usuario_id, NEW.produto_id, NEW.versao_id, NEW.tipo, NEW.descricao, NEW.data_suporte, NEW.status);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_suporte(id_suporte, acao, usuario_id, produto_id, versao_id, tipo, descricao, data_suporte, status)
        VALUES (OLD.id_suporte, 'DELETE', OLD.usuario_id, OLD.produto_id, OLD.versao_id, OLD.tipo, OLD.descricao, OLD.data_suporte, OLD.status);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_suporte
AFTER INSERT OR UPDATE OR DELETE ON suporte
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_suporte();

-- Trigger para preenchimento da tabela de auditoria referente à tabela versão
CREATE OR REPLACE FUNCTION log_auditoria_avaliacao() RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO auditoria_avaliacao(id_avaliacao, acao, usuario_id, versao_id, nota, data_avaliacao)
            VALUES (NEW.id_avaliacao, 'INSERT', NEW.usuario_id, NEW.versao_id, NEW.nota, NEW.data_avaliacao);
            RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO auditoria_avaliacao(id_avaliacao, acao, usuario_id, versao_id, nota, data_avaliacao)
            VALUES (NEW.id_avaliacao, 'UPDATE', NEW.usuario_id, NEW.versao_id, NEW.nota, NEW.data_avaliacao);
            RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
            INSERT INTO auditoria_avaliacao(id_avaliacao, acao, usuario_id, versao_id, nota, data_avaliacao)
            VALUES (OLD.id_avaliacao, 'DELETE', OLD.usuario_id, OLD.versao_id, OLD.nota, OLD.data_avaliacao);
            RETURN OLD;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_avaliacao
AFTER INSERT OR UPDATE OR DELETE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_avaliacao();

-- Trigger para preenchimento da tabela de auditoria referente à tabela versão
CREATE OR REPLACE FUNCTION log_auditoria_parcela() RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO auditoria_parcela(id_parcela, acao, assinatura_id, valor, data_vencimento, data_pagamento, status)
            VALUES (NEW.id_parcela, 'INSERT', NEW.assinatura_id, NEW.valor, NEW.data_vencimento, NEW.data_pagamento, NEW.status);
            RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO auditoria_parcela(id_parcela, acao, assinatura_id, valor, data_vencimento, data_pagamento, status)
            VALUES (NEW.id_parcela, 'UPDATE', NEW.assinatura_id, NEW.valor, NEW.data_vencimento, NEW.data_pagamento, NEW.status);
            RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
            INSERT INTO auditoria_parcela(id_parcela, acao, assinatura_id, valor, data_vencimento, data_pagamento, status)
            VALUES (OLD.id_parcela, 'DELETE', OLD.assinatura_id, OLD.valor, OLD.data_vencimento, OLD.data_pagamento, OLD.status);
            RETURN OLD;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_parcela
AFTER INSERT OR UPDATE OR DELETE ON parcela
FOR EACH ROW
EXECUTE FUNCTION log_auditoria_parcela();
