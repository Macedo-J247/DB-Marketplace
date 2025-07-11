-- Exemplo geral
-- SELECT insercao_global('tabela', 'dados', 'referente', 'aquela', 'tabela');

-- Desenvolvedores
-- Exemplo:
-- SELECT insercao_global('desenvolvedor', 'nome sobrenome', 'email@mail.com');

-- SELECT atualizacao_global('desenvolvedor', 'id do desenvolvedor', 'nome', 'email');

-- SELECT remocao_global('desenvolvedor', 'id', 'nome');

-- Testada e validada
SELECT insercao_global('desenvolvedor', 'Ana Silva', 'ana.silva@dev.com');
SELECT insercao_global('desenvolvedor', 'Jose Santos', 'jose.santos@dev.com');
SELECT insercao_global('desenvolvedor', 'Wadson Dias', 'wadson.dias@dev.com');
SELECT insercao_global('desenvolvedor', 'Tiago Elias', 'tiago.elias@dev.com');
SELECT insercao_global('desenvolvedor', 'Bruna Castro', 'bruna.castro@dev.com');
SELECT insercao_global('desenvolvedor', 'Lucas Almeida', 'lucas.almeida@dev.com');
SELECT insercao_global('desenvolvedor', 'Helena Lopes', 'helena.lopes@dev.com');
SELECT insercao_global('desenvolvedor', 'Rafael Souza', 'rafael.souza@dev.com');

-- Categorias
-- Exemplo:
-- SELECT insercao_global('categoria', 'nome da categoria', 'descrição');

-- SELECT atualizacao_global('categoria', 'id da categoria', 'nome', 'descricao(pode ser nula)');

-- SELECT remocao_global('categoria', 'id', 'nome');

-- Testada e validada
SELECT insercao_global('categoria', 'Desktop', 'Programas locais com interface gráfica');
SELECT insercao_global('categoria', 'Web', 'Sistemas acessados via navegador com funcionalidades');
SELECT insercao_global('categoria', 'Produtividade', 'Ferramenta para organização, escrita ou tarefas');
SELECT insercao_global('categoria', 'Design', 'Criação e edição de conteúdo visual ou audiovisual');
SELECT insercao_global('categoria', 'Educação', 'Ferramentas para aprendizagem e ensino');
SELECT insercao_global('categoria', 'Financeiro', 'Sistemas de gestão de finanças pessoais ou empresariais');
SELECT insercao_global('categoria', 'Autenticação', 'Ferramentas de login e controle de acesso entre sistemas');
SELECT insercao_global('categoria', 'Mensageria', 'Programas de envio de mensagens por SMS, e-mail ou chat');
SELECT insercao_global('categoria', 'Dados Públicos', 'Sistemas de acesso a informações abertas de instituições');
SELECT insercao_global('categoria', 'Redes Sociais', 'Integração com plataformas sociais');
SELECT insercao_global('categoria', 'Pagamentos', 'Integração com sistemas financeiros e carteiras digitais');
SELECT insercao_global('categoria', 'Geolocalização', 'Serviços de mapas, endereços e rastreamento');

-- Usuários
-- Exemplo:
-- SELECT insercao_global('usuario', 'nome sobrenome', 'email@mail.com', 'senha', 'tipo de usuário('administrador', 'cliente', 'desenvolvedor')');

-- SELECT atualizacao_global('usuario', 'id do usuario', 'nome', 'email', 'senha', 'tipo('administrador', 'cliente', 'desenvolvedor')');

-- SELECT remocao_global('usuario', 'id', 'nome');

-- Testada e validada
SELECT insercao_global('usuario', 'Carlos Lima', 'carlos.lima@cliente.com', '123senha', 'cliente');
SELECT insercao_global('usuario', 'Mariana Dias', 'mariana.dias@cliente.com', '456senha', 'cliente');
SELECT insercao_global('usuario', 'João Pedro', 'joao.pedro@admin.com', 'admin123', 'administrador');
SELECT insercao_global('usuario', 'Lucas Dev', 'lucas.dev@dev.com', 'senha456', 'desenvolvedor');
SELECT insercao_global('usuario', 'Paula Souza', 'paula.souza@cliente.com', 'senha789', 'cliente');
SELECT insercao_global('usuario', 'Renato Braga', 'renato.braga@cliente.com', 'pass1234', 'cliente');
SELECT insercao_global('usuario', 'Fernanda Torres', 'fernanda.torres@admin.com', 'admin456', 'administrador');
SELECT insercao_global('usuario', 'Igor Lopes', 'igor.lopes@cliente.com', 'pass789', 'cliente');

-- Tipos de Pagamento
-- Exemplo:
-- SELECT insercao_global('tipo_pagamento', 'nome do tipo de pagamento('cartao', 'boleto', 'pix')');

