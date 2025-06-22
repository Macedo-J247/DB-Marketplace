-- Este arquivo contém a função para verificar o status de um produto antes de permitir uma assinatura.
-- Ela impede que usuários assinem produtos que não estejam com o status 'ativo'.

CREATE OR REPLACE FUNCTION verificar_status_produto_assinatura()
RETURNS TRIGGER AS $$
DECLARE
    v_status_produto enum_status_produto; -- USANDO O TIPO ENUM NOMEADO
    v_nome_produto VARCHAR(255);
BEGIN
    -- Busca o status e o nome do produto associado à versão que está sendo assinada.
    SELECT
        p.status,
        p.nome_produto
    INTO
        v_status_produto,
        v_nome_produto
    FROM
        produto p
    JOIN
        versao v ON p.id_produto = v.produto_id
    WHERE
        v.id_versao = NEW.versao_id;

    -- Se a versão do produto não for encontrada, levanta um erro.
    IF v_status_produto IS NULL THEN
        RAISE EXCEPTION 'Versão do produto com ID % não encontrada para a assinatura.', NEW.versao_id;
    -- Se o status do produto não for 'ativo', levanta um erro impedindo a assinatura.
    ELSIF v_status_produto <> 'ativo' THEN
        RAISE EXCEPTION 'Não é possível assinar o produto "%" porque ele está com o status "%". Somente produtos "ativos" podem ser assinados.', v_nome_produto, v_status_produto;
    END IF;

    -- Retorna NEW para indicar que a operação pode continuar.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
