-- Este arquivo contém todas as funções (PL/pgSQL) relacionadas à tabela "parcela".

-- Função: registrar_data_pagamento_parcela
-- Objetivo: Registra automaticamente a data em que uma parcela foi paga.
-- Acionada por: Trigger trg_parcela_data_pagamento (antes de UPDATE)
CREATE OR REPLACE FUNCTION registrar_data_pagamento_parcela()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o novo status da parcela é 'pago' e se o status antigo não era 'pago'.
    -- Isso evita atualizar a data se a parcela já estava marcada como paga.
    IF NEW.status = 'pago' AND OLD.status <> 'pago' THEN
        NEW.data_pagamento = CURRENT_DATE; -- Define a data de pagamento para a data atual.
    END IF;
    -- Retorna NEW para indicar que a operação pode continuar com os novos dados.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
