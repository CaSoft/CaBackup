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
#
# Licença: GNU GPL v3 (http://www.gnu.org/licenses/gpl-3.0.txt)
#
########################################
# Config                               #
# Faça as adaptações do script aqui    #
########################################
#
# Dados do MySQL
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
ORIGENS=( "/opt/" "/var/www/" )
#
# Disco externo
#
DISCO_EXTERNO="/dev/sdb1"
#
# Onde o backup será gravado?
#
DESTINO="/mnt/backup/"
#
########################################
# Fim do Config                        #
# Só altere daqui para baixo se souber #
# o que está fazendo                   #
########################################
#
# Montando o externo
#
mount "$DISCO_EXTERNO" "$DESTINO"
#
# Auxiliares
#
BIN_MYSQLDUMP=`which mysqldump`
DATA=`date +%Y%m%d`
if [ ! -d "$DESTINO$DATA" ]
then
    mkdir "$DESTINO$DATA"
fi
#
# Começando o backup!
#
for origem in "${ORIGENS[@]}"
do
    echo "Copiando $origem..."
    cp -r "$origem" "$DESTINO$DATA"
    echo "$origem copiado"
done

#
# Agora vamos ao MySQL
#
echo "Iniciando o backup do MySQL"
$BIN_MYSQLDUMP -u "$MYSQL_USER" -h "$MYSQL_HOST" --password="$MYSQL_PASS" --all-databases > "$DESTINO$DATA/backup_mysql.sql"
echo "Backup do MySQL completo"

echo "Desmontando o externo"
umount "$DESTINO"

echo "Fim do script de backup"
