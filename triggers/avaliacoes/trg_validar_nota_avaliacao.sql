-- Este arquivo contém o trigger que chama a função validar_nota_avaliacao.
-- Ele é acionado antes de qualquer tentativa de inserção ou atualização na tabela 'avaliacao'.

CREATE TRIGGER trg_validar_nota_avaliacao
BEFORE INSERT OR UPDATE ON avaliacao -- Aciona antes de INSERIR ou ATUALIZAR registros na tabela 'avaliacao'.
FOR EACH ROW -- Para cada linha que será inserida ou atualizada.
EXECUTE FUNCTION validar_nota_avaliacao(); -- Executa a função que valida a nota.
