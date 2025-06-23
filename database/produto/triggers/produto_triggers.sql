-- Este arquivo contém todos os triggers relacionados à tabela "produto".

-- Trigger: trg_validar_preco_produto
-- Objetivo: Chama a função validar_preco_produto para garantir que o preço seja válido.
-- Disparo: Antes de INSERIR ou ATUALIZAR registros na tabela 'produto'.
CREATE TRIGGER trg_validar_preco_produto
BEFORE INSERT OR UPDATE ON produto -- Aciona antes de INSERIR ou ATUALIZAR registros na tabela 'produto'.
FOR EACH ROW -- Para cada linha que será inserida ou atualizada.
EXECUTE FUNCTION validar_preco_produto(); -- Executa a função que valida o preço.

-- Trigger: trg_produto_data_atualizacao
-- Objetivo: Chama a função atualizar_data_atualizacao_produto para registrar a última modificação.
-- Disparo: Antes de ATUALIZAR registros na tabela 'produto'.
CREATE TRIGGER trg_produto_data_atualizacao
BEFORE UPDATE ON produto -- Aciona antes de ATUALIZAR registros na tabela 'produto'.
FOR EACH ROW -- Para cada linha que será atualizada.
EXECUTE FUNCTION atualizar_data_atualizacao_produto(); -- Executa a função que atualiza a data.
