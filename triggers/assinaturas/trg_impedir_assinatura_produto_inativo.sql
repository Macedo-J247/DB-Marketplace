-- Este arquivo contém o trigger que chama a função verificar_status_produto_assinatura.
-- Ele é acionado antes de qualquer tentativa de inserção na tabela 'assinatura'
-- para garantir que apenas produtos 'ativos' possam ser assinados.

CREATE TRIGGER trg_impedir_assinatura_produto_inativo
BEFORE INSERT ON assinatura -- Aciona antes de INSERIR registros na tabela 'assinatura'.
FOR EACH ROW -- Para cada linha que será inserida.
EXECUTE FUNCTION verificar_status_produto_assinatura(); -- Executa a função que verifica o status do produto.
