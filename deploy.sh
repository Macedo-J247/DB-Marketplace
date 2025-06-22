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

echo "Iniciando a implantação do schema do Marketplace..."
echo "Conectando ao banco de dados: '$DB_NAME' como usuário: '$DB_USER'..."

# --- Ordem de Execução ---

# 0. Executar os ENUMs (Precisam ser criados antes das tabelas e funções que os usam)
echo ""
echo "--- 0. Executando Definição de Tipos ENUM ---"
execute_sql_file ddl/enum_types.sql

# 1. Executar o DDL (Definição das Tabelas)
echo ""
echo "--- 1. Executando Definição de Dados (DDL) ---"
execute_sql_file ddl/marketplace.sql

# 2. Executar as Funções (Precisam existir antes dos Triggers)
echo ""
echo "--- 2. Executando Funções (PL/pgSQL) ---"
execute_sql_file functions/produtos/func_validar_preco_produto.sql
execute_sql_file functions/produtos/func_atualizar_data_atualizacao_produto.sql
execute_sql_file functions/parcelas/func_registrar_data_pagamento_parcela.sql
execute_sql_file functions/avaliacoes/func_validar_nota_avaliacao.sql
execute_sql_file functions/assinaturas/func_verificar_status_produto_assinatura.sql
# Adicione aqui todos os outros arquivos de função que você criar

# 3. Executar os Triggers (Dependem das Funções e Tabelas)
echo ""
echo "--- 3. Executando Triggers ---"
execute_sql_file triggers/produtos/trg_validar_preco_produto.sql
execute_sql_file triggers/produtos/trg_produto_data_atualizacao.sql
execute_sql_file triggers/parcelas/trg_parcela_data_pagamento.sql
execute_sql_file triggers/avaliacoes/trg_validar_nota_avaliacao.sql
execute_sql_file triggers/assinaturas/trg_impedir_assinatura_produto_inativo.sql
# Adicione aqui todos os outros arquivos de trigger que você criar

echo ""
echo "Implantação do schema do Marketplace concluída com sucesso!"

# Desdefine a variável de ambiente PGPASSWORD no final do script para segurança
unset PGPASSWORD
