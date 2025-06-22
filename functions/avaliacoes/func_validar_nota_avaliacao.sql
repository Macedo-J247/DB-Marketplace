-- Este arquivo contém a função para validar a nota de uma avaliação.
-- Ela garante que a nota esteja dentro de um intervalo válido (0.00 a 5.00).

CREATE OR REPLACE FUNCTION validar_nota_avaliacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Assumindo que a nota deve estar entre 0.00 e 5.00 (inclusive).
    IF NEW.nota < 0.00 OR NEW.nota > 5.00 THEN
        -- Se a nota estiver fora do intervalo, levanta uma exceção (erro).
        RAISE EXCEPTION 'A nota da avaliação deve estar entre 0.00 e 5.00 (inclusive). Nota fornecida: %', NEW.nota;
    END IF;
    -- Retorna NEW para indicar que a operação pode continuar com os novos dados.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
