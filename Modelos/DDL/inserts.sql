-- Desenvolvedores
-- Testada e validada
SELECT insercao_global('desenvolvedor', 'Ana Silva', 'ana.silva@dev.com');
SELECT insercao_global('desenvolvedor', 'Jose Santos', 'jose.santos@dev.com');
SELECT insercao_global('desenvolvedor', 'Wadson Dias', 'wadson.dias@dev.com');
SELECT insercao_global('desenvolvedor', 'Tiago Elias', 'tiago.elias@dev.com');
SELECT insercao_global('desenvolvedor', 'Bruna Castro', 'bruna.castro@dev.com');
SELECT insercao_global('desenvolvedor', 'Lucas Almeida', 'lucas.almeida@dev.com');

-- Categorias
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
-- Testada e validada
SELECT insercao_global('usuario', 'Carlos Lima', 'carlos.lima@cliente.com', '123senha', 'cliente');
SELECT insercao_global('usuario', 'Mariana Dias', 'mariana.dias@cliente.com', '456senha', 'cliente');
SELECT insercao_global('usuario', 'João Pedro', 'joao.pedro@admin.com', 'admin123', 'administrador');
SELECT insercao_global('usuario', 'Lucas Dev', 'lucas.dev@dev.com', 'senha456', 'desenvolvedor');
SELECT insercao_global('usuario', 'Paula Souza', 'paula.souza@cliente.com', 'senha789', 'cliente');
SELECT insercao_global('usuario', 'Renato Braga', 'renato.braga@cliente.com', 'pass1234', 'cliente');

-- Tipos de Pagamento
-- Testada e validada
SELECT insercao_global('tipo_pagamento', 'cartao');
SELECT insercao_global('tipo_pagamento', 'boleto');
SELECT insercao_global('tipo_pagamento', 'pix');

-- Produtos
SELECT insercao_global('produto', '1', '1', 'PhotoMaster', 'Editor de imagens profissional', '299.99', 'software', 'ativo', '2024-01-10');
SELECT insercao_global('produto', '2', '2', 'NoteApp', 'Aplicativo de anotações rápido e prático', '19.99', 'software', 'ativo', '2024-02-05');
SELECT insercao_global('produto', '3', '5', 'AuthX', 'API de autenticação segura com OAuth2', '99.00', 'api', 'ativo', '2024-03-01');
SELECT insercao_global('produto', '4', '6', 'SendQuick', 'API de envio de SMS e emails', '149.50', 'api', 'ativo', '2024-04-15');
SELECT insercao_global('produto', '1', '4', 'DesignFlow', 'Editor gráfico intuitivo para design gráfico', '79.00', 'software', 'revisao', '2024-05-10');

-- Softwares (ligados aos produtos 1, 2 e 5)
SELECT insercao_global('software', '1', 'licença perpétua');
SELECT insercao_global('software', '2', 'mensal');
SELECT insercao_global('software', '5', 'anual');

-- APIs (ligadas aos produtos 3 e 4)
SELECT insercao_global('api', '3', 'https://api.authx.com/v1');
SELECT insercao_global('api', '4', 'https://api.sendquick.io/v1');

-- Versões
SELECT insercao_global('versao', '1', '1.0', '2024-01-15');
SELECT insercao_global('versao', '1', '1.1', '2024-03-10');
SELECT insercao_global('versao', '3', 'v1', '2024-03-05');
SELECT insercao_global('versao', '4', 'v1.0', '2024-04-20');
SELECT insercao_global('versao', '5', 'beta', '2024-05-15');

-- Avaliações
SELECT insercao_global('avaliacao', '1', '1', '4.5', '2024-03-01');
SELECT insercao_global('avaliacao', '2', '2', '5.0', '2024-03-05');
SELECT insercao_global('avaliacao', '1', '3', '4.0', '2024-04-01');
SELECT insercao_global('avaliacao', '5', '4', '4.2', '2024-05-01');

-- Suportes
SELECT insercao_global('suporte', '1', '1', '1', 'erro', 'Erro ao abrir imagem', 'aberto');
SELECT insercao_global('suporte', '2', '3', '3', 'duvida', 'Como configurar OAuth?', 'em andamento');
SELECT insercao_global('suporte', '1', '4', '4', 'melhoria', 'Sugestão de integração com WhatsApp', 'aberto');
SELECT insercao_global('suporte', '5', '5', '5', 'erro', 'Erro ao exportar PNG', 'resolvido');

-- Assinaturas
SELECT insercao_global('assinatura', '1', '3', '1', '2024-04-01', NULL, 'ativa');
SELECT insercao_global('assinatura', '2', '4', '3', '2024-04-10', NULL, 'ativa');
SELECT insercao_global('assinatura', '5', '1', '2', '2024-02-01', '2024-03-01', 'expirada');
SELECT insercao_global('assinatura', '6', '5', '1', '2024-05-20', NULL, 'ativa');

-- Parcelas
SELECT insercao_global('parcela', '1', '99.00', '2024-04-10', '2024-04-10', 'pago');
SELECT insercao_global('parcela', '1', '99.00', '2024-05-10', NULL, 'pendendte');
SELECT insercao_global('parcela', '2', '149.50', '2024-04-20', '2024-04-20', 'pago');
SELECT insercao_global('parcela', '2', '149.50', '2024-05-20', NULL, 'pendendte');
SELECT insercao_global('parcela', '3', '19.99', '2024-02-15', '2024-02-15', 'pago');
SELECT insercao_global('parcela', '3', '19.99', '2024-03-15', '2024-03-16', 'pago');
SELECT insercao_global('parcela', '4', '79.00', '2024-06-20', NULL, 'pendendte');
