-- Usuário comum
CREATE ROLE usuario_comum WITH LOGIN PASSWORD 'senha_usuario_comum';

-- Cliente
CREATE ROLE cliente WITH LOGIN PASSWORD 'senha_cliente';

-- Desenvolvedor
CREATE ROLE desenvolvedor WITH LOGIN PASSWORD 'senha_desenvolvedor';

-- Admin do marketplace
CREATE ROLE admin_marketplace WITH LOGIN PASSWORD 'senha_@admin';

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

-- Permissões básicas para leitura
GRANT CONNECT ON DATABASE neondb TO usuario_comum, cliente, desenvolvedor, admin_marketplace;
GRANT USAGE ON SCHEMA public TO usuario_comum, cliente, desenvolvedor, admin_marketplace;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_comum, cliente, desenvolvedor, admin_marketplace;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO usuario_comum, cliente, desenvolvedor, admin_marketplace;

-- Cliente: pode inserir/alterar o que for vinculado ao usuário
GRANT INSERT, UPDATE ON suporte TO cliente;
GRANT INSERT, UPDATE ON avaliacao TO cliente;
GRANT INSERT, UPDATE ON assinatura TO cliente;
GRANT INSERT, UPDATE ON parcela TO cliente;
GRANT INSERT, UPDATE ON usuario TO cliente;

-- Desenvolvedor: pode inserir/alterar seus produtos e versões
GRANT INSERT, UPDATE ON produto TO desenvolvedor;
GRANT INSERT, UPDATE ON versao TO desenvolvedor;
GRANT INSERT, UPDATE ON api TO desenvolvedor;
GRANT INSERT, UPDATE ON software TO desenvolvedor;
GRANT INSERT, UPDATE ON desenvolvedor TO desenvolvedor;

-- Admin: acesso total
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_marketplace;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_marketplace;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO admin_marketplace;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO admin_marketplace;
