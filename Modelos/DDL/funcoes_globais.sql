-- Inserções globais por nome de tabela
CREATE OR REPLACE FUNCTION insercao_global() RETURNS INT AS $$
    DECLARE
        resultado INT;
    BEGIN
    END;
$$ LANGUAGE plpgsql;

-- Atualizações globais por nome de tabela
CREATE OR REPLACE FUNCTION atualizacao_global() RETURNS INT AS $$
    DECLARE
        resultado INT;
    BEGIN
    END;
$$ LANGUAGE plpgsql;

-- Remoções globais por nome de tabela
CREATE OR REPLACE FUNCTION remocao_global() RETURNS TEXT AS $$
    DECLARE
        resultado TEXT;
    BEGIN
    END;
$$ LANGUAGE plpgsql;
