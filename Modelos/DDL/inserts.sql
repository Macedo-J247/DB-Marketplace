-- Desenvolvedores
SELECT cadastrar_desenvolvedor('Ana Silva', 'ana.silva@dev.com');
SELECT cadastrar_desenvolvedor('Jose Santos', 'jose.santos@dev.com');
SELECT cadastrar_desenvolvedor('Wadson Dias', 'wadson.dias@dev.com');
SELECT cadastrar_desenvolvedor('Tiago Elias', 'tiago.elias@dev.com');

-- Categorias
-- Preferencialmente softwares
SELECT cadastrar_categoria('Desktop', 'Programas locais com interface gráfica');
SELECT cadastrar_categoria('Web', 'Sistemas acessados via navegador com funcionalidades');
SELECT cadastrar_categoria('Produtividade', 'Ferramenta para organização, escrita ou tarefas');
SELECT cadastrar_categoria('Design', 'Criação e edição de conteúdo visual ou audiovisual');
-- Preferencialmente API's
SELECT cadastrar_categoria('Autenticação', 'Ferramentas de login e controle de acesso entre sistemas');
SELECT cadastrar_categoria('Mensageria', 'Programas de envio de mensagens por SMS, e-mail ou chat');
SELECT cadastrar_categoria('Dados Públicos', 'Sistemas de acesso a informações abertas de instituições');
SELECT cadastrar_categoria('Redes Sociais', 'Integração com plataformas sociais');
