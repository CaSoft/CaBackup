#!/bin/bash
#
# ==== CaBackup ====
#
# Script para fazer backup simples, na base da cópia usando o cp
# Ele também faz o backup do MySQL
#
# Autor: CaSoft Tecnologia - Evaldo Junior <junior@casoft.info>
#
# Versão 1.0 - 06 de Out. de 2011
# Versão 1.1 - 14 de Out. de 2011
#   - Backup do MySQL agora é opcional
#   - Montagem de HD externa é opcional
#   - Agora ele gera o log em um arquivo, opcional
#   - Agora exibe o primeiro nível da estrutura dos diretórios sendo copiados
#
# Licença: GNU GPL v3 (http://www.gnu.org/licenses/gpl-3.0.txt)
#
########################################
# Config                               #
# Faça as adaptações do script aqui    #
########################################
#
# Opção de saída na tela, use 0 para não ter saída na tela
#
SAIDA_NA_TELA=1
#
# Dados do MySQL
# Deixe o HOST em branco para não copiar o MySQL
#
MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASS="root"
#
# Origens do backup, quais diretórios
# serão copiados?
# Separe os diretórios com espaços
# isso é um array do bash, siga o padrão
#
# !!! ATENÇÃO !!!
# Não deixe uma barra ao final do caminho!
#
ORIGENS=( "/opt" "/var/www" )
#
# Disco externo - Deixe em branco caso não use um disco externo
#
DISCO_EXTERNO="/dev/sdb1"
#
# Ponto de montagem - Deixe em branco caso não use um disco externo
#
PONTO_MONTAGEM="/mnt/backup"
#
# Onde o backup será gravado?
# Sempre DEIXE uma barra no nome do diretório
#
DESTINO="/mnt/backup/backup"
#
# Arquivo para gravar o log. Deixa em branco para não ter log.
#
ARQUIVO_LOG="/tmp/meulog.txt"
#
########################################
# Fim do Config                        #
# Só altere daqui para baixo se souber #
# o que está fazendo                   #
########################################
#
# Esta função exibe a mensagem na tela e grava o log
#
function log_mensagem {
    if [ ! $SAIDA_NA_TELA -eq 0 ]
    then
        echo $1
    fi
    if [ -n "$ARQUIVO_LOG" ]
    then
        echo $1 >> "$ARQUIVO_LOG"
    fi
}
#
# Data do backup
#
DATA=`date +%Y%m%d`
#
# Agora começa
#
log_mensagem "Iniciando o backup de $DATA"
#
# Foi definido um disco externo? Então monta
#
if [ -n "$DISCO_EXTERNO" ]
then
    log_mensagem "Montando disco externo"
    mount "$DISCO_EXTERNO" "$PONTO_MONTAGEM"
fi
#
# Auxiliares
#
BIN_MYSQLDUMP=`which mysqldump`
#
# O diretório de destino existe? Não? Então crie-o, ué.
if [ ! -d "$DESTINO$DATA" ]
then
    mkdir -p "$DESTINO$DATA"
fi
#
# Começando o backup!
#
for origem in "${ORIGENS[@]}"
do
    NOME_DIR=${origem##*/}
    DEST="$DESTINO$DATA/$NOME_DIR"
    for sub in $(ls "$origem")
    do
        log_mensagem "Copiando $origem/$sub..."
        cp -r "$origem/$sub" "$DEST"
        log_mensagem "$origem/$sub copiado"
    done
done

#
# Agora vamos ao MySQL
#
if [ -n $MYSQL_HOST ]
then
    log_mensagem "Iniciando o backup do MySQL"
    $BIN_MYSQLDUMP -u "$MYSQL_USER" -h "$MYSQL_HOST" --password="$MYSQL_PASS" --all-databases > "$DESTINO$DATA/backup_mysql.sql"
    log_mensagem "Backup do MySQL completo"
fi

#
# Tem que desmontar?
#
if [ -n "$DISCO_EXTERNO" ]
then
    log_mensagem "Desmontando o externo"
    umount "$DESTINO"
fi

log_mensagem "Fim do script de backup"
