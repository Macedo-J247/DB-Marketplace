-- Este arquivo contém o trigger que chama a função atualizar_data_atualizacao_produto.
-- Ele é acionado antes de qualquer atualização na tabela 'produto' para manter o registro da última modificação.

CREATE TRIGGER trg_produto_data_atualizacao
BEFORE UPDATE ON produto -- Aciona antes de ATUALIZAR registros na tabela 'produto'.
FOR EACH ROW -- Para cada linha que será atualizada.
EXECUTE FUNCTION atualizar_data_atualizacao_produto(); -- Executa a função que atualiza a data.
