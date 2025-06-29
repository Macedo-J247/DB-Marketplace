-- VIEW: APIs com detalhes
CREATE OR REPLACE VIEW vw_apis AS
SELECT
    p.id_produto AS id,
    p.nome_produto AS nome,
    p.descricao,
    p.preco,
    p.status,
    a.endpoint_url AS url,
    p.data_publicacao,
    p.data_atualizacao,
    p.tipo,
    p.categoria_id,
    p.desenvolvedor_id
FROM produto p
JOIN api a ON a.produto_id = p.id_produto;

-- VIEW: Softwares com detalhes
CREATE OR REPLACE VIEW vw_softwares AS
SELECT
    p.id_produto AS id,
    p.nome_produto AS nome,
    p.descricao,
    p.preco,
    p.status,
    s.tipo_licenca,
    p.data_publicacao,
    p.data_atualizacao,
    p.tipo,
    p.categoria_id,
    p.desenvolvedor_id
FROM produto p
JOIN software s ON s.produto_id = p.id_produto;

-- VIEW: Produtos com tipo API ou Software e categoria
CREATE OR REPLACE VIEW vw_produtos_com_categoria AS
SELECT
    p.id_produto,
    p.nome_produto,
    p.descricao,
    p.preco,
    p.tipo,
    p.status,
    p.data_publicacao,
    p.data_atualizacao,
    c.nome_categoria,
    d.nome_dev
FROM produto p
JOIN categoria c ON p.categoria_id = c.id_categoria
JOIN desenvolvedor d ON p.desenvolvedor_id = d.id_desenvolvedor;

-- VIEW: Versões de produto com nome do produto e desenvolvedor
CREATE OR REPLACE VIEW vw_versoes_com_produto AS
SELECT
    v.id_versao,
    v.num_versao,
    v.data_lancamento,
    p.id_produto,
    p.nome_produto,
    d.nome_dev
FROM versao v
JOIN produto p ON v.produto_id = p.id_produto
JOIN desenvolvedor d ON p.desenvolvedor_id = d.id_desenvolvedor;

-- VIEW: Assinaturas com nome do usuário, produto, versão e tipo de pagamento
CREATE OR REPLACE VIEW vw_assinaturas_completas AS
SELECT
    a.id_assinatura,
    a.data_inicio,
    a.data_termino,
    a.status,
    u.nome_usuario,
    v.num_versao,
    p.nome_produto,
    tp.nome_tipo AS tipo_pagamento
FROM assinatura a
JOIN usuario u ON a.usuario_id = u.id_usuario
JOIN versao v ON a.versao_id = v.id_versao
JOIN produto p ON v.produto_id = p.id_produto
JOIN tipo_pagamento tp ON a.tipo_pagamento_id = tp.id_tipo_pagamento;

-- VIEW: Parcelas de assinatura com situação
CREATE OR REPLACE VIEW vw_parcelas_detalhadas AS
SELECT
    par.id_parcela,
    par.valor,
    par.data_vencimento,
    par.data_pagamento,
    par.status,
    ass.id_assinatura,
    u.nome_usuario,
    p.nome_produto,
    v.num_versao
FROM parcela par
JOIN assinatura ass ON par.assinatura_id = ass.id_assinatura
JOIN usuario u ON ass.usuario_id = u.id_usuario
JOIN versao v ON ass.versao_id = v.id_versao
JOIN produto p ON v.produto_id = p.id_produto;

-- VIEW: Suportes com detalhes
CREATE OR REPLACE VIEW vw_suportes_detalhados AS
SELECT
    s.id_suporte,
    s.tipo,
    s.descricao,
    s.status,
    s.data_suporte,
    u.nome_usuario,
    p.nome_produto,
    v.num_versao
FROM suporte s
JOIN usuario u ON s.usuario_id = u.id_usuario
JOIN produto p ON s.produto_id = p.id_produto
JOIN versao v ON s.versao_id = v.id_versao;

-- VIEW: Avaliações com média por produto
CREATE OR REPLACE VIEW vw_avaliacoes_produto AS
SELECT
    p.id_produto,
    p.nome_produto,
    COUNT(a.id_avaliacao) AS total_avaliacoes,
    ROUND(AVG(a.nota), 2) AS media_nota
FROM avaliacao a
JOIN versao v ON a.versao_id = v.id_versao
JOIN produto p ON v.produto_id = p.id_produto
GROUP BY p.id_produto, p.nome_produto;
