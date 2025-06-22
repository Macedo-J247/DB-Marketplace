-- Este arquivo contém a função para validar o preço de um produto.
-- Ela garante que o preço seja um valor positivo antes de ser inserido ou atualizado.

CREATE OR REPLACE FUNCTION validar_preco_produto()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o novo preço for menor ou igual a zero, levanta uma exceção (erro).
    IF NEW.preco <= 0 THEN
        RAISE EXCEPTION 'O preço do produto "%" deve ser um valor positivo.', NEW.nome_produto;
    END IF;
    -- Retorna NEW para indicar que a operação pode continuar com os novos dados.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
