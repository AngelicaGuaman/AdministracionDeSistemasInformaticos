#!/bin/bash

ERROR_PARAMETROS=80
ERROR_PATRON=81
ERROR_LINEA=82
ERROR_DIRECTORIO=83

if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi

apt-get -y install rsync > /dev/null

FICHERO_PERFIL=$1

numero_lineas=$(cat $FICHERO_PERFIL | wc -l)

if [ $numero_lineas -eq 0 ]
then
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener una linea"
    exit $ERROR_LINEA
fi

while read line
do
    numero_palabras=$(echo $line | wc -w)

    if [ $numero_palabras -ne 1 ]
    then
	echo "[PATRON DE LINEA]: El patron de la linea $line es incorrecto"
	exit $ERROR_PATRON
    fi

    directorio_donde_se_realiza_el_backup=$line
    if [ -d $directorio_donde_se_realiza_el_backup ]
    then
	if [ $(ls $directorio_donde_se_realiza_el_backup | wc -l) -ne 0 ]
	then
	    echo "[DIRECTORIO BACKUP]: El directorio $directorio_donde_se_realiza_el_backup donde se quiere hacer el backup está ocupado"
	    exit $ERROR_DIRECTORIO
	fi
	#aqui va el mandato
    else
	mkdir $directorio_donde_se_realiza_el_backup
	#aqui va el mandato
    fi
 
done < $FICHERO_PERFIL

