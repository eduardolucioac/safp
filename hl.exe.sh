#!/bin/bash

# Note: Para gerar o report e monitorar os eventos precisamos de credenciais
# de root! By Questor
sudo su <<'EOF'
# Note: Nome do executável a ser monitorado. Esse valor será usado no 
# filtro! By Questor
EXE_NAME_FILTER="wineserver"
# Note: Nome do executável a ser monitorado o status durante a execução 
# do script! By Questor
EXE_NAME="hl.exe"
# Note: Diretório a ser monitorado (recursivo)! By Questor
DIR_WATCH="/home/eduardo/Data/Games/Counter Strike 1.6 RE-MOD v1.5.0b/Counter Strike 1.6 RE-MOD"
# Note: Define se deve ser criado um novo arquivo de log a cada execução
# ou se deve ser incrementado arquivo de que log caso já exista! By Questor
UP_EXISTING_DATA_LOG_FILE=1
# Note: Tipo de chamada para o sistema que se quer monitorar! Use 
# vazio para monitorar tudo! Use o modelo comentado abaixo para 
# monitorar apenas abertura! By Questor
# SYS_CALL_W="-S open"
SYS_CALL_W=""
# Note: Tipo de chamada para o sistema que se quer usar como filtro 
# ao gerar o relatório! Use vazio para obter tudo! Use o modelo 
# comentado abaixo para filtrar apenas abertura! By Questor
# SYS_CALL_S="-sc open"
SYS_CALL_S=""
# Note: Chamada ao script que executa o processo. Esse script deve estar na
# mesma pasta do script atual! By Questor
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "$SCRIPT_DIR/SAFP.sh" &
EOF

# Note: Chamada à aplicação que será monitorada. O script "SAFP.sh" 
# irá parar automaticamente quando à aplicação monitorada (informada 
# em "EXE_NAME") for encerrada! By Questor
. "/home/eduardo/Data/Games/Counter Strike 1.6 RE-MOD v1.5.0b/Resource/CS16REMOD.sh"
