#!/bin/bash

ERROR_PARAMETROS=10
ERROR_PATRON=11
ERROR_NUMERO_LINEA=12
ERROR_DISPOSITIVO=13
ERROR_MONTAJE=14

SISTEMA_DE_FICHERO=ext4

if [ $# -ne 2 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi

FICHERO_PERFIL=$1

numero_lineas=$(cat $FICHERO_PERFIL | wc -l)

if [ $numero_lineas -ne 1 ]
then 
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener 2 lineas"
    exit $ERROR_NUMERO_LINEA
fi 

counter=1
while read line
do
    numero_palabras=$(echo $line | wc -w)
    
    if [ $numero_palabras -gt 1 ]
    then
	echo "[PATRON DE LINEA]: La linea tiene $numero_palabras palabras y debe tener 1 palabra"
	exit $ERROR_PATRON
    fi
    
    echo "El patron de la linea $line es correcto"

    if [ $counter -eq 1 ] 
    then
	dispositivo=$line
	if [ ! -b $dispositivo ]
	then
	    echo "[DISPOSITIVO]: No existe el dispositivo $dispositivo"
	    exit $ERROR_DISPOSITIVO
	fi

	echo "El dispositivo si existe, procedemos a comporbar el directorio de montaje"
    else
	directorio_de_montaje=$line
	if [ ! -d $directorio_de_montaje ]
	then
	    mkdir $directorio_de_montaje
	    echo "Como no existe el directorio procedemos a crearlo"
	elif [ $(ls $directorio_de_montaje | wc -l) -ge 0 ]
	then
	    echo "[MONTAJE]: No se puede realizar el montaje, porque el dispositivo $directorio_de_montaje está siendo utilizado"
	    exit $ERROR_MONTAJE
	fi
    fi
    let counter+=1
 done < $FICHERO_PERFIL

echo "$dispositivo $directorio_de_montaje $SISTEMA_DE_FICHERO auto,exec,rw,user 0 2" >> /etc/fstab
mount -t $SISTEMA_DE_FICHERO $dispositivo $directorio_de_montaje

