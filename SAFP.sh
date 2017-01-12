#!/bin/bash

# Note: Gera um UUID para o filtro do relatório! By Questor
UUID=$(python -c 'import uuid; print uuid.uuid1().hex')

# Note: Seta o watching! By Questor
echo "Setting the watching! Please do not use \"Ctr+c\"!"
echo "Waiting the process to terminate itself after you closing the target application!"
auditctl -a exit,always -F arch=b64 $SYS_CALL_W -F dir="${DIR_WATCH}" -k $UUID

# Note: Aguarda 3 segundos até começar a monitorar o processo da aplicação
# alvo (se está rodando). Se a aplicação for encerrada o watching será 
# removido! By Questor
echo "Waiting for process to start to monitoring if it is running!"
sleep 3;

# Note: Monitora o processo da aplicação alvo! By Questor
echo "Monitoring the process!"
EXE_PIDOF=$(pidof $EXE_NAME)
EXE_PIDOF_HOLDER=$EXE_PIDOF
while [ -n "$EXE_PIDOF" ] ; do
    sleep 3;
    EXE_PIDOF=$(pidof $EXE_NAME)
done

echo "The process is stopped!"
if [ -n "$EXE_PIDOF_HOLDER" ] ; then

    FLS_ARRAY_LOG=()
    HAVE_EXISTING_DATA_LOG_FILE=0
    EXISTING_DATA_LOG_FILE=""

    # Note: Recupera o arquivo de log se houver! By Questor
    if [ ${UP_EXISTING_DATA_LOG_FILE} -eq 1 ] ; then
        EXISTING_DATA_LOG_FILE=$(find "$SCRIPT_DIR" -maxdepth 1 -type f -name "SAFP*" -and -name "*C*" -and -name "*U*" -and -name "*.LOG")
        if [ -f "${EXISTING_DATA_LOG_FILE}" ] ; then
            echo  "Opening and processing the existing data log file!"
            EXISTING_DATA_LOG_FILE_TXT=$(cat "$EXISTING_DATA_LOG_FILE")
            readarray -t FLS_ARRAY_LOG <<<"$EXISTING_DATA_LOG_FILE_TXT"
            HAVE_EXISTING_DATA_LOG_FILE=1
        fi
    fi

    echo  "Processing data!"

    FLS_ARRAY=()

    # Note: Checa os eventos relativos a aplicação alvo e formata a saída! By Questor
    FLS_ARRAY=$(ausearch -i $SYS_CALL_S -x "$EXE_NAME_FILTER" -k $UUID | grep "$DIR_WATCH" | grep "mode=file" | grep "name=" | grep "type=" | grep "msg=" | grep "item=" | awk -F' name=' '{print $2}' | awk -F' inode=' '{print $1}')

    # Note: Transforma a saída em array! By Questor
    readarray -t FLS_ARRAY <<<"$FLS_ARRAY"

    # Note: Remove ítens repetidos para ganhar desempenho na próxima remoção! By Questor
    readarray -t FLS_ARRAY < <(printf '%s\n' "${FLS_ARRAY[@]}" | sort -u)

    if [ ${HAVE_EXISTING_DATA_LOG_FILE} -eq 1 ] ; then

        # Note: Junta o array do log com o array das ocorrências atual! By Questor
        FLS_ARRAY=("${FLS_ARRAY[@]}" "${FLS_ARRAY_LOG[@]}")

        # Note: Remove ítens repetidos! By Questor
        readarray -t FLS_ARRAY < <(printf '%s\n' "${FLS_ARRAY[@]}" | sort -u)
    fi

    # Note: Forma o conteúdo em string do log acrescentando quebras de
    # linha! By Questor
    FILE_OUTPUT=""
    NEW_LINE=''
    for ITEM_NOW in "${FLS_ARRAY[@]}"
    do
        FILE_OUTPUT="$FILE_OUTPUT$NEW_LINE$ITEM_NOW"
        NEW_LINE=$'\n'
    done

    # Note: Datas em fomato ISO para formar o nome do log! By Questor
    DATE_TIME_NOW_C=$(date +"%Y-%m-%dT%H-%M-%S")
    DATE_TIME_NOW_U=$(date +"%Y-%m-%dT%H-%M-%S")

    FILE_NAME=""
    if [ ${HAVE_EXISTING_DATA_LOG_FILE} -eq 1 ] ; then
        FILE_NAME=$(basename "$EXISTING_DATA_LOG_FILE")
        FILE_NAME=$(echo "$FILE_NAME" | awk -F'C' '{print $1}')
        FILE_NAME="${FILE_NAME}C${DATE_TIME_NOW_U}U.LOG"
    else
        FILE_NAME="SAFP${DATE_TIME_NOW_C}C${DATE_TIME_NOW_U}U.LOG"
    fi

    # Note: Cria um novo arquivo de log. Se houver arquivo de log
    # anterior o seu conteúdo irá para esse novo arquivo juntamente
    # com o conteúdo da monitoração atual! By Questor
    printf "$FILE_OUTPUT" > "${SCRIPT_DIR}/${FILE_NAME}"

    if [ ${HAVE_EXISTING_DATA_LOG_FILE} -eq 1 ] ; then
        rm -f "$EXISTING_DATA_LOG_FILE"
    fi

    echo "Data obtained!"

fi

# Note: Remove o watching! By Questor
echo "Removing watching!"
auditctl -D -k $UUID > /dev/null 2>&1

echo "Thanks! =D By Questor"