CREATE OR REPLACE FUNCTION log_auditoria_assinatura() RETURNS TRIGGER AS $$
    BEGIN
        -- INSERT
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO auditoria_assinatura(id_assinatura, acao, usuario_id, versao_id, tipo_pagamento_id, data_inicio, data_termino, status)
            VALUES (NEW.id_assinatura, 'INSERT', NEW.usuario_id, NEW.versao_id, NEW.tipo_pagamento_id, NEW.data_inicio, NEW.data_termino, NEW.status);

            RETURN NEW;
        
        -- UPDATE
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO auditoria_assinatura(id_assinatura, acao, usuario_id, versao_id, tipo_pagamento_id, data_inicio, data_termino, status)
            VALUES (NEW.id_assinatura, 'UPDATE', NEW.usuario_id, NEW.versao_id, NEW.tipo_pagamento_id, NEW.data_inicio, NEW.data_termino, NEW.status);

            RETURN NEW;

        -- DELETE
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