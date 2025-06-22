-- Este arquivo contém o trigger que chama a função validar_preco_produto.
-- Ele é acionado antes de qualquer tentativa de inserção ou atualização na tabela 'produto'.

CREATE TRIGGER trg_validar_preco_produto
BEFORE INSERT OR UPDATE ON produto -- Aciona antes de INSERIR ou ATUALIZAR registros na tabela 'produto'.
FOR EACH ROW -- Para cada linha que será inserida ou atualizada.
EXECUTE FUNCTION validar_preco_produto(); -- Executa a função que valida o preço.
