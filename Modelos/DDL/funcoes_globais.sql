-- Inserções globais por nome de tabela
-- Testada e validada
CREATE OR REPLACE FUNCTION insercao_global(tab TEXT, VARIADIC campos TEXT[]) RETURNS INT AS $$
    DECLARE
        resultado INT;
    BEGIN
        CASE LOWER(tab)
            WHEN 'desenvolvedor' THEN
                EXECUTE format('SELECT cadastrar_desenvolvedor(%L, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'categoria' THEN
                EXECUTE format('SELECT cadastrar_categoria(%L, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'usuario' THEN
                EXECUTE format('SELECT cadastrar_usuario(%L, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4]) INTO resultado;
            WHEN 'produto' THEN
                EXECUTE format('SELECT cadastrar_produto(%s, %s, %L, %L, %s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5], campos[6], campos[7], campos[8]) INTO resultado;
            WHEN 'software' THEN
                EXECUTE format('SELECT cadastrar_software(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'api' THEN
                EXECUTE format('SELECT cadastrar_api(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'versao' THEN
                EXECUTE format('SELECT cadastrar_versao(%s, %L, %L)', campos[1], campos[2], campos[3]) INTO resultado;
            WHEN 'suporte' THEN
                EXECUTE format('SELECT cadastrar_suporte(%s, %s, %s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5], campos[6]) INTO resultado;
            WHEN 'avaliacao' THEN
                EXECUTE format('SELECT cadastrar_avaliacao(%s, %s, %s)', campos[1], campos[2], campos[3], campos[4]) INTO resultado;
            WHEN 'tipo_pagamento' THEN
                EXECUTE format('SELECT cadastrar_tipo_pagamento(%L)', campos[1]) INTO resultado;
            WHEN 'assinatura' THEN
                EXECUTE format('SELECT cadastrar_assinatura(%s, %s, %s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5], campos[6]) INTO resultado;
            WHEN 'parcela' THEN
                EXECUTE format('SELECT cadastrar_parcela(%s, %s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5]) INTO resultado;
            ELSE
                RAISE EXCEPTION 'Tabela % não suportada para inserção.', tab;
        END CASE;

        RETURN resultado;
    END;
$$ LANGUAGE plpgsql;

-- Atualizações globais por nome de tabela
-- Testada e atualizada
CREATE OR REPLACE FUNCTION atualizacao_global(tab TEXT, VARIADIC campos TEXT[]) RETURNS INT AS $$
    DECLARE
        resultado INT;
    BEGIN
        CASE LOWER(tab)
            WHEN 'desenvolvedor' THEN
                EXECUTE format('SELECT atualizar_desenvolvedor(%s, %L, %L)', campos[1], campos[2], campos[3]) INTO resultado;
            WHEN 'categoria' THEN
                EXECUTE format('SELECT atualizar_categoria(%s, %L, %L)', campos[1], campos[2], campos[3]) INTO resultado;
            WHEN 'usuario' THEN
                EXECUTE format('SELECT atualizar_usuario(%s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4]) INTO resultado;
            WHEN 'produto' THEN
                EXECUTE format('SELECT atualizar_produto(%s, %s, %L, %L, %s, %L, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5], campos[6], campos[7], campos[8], campos[9]) INTO resultado;
            WHEN 'software' THEN
                EXECUTE format('SELECT atualizar_software(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'api' THEN
                EXECUTE format('SELECT atualizar_api(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'versao' THEN
                EXECUTE format('SELECT atualizar_versao(%s, %L, %L)', campos[1], campos[2], campos[3]) INTO resultado;
            WHEN 'suporte' THEN
                EXECUTE format('SELECT atualizar_suporte(%s, %s, %s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5], campos[6]) INTO resultado;
            WHEN 'avaliacao' THEN
                EXECUTE format('SELECT atualizar_avaliacao(%s, %s, %s, %L)', campos[1], campos[2], campos[3], campos[4]) INTO resultado;
            WHEN 'tipo_pagamento' THEN
                EXECUTE format('SELECT atualizar_tipo_pagamento(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'assinatura' THEN
                EXECUTE format('SELECT atualizar_assinatura(%s, %s, %s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5], campos[6]) INTO resultado;
            WHEN 'parcela' THEN
                EXECUTE format('SELECT atualizar_parcela(%s, %s, %L, %L, %L)', campos[1], campos[2], campos[3], campos[4], campos[5]) INTO resultado;
            ELSE
                RAISE EXCEPTION 'Tabela % não suportada para atualização.', tab;
        END CASE;
        
        RETURN resultado;
    END;
$$ LANGUAGE plpgsql;

-- Remoções globais por nome de tabela
-- Testada e validada
CREATE OR REPLACE FUNCTION remocao_global(tab TEXT, VARIADIC campos TEXT[]) RETURNS TEXT AS $$
    DECLARE
        resultado TEXT;
    BEGIN
        CASE LOWER(tab)
            WHEN 'desenvolvedor' THEN
                EXECUTE format('SELECT excluir_desenvolvedor(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'categoria' THEN
                EXECUTE format('SELECT excluir_categoria(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'usuario' THEN
                EXECUTE format('SELECT excluir_usuario(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'produto' THEN
                EXECUTE format('SELECT excluir_produto(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'software' THEN
                EXECUTE format('SELECT excluir_software(%s)', campos[1]) INTO resultado;
            WHEN 'api' THEN
                EXECUTE format('SELECT excluir_api(%s)', campos[1]) INTO resultado;
            WHEN 'versao' THEN
                EXECUTE format('SELECT excluir_versao(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'suporte' THEN
                EXECUTE format('SELECT excluir_suporte(%s)', campos[1]) INTO resultado;
            WHEN 'avaliacao' THEN
                EXECUTE format('SELECT excluir_avaliacao(%s, %s)', campos[1], campos[2]) INTO resultado;
            WHEN 'tipo_pagamento' THEN
                EXECUTE format('SELECT excluir_tipo_pagamento(%s)', campos[1]) INTO resultado;
            WHEN 'assinatura' THEN
                EXECUTE format('SELECT excluir_assinatura(%s, %L)', campos[1], campos[2]) INTO resultado;
            WHEN 'parcela' THEN
                EXECUTE format('SELECT excluir_parcela(%s)', campos[1]) INTO resultado;
            ELSE
                RAISE EXCEPTION 'Tabela % não suportada para exclusão.', tab;
        END CASE;

        RETURN resultado;
    END;
$$ LANGUAGE plpgsql;
