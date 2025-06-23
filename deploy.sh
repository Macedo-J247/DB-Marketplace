#!/bin/bash

# Este script automatiza a implantação do schema do banco de dados do marketplace.
# Certifique-se de substituir 'seu_usuario', 'sua_senha' e 'seu_banco_de_dados' pelos seus dados.

# --- Configurações do Banco de Dados ---
DB_USER="postgres"          # <--- SUBSTITUA PELO SEU USUÁRIO DO POSTGRESQL
DB_PASS="1112" # <--- SUBSTITUA PELA SENHA DO SEU USUÁRIO DO POSTGRESQL
DB_NAME="marketplace_db"   # <--- SUBSTITUA PELO NOME DO SEU BANCO DE DADOS (EX: marketplace_db)
DB_HOST="localhost"            # Host do PostgreSQL (geralmente localhost)
DB_PORT="5432"                 # Porta do PostgreSQL (padrão é 5432)

# Exporta a variável de ambiente PGPASSWORD
# Este é o método recomendado para passar a senha em scripts,
# pois ela não aparece na linha de comando diretamente.
export PGPASSWORD="$DB_PASS"

# --- Função para Executar um Arquivo SQL ---
execute_sql_file() {
    local file_path=$1
    echo "--> Executando: $file_path"
    # psql usará automaticamente a PGPASSWORD exportada
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file_path"
    # Verifica se o comando psql falhou
    if [ $? -ne 0 ]; then
        echo "!!! ERRO: Falha ao executar $file_path. Abortando a implantação."
        # Desdefine a variável de ambiente PGPASSWORD antes de sair para segurança
        unset PGPASSWORD
        exit 1 # Sai do script com código de erro
    fi
}

echo "Iniciando a implantação do schema do Marketplace com a estrutura tabela-centrada..."
echo "Conectando ao banco de dados: '$DB_NAME' como usuário: '$DB_USER'..."

# --- Ordem de Execução ---

# 0. Executar os ENUMs (Precisam ser criados antes das tabelas e funções que os usam)
echo ""
echo "--- 0. Executando Definição de Tipos ENUM ---"
execute_sql_file database/types/enum_types.sql

# 1. Executar o DDL Principal (Todas as Tabelas)
echo ""
echo "--- 1. Executando Definição de Dados (DDL) das Tabelas ---"
execute_sql_file database/ddl/marketplace.sql

# 2. Executar Funções (agrupadas por tabela)
echo ""
echo "--- 2. Executando Funções (PL/pgSQL) ---"
execute_sql_file database/produto/functions/produto_functions.sql
execute_sql_file database/parcela/functions/parcela_functions.sql
execute_sql_file database/avaliacao/functions/avaliacao_functions.sql
execute_sql_file database/assinatura/functions/assinatura_functions.sql
# Adicione aqui todos os outros arquivos de funções por tabela que você criar

# 3. Executar os Triggers (agrupados por tabela)
echo ""
echo "--- 3. Executando Triggers ---"
execute_sql_file database/produto/triggers/produto_triggers.sql
execute_sql_file database/parcela/triggers/parcela_triggers.sql
execute_sql_file database/avaliacao/triggers/avaliacao_triggers.sql
execute_sql_file database/assinatura/triggers/assinatura_triggers.sql
# Adicione aqui todos os outros arquivos de triggers por tabela que você criar

echo ""
echo "Implantação do schema do Marketplace concluída com sucesso!"

# Desdefine a variável de ambiente PGPASSWORD no final do script para segurança
unset PGPASSWORD
