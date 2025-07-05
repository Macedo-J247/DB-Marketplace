-- Triggers

-- Trigger para preenchimento da tabela de auditoria referente a tabela assinatura
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

-- Trigger para preenchimento da tabela de auditoria referente a tabela assinatura
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

-- Trigger para preenchimento da tabela de auditoria referente a tabela desenvolvimento
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
