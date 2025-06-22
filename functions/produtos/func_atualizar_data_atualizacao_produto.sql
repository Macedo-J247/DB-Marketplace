-- Este arquivo contém a função para atualizar automaticamente a data de atualização de um produto.
-- Sempre que um produto é modificado, esta função registra o timestamp da última modificação.

CREATE OR REPLACE FUNCTION atualizar_data_atualizacao_produto()
RETURNS TRIGGER AS $$
BEGIN
    -- Define a coluna 'data_atualizacao' da nova linha para o timestamp atual.
    NEW.data_atualizacao = NOW();
    -- Retorna NEW para indicar que a operação pode continuar com os novos dados.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
