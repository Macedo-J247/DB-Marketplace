-- Este arquivo contém todos os triggers relacionados à tabela "avaliacao".

-- Trigger: trg_validar_nota_avaliacao
-- Objetivo: Chama a função validar_nota_avaliacao para garantir que a nota seja válida.
-- Disparo: Antes de INSERIR ou ATUALIZAR registros na tabela 'avaliacao'.
CREATE TRIGGER trg_validar_nota_avaliacao
BEFORE INSERT OR UPDATE ON avaliacao -- Aciona antes de INSERIR ou ATUALIZAR registros na tabela 'avaliacao'.
FOR EACH ROW -- Para cada linha que será inserida ou atualizada.
EXECUTE FUNCTION validar_nota_avaliacao(); -- Executa a função que valida a nota.
