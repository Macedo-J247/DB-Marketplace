-- 📦 1. Produtos mais assinados
CREATE OR REPLACE VIEW vw_produtos_mais_assinados AS
SELECT
    p.nome_produto,
    COUNT(a.id_assinatura) AS total_assinaturas
FROM assinatura a
JOIN versao v ON v.id_versao = a.versao_id
JOIN produto p ON p.id_produto = v.produto_id
GROUP BY p.nome_produto
ORDER BY total_assinaturas DESC;

-- ⭐ 2. Média de avaliação por produto
CREATE OR REPLACE VIEW vw_media_avaliacao_produto AS
SELECT
    p.nome_produto,
    ROUND(AVG(a.nota), 2) AS media_nota,
    COUNT(a.id_avaliacao) AS total_avaliacoes
FROM avaliacao a
JOIN versao v ON v.id_versao = a.versao_id
JOIN produto p ON p.id_produto = v.produto_id
GROUP BY p.nome_produto;

-- 💳 3. Assinaturas por tipo de pagamento
CREATE OR REPLACE VIEW vw_assinaturas_por_pagamento AS
SELECT
    tp.nome_tipo AS tipo_pagamento,
    COUNT(a.id_assinatura) AS total_assinaturas
FROM assinatura a
JOIN tipo_pagamento tp ON tp.id_tipo_pagamento = a.tipo_pagamento_id
GROUP BY tp.nome_tipo;

-- 💳 4. Receita mensal (parcelas pagas)
CREATE OR REPLACE VIEW vw_receita_mensal AS
SELECT
    DATE_TRUNC('month', p.data_pagamento) AS mes_referencia,
    SUM(p.valor) AS total_receita
FROM parcela p
WHERE p.status = 'pago'
GROUP BY DATE_TRUNC('month', p.data_pagamento)
ORDER BY mes_referencia;

-- 🧩 5. Produtos com suporte aberto e nota < 3
CREATE OR REPLACE VIEW vw_produtos_problema AS
SELECT
    p.nome_produto,
    COUNT(s.id_suporte) AS total_suportes_abertos,
    ROUND(AVG(a.nota), 2) AS media_nota
FROM produto p
JOIN versao v ON v.produto_id = p.id_produto
LEFT JOIN suporte s ON s.versao_id = v.id_versao AND s.status IN ('aberto', 'em andamento')
LEFT JOIN avaliacao a ON a.versao_id = v.id_versao
GROUP BY p.nome_produto
HAVING COUNT(s.id_suporte) > 0 AND AVG(a.nota) < 3;

-- 🧑‍💻 6. Total de produtos por desenvolvedor
CREATE OR REPLACE VIEW vw_produtos_por_desenvolvedor AS
SELECT
    d.nome_dev,
    COUNT(p.id_produto) AS total_produtos
FROM desenvolvedor d
LEFT JOIN produto p ON p.desenvolvedor_id = d.id_desenvolvedor
GROUP BY d.nome_dev;

-- 🎧 7. Chamados por tipo de suporte
CREATE OR REPLACE VIEW vw_suporte_por_tipo AS
SELECT
    tipo,
    COUNT(*) AS total
FROM suporte
GROUP BY tipo;

-- 🎧 8. Chamados por status
CREATE OR REPLACE VIEW vw_suporte_por_status AS
SELECT
    status,
    COUNT(*) AS total
FROM suporte
GROUP BY status;

-- 💳 9. Parcelas em atraso
CREATE OR REPLACE VIEW vw_parcelas_em_atraso AS
SELECT
    p.id_parcela,
    u.nome_usuario,
    p.valor,
    p.data_vencimento
FROM parcela p
JOIN assinatura a ON a.id_assinatura = p.assinatura_id
JOIN usuario u ON u.id_usuario = a.usuario_id
WHERE p.status = 'pendendte' AND p.data_vencimento < CURRENT_DATE;

-- 🧩 10. Usuários com mais de uma assinatura ativa
CREATE OR REPLACE VIEW vw_usuarios_multi_assinatura AS
SELECT
    u.nome_usuario,
    COUNT(a.id_assinatura) AS total_assinaturas_ativas
FROM usuario u
JOIN assinatura a ON a.usuario_id = u.id_usuario
WHERE a.status = 'ativa'
GROUP BY u.nome_usuario
HAVING COUNT(a.id_assinatura) > 1;
