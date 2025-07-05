-- Trigger para impedir exclusão do próprio administrador
CREATE OR REPLACE FUNCTION trigger_bloquear_exclusao_admin()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.tipo_usuario = 'admin' THEN
        RAISE EXCEPTION 'Não é permitido excluir um usuário do tipo "admin" diretamente.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bloquear_exclusao_admin
BEFORE DELETE ON usuario
FOR EACH ROW
EXECUTE FUNCTION trigger_bloquear_exclusao_admin();

