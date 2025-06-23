-- Este arquivo contém todas as funções (PL/pgSQL) relacionadas à tabela "produto".

-- Função: validar_preco_produto
-- Objetivo: Garante que o preço de um produto seja sempre um valor positivo.
-- Acionada por: Trigger trg_validar_preco_produto (antes de INSERT/UPDATE)
CREATE OR REPLACE FUNCTION validar_preco_produto()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o novo preço for menor ou igual a zero, levanta uma exceção (erro).
    IF NEW.preco <= 0 THEN
        RAISE EXCEPTION 'O preço do produto "%" deve ser um valor positivo. Valor fornecido: %', NEW.nome_produto, NEW.preco;
    END IF;
    -- Retorna NEW para indicar que a operação pode continuar com os novos dados.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função: atualizar_data_atualizacao_produto
-- Objetivo: Atualiza automaticamente a coluna 'data_atualizacao' do produto
--           para o momento atual sempre que o registro é modificado.
-- Acionada por: Trigger trg_produto_data_atualizacao (antes de UPDATE)
CREATE OR REPLACE FUNCTION atualizar_data_atualizacao_produto()
RETURNS TRIGGER AS $$
BEGIN
    -- Define a coluna 'data_atualizacao' da nova linha para o timestamp atual.
    NEW.data_atualizacao = NOW();
    -- Retorna NEW para indicar que a operação pode continuar com os novos dados.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
