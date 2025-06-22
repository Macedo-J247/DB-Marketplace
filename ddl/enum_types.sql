-- Este arquivo contém a definição dos tipos ENUM personalizados.
-- Estes tipos devem ser criados antes das tabelas e funções que os utilizam.

-- Tipo ENUM para o status do produto
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_status_produto') THEN
        CREATE TYPE "enum_status_produto" AS ENUM('ativo', 'inativo', 'revisao');
    END IF;
END
$$ LANGUAGE plpgsql;

-- Tipo ENUM para o tipo de produto
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_tipo_produto') THEN
        CREATE TYPE "enum_tipo_produto" AS ENUM('software', 'api');
    END IF;
END
$$ LANGUAGE plpgsql;

-- Tipo ENUM para o tipo de usuário
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_tipo_usuario') THEN
        CREATE TYPE "enum_tipo_usuario" AS ENUM('cliente', 'admin', 'desenvolvedor');
    END IF;
END
$$ LANGUAGE plpgsql;

-- Tipo ENUM para o tipo de suporte
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_tipo_suporte') THEN
        CREATE TYPE "enum_tipo_suporte" AS ENUM('erro', 'duvida', 'melhoria');
    END IF;
END
$$ LANGUAGE plpgsql;

-- Tipo ENUM para o status do suporte
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_status_suporte') THEN
        CREATE TYPE "enum_status_suporte" AS ENUM('aberto', 'em andamento', 'resolvido', 'fechado', 'cancelado');
    END IF;
END
$$ LANGUAGE plpgsql;

-- Tipo ENUM para o tipo de pagamento
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_tipo_pagamento') THEN
        CREATE TYPE "enum_tipo_pagamento" AS ENUM('cartao', 'boleto', 'pix');
    END IF;
END
$$ LANGUAGE plpgsql;

-- Tipo ENUM para o status da assinatura
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_status_assinatura') THEN
        CREATE TYPE "enum_status_assinatura" AS ENUM('ativa', 'suspensa', 'cancelada', 'expirada', 'teste');
    END IF;
END
$$ LANGUAGE plpgsql;

-- Tipo ENUM para o status da parcela
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_status_parcela') THEN
        CREATE TYPE "enum_status_parcela" AS ENUM('pendente', 'pago', 'atrasado', 'falha', 'estornado');
    END IF;
END
$$ LANGUAGE plpgsql;
