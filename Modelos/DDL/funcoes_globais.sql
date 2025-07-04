-- Inserções globais por nome de tabela
CREATE OR REPLACE FUNCTION insercao_global() RETURNS INT AS $$
$$ LANGUAGE plpgsql;

-- Atualizações globais por nome de tabela
CREATE OR REPLACE FUNCTION atualizacao_global() RETURNS INT AS $$
$$ LANGUAGE plpgsql;

-- Remoções globais por nome de tabela
CREATE OR REPLACE FUNCTION remocao_global() RETURNS INT AS $$
$$ LANGUAGE plpgsql;