-- SELECT atualizacao_global('tipo_pagamento', 'id', 'nome', 'tipo('cartao', 'boleto', 'pix')');

-- SELECT remocao_global('tipo_pagamento', 'id', 'tipo('cartao', 'boleto', 'pix')');

-- Testada e validada
SELECT insercao_global('tipo_pagamento', 'cartao');
SELECT insercao_global('tipo_pagamento', 'boleto');
SELECT insercao_global('tipo_pagamento', 'pix');

-- Produtos
-- Exemplo:
-- SELECT insercao_global('produto', 'id do desenvolvedor', 'id da categoria', 'nome do produto', 'descrição do produto', 'preco do produto', 'tipo do produto('software', 'api')', 'status do produto('ativo', 'inativo', 'revisao')', 'data da publicação do produto');

-- SELECT atualizacao_global('produto', 'id produto', 'id desenvolvedor', 'id categoria', 'nome', 'descricao(pode ser nulo)', 'valor', 'tipo('software', 'api')', 'status('ativo', 'inativo', 'revisao')', 'data de publicacao');

-- SELECT remocao_global('produto', 'id', 'nome');

-- Testada e validada
SELECT insercao_global('produto', '1', '1', 'PhotoMaster', 'Editor de imagens profissional', '299.99', 'software', 'ativo', '2024-01-10');
SELECT insercao_global('produto', '2', '2', 'NoteApp', 'Aplicativo de anotações rápido e prático', '19.99', 'software', 'ativo', '2024-02-05');
SELECT insercao_global('produto', '3', '5', 'AuthX', 'API de autenticação segura com OAuth2', '99.00', 'api', 'ativo', '2024-03-01');
SELECT insercao_global('produto', '4', '6', 'SendQuick', 'API de envio de SMS e emails', '149.50', 'api', 'ativo', '2024-04-15');
SELECT insercao_global('produto', '1', '4', 'DesignFlow', 'Editor gráfico intuitivo para design gráfico', '79.00', 'software', 'revisao', '2024-05-10');
SELECT insercao_global('produto', '5', '8', 'LearnSpace', 'Plataforma de ensino à distância', '199.90', 'software', 'ativo', '2024-05-20');
SELECT insercao_global('produto', '6', '9', 'GeoTrack', 'API para rastreamento em tempo real', '89.99', 'api', 'ativo', '2024-06-10');

-- Softwares (ligados aos produtos 1, 2 e 5)
-- Exemplo:
-- SELECT insercao_global('software', 'id do produto', 'nome da licença')

-- SELECT atualizacao_global('software', 'id produto', 'nome da licença');

-- SELECT remocao_global('software', 'id do produto', 'nome da licença');


-- Testada e validada
SELECT insercao_global('software', '1', 'licença perpétua');
SELECT insercao_global('software', '2', 'mensal');
SELECT insercao_global('software', '5', 'anual');
SELECT insercao_global('software', '6', 'mensal');

-- APIs (ligadas aos produtos 3 e 4)
-- Exemplo:
-- SELECT insercao_global('api', 'id do produto', 'link de endpoint da api')

-- SELECT atualizacao_global('api', 'id produto', 'link do endpoint');

-- SELECT remocao_global('api', 'id do produto', 'link do endpoint');

-- Testada e validada
SELECT insercao_global('api', '3', 'https://api.authx.com/v1');
SELECT insercao_global('api', '4', 'https://api.sendquick.io/v1');
SELECT insercao_global('api', '7', 'https://api.geotrack.io');

-- Versões
-- Exemplo:
-- SELECT insercao_global('versão', 'id do produto', 'número da versão', 'data de lançamento');

-- SELECT atualizacao_global('versão', 'id da versão', 'id do produto', 'número da versão', 'data de lançamento');

-- SELECT remocao_global('versão', 'id da versão', 'número da versão');

-- Testada e validada
SELECT insercao_global('versao', '1', '1.0', '2024-01-15');
SELECT insercao_global('versao', '1', '1.1', '2024-03-10');
SELECT insercao_global('versao', '3', 'v1', '2024-03-05');
SELECT insercao_global('versao', '4', 'v1.0', '2024-04-20');
SELECT insercao_global('versao', '5', 'beta', '2024-05-15');
SELECT insercao_global('versao', '7', 'v2.0', '2024-06-20');

-- Avaliações
-- Exemplo:
-- SELECT insercao_global('avaliacão', 'id do usuário', 'id da versão do produto', 'nota da avaliação', 'data da avaliacão');

-- SELECT atualizacao_global('avaliação', 'id da avaliação', 'nota em número decimal', 'data da avaliação');

