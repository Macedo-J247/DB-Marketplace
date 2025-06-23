-- Este arquivo contém todos os triggers relacionados à tabela "assinatura".

-- Trigger: trg_impedir_assinatura_produto_inativo
-- Objetivo: Chama a função verificar_status_produto_assinatura para garantir que
--           apenas produtos 'ativos' possam ser assinados.
-- Disparo: Antes de INSERIR registros na tabela 'assinatura'.
CREATE TRIGGER trg_impedir_assinatura_produto_inativo
BEFORE INSERT ON assinatura -- Aciona antes de INSERIR registros na tabela 'assinatura'.
FOR EACH ROW -- Para cada linha que será inserida.
EXECUTE FUNCTION verificar_status_produto_assinatura(); -- Executa a função que verifica o status do produto.
