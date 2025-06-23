-- Este arquivo contém todos os triggers relacionados à tabela "parcela".

-- Trigger: trg_parcela_data_pagamento
-- Objetivo: Chama a função registrar_data_pagamento_parcela para automatizar o registro da data de pagamento.
-- Disparo: Antes de ATUALIZAR registros na tabela 'parcela'.
CREATE TRIGGER trg_parcela_data_pagamento
BEFORE UPDATE ON parcela -- Aciona antes de ATUALIZAR registros na tabela 'parcela'.
FOR EACH ROW -- Para cada linha que será atualizada.
EXECUTE FUNCTION registrar_data_pagamento_parcela(); -- Executa a função que registra a data de pagamento.