-- SELECT remocao_global('avaliação', 'id da avaliação', 'id do usuário');

-- Testada e validada
SELECT insercao_global('avaliacao', '1', '1', '4.5', '2024-03-01');
SELECT insercao_global('avaliacao', '2', '2', '5.0', '2024-03-05');
SELECT insercao_global('avaliacao', '1', '3', '4.0', '2024-04-01');
SELECT insercao_global('avaliacao', '5', '4', '4.2', '2024-05-01');
SELECT insercao_global('avaliacao', '6', '6', '4.8', '2024-06-01');

-- Suportes
-- Exemplo:
-- SELECT insercao_global('suporte', 'id do usuário', 'id do produto', 'id da versão', 'tipo do suporte('erro', 'duvida', 'melhoria')', 'descrição do suporte', 'status dos suporte('aberto', 'em andamento', 'resolvido', 'fechado', 'cancelado')');

-- SELECT atualizacao_global('suporte', 'id do suporte', 'tipo do suporte('erro', 'duvida', 'melhoria')', 'descrição(pode ser nulo)', 'status('aberto', 'em andamento', 'resolvido', 'fechado', 'cancelado')');

-- SELECT remocao_global('suporte', 'id do suporte', 'id do usuário');

-- Testada e validada
SELECT insercao_global('suporte', '1', '1', '1', 'erro', 'Erro ao abrir imagem', 'aberto');
SELECT insercao_global('suporte', '2', '3', '3', 'duvida', 'Como configurar OAuth?', 'em andamento');
SELECT insercao_global('suporte', '1', '4', '4', 'melhoria', 'Sugestão de integração com WhatsApp', 'aberto');
SELECT insercao_global('suporte', '5', '5', '5', 'erro', 'Erro ao exportar PNG', 'resolvido');
SELECT insercao_global('suporte', '6', '6', '6', 'duvida', 'Dúvida sobre plano de assinatura', 'aberto');

-- Assinaturas
-- Exemplo:
-- SELECT insercao_global('assinatura', 'id do usuário', 'id da versão', 'id do tipo de pagamento', 'data de início', 'data de término', 'status da assinatura('ativa', 'suspensa', 'cancelada', 'expirada', 'teste')');

-- SELECT atualizacao_global('assinatura', 'id da assinatura', 'id do usuário', 'id da versão', 'id do tipo de pagamento', 'data de início', 'data de término(pode ser nulo)', 'status('ativa', 'suspensa', 'cancelada', 'expirada', 'teste')');

-- SELECT remocao_global('assinatura', 'id da assinatura', 'id do usuário');

-- Testada e validada
SELECT insercao_global('assinatura', '1', '3', '1', '2024-04-01', NULL, 'ativa');
SELECT insercao_global('assinatura', '2', '4', '3', '2024-04-10', NULL, 'ativa');
SELECT insercao_global('assinatura', '5', '1', '2', '2024-02-01', '2024-03-01', 'expirada');
SELECT insercao_global('assinatura', '6', '5', '1', '2024-05-20', NULL, 'ativa');
SELECT insercao_global('assinatura', '7', '6', '3', '2024-06-10', NULL, 'ativa');

-- Parcelas
-- Exemplo:
-- SELECT insercao_global('parcela', 'id da assinatura', 'valor', 'data de vencimento', 'data de pagamento', 'status da parcela('pendente', 'pago', 'atrasado', 'falha', 'estornado')');

-- SELECT atualizacao_global('parcela', 'id da assinatura', 'valor em decimal', 'data de vencimento', 'data de pagamento(pode ser nulo)', 'status('pendente', 'pago', 'atrasado', 'falha', 'estornado')');

-- SELECT remocao_global('parcela', 'id da parcela', 'data de vencimento');

-- Testada e validada
SELECT insercao_global('parcela', '1', '99.00', '2024-04-10', '2024-04-10', 'pago');
SELECT insercao_global('parcela', '1', '99.00', '2024-05-10', NULL, 'pendendte');
SELECT insercao_global('parcela', '2', '149.50', '2024-04-20', '2024-04-20', 'pago');
SELECT insercao_global('parcela', '2', '149.50', '2024-05-20', NULL, 'pendendte');
SELECT insercao_global('parcela', '3', '19.99', '2024-02-15', '2024-02-15', 'pago');
SELECT insercao_global('parcela', '3', '19.99', '2024-03-15', '2024-03-16', 'pago');
SELECT insercao_global('parcela', '4', '79.00', '2024-06-20', NULL, 'pendendte');
SELECT insercao_global('parcela', '5', '199.90', '2024-05-25', NULL, 'pendendte');
SELECT insercao_global('parcela', '6', '89.99', '2024-06-15', NULL, 'pendendte');
