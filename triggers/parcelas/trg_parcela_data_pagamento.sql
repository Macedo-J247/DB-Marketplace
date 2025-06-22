-- Este arquivo contém o trigger que chama a função registrar_data_pagamento_parcela.
-- Ele é acionado antes de qualquer atualização na tabela 'parcela' para automatizar o registro da data de pagamento.

CREATE TRIGGER trg_parcela_data_pagamento
BEFORE UPDATE ON parcela -- Aciona antes de ATUALIZAR registros na tabela 'parcela'.
FOR EACH ROW -- Para cada linha que será atualizada.
EXECUTE FUNCTION registrar_data_pagamento_parcela(); -- Executa a função que registra a data de pagamento.
