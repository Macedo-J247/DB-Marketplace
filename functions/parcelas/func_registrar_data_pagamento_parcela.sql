-- Este arquivo contém a função para registrar a data de pagamento de uma parcela.
-- Se o status de uma parcela muda para 'pago' e a data de pagamento ainda não está definida,
-- ela é preenchida automaticamente com a data atual.

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
