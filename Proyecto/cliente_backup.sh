#!/bin/bash

ERROR_PARAMETROS=90
ERROR_PATRON=91
ERROR_LINEA=92
ERROR_DIRECTORIO=93
ERROR_PING=94
ERROR_HORAS=95

EXITO=0

if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi

apt-get -y install rsync > /dev/null

FICHERO_PERFIL=$1

numero_lineas=$(cat $FICHERO_PERFIL | wc -l)

if [ $numero_lineas -ne 4 ]
then
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener 4 lineas"
    exit $ERROR_LINEA
fi 

counter=1
while read line
do
    numero_palabras=$(echo $line | wc -w)

    if [ $numero_palabras -ne 1 ]
    then 
	echo "[PATRON DE LINEA]: El patron de la linea $line es incorrecto"
	exit $ERROR_PATRON
    fi

    if [ $counter -eq 1 ]
    then
	ruta_del_directorio_del_que_se_desea_hacer_backup=$line
	if [ ! -b $ruta_del_directorio_del_que_se_desea_hacer_backup ]
	then
	    echo "[DIRECTORIO DEL QUE SE DESEA HACER EL BACKUP]: No existe el directorio $ruta_del_directorio_del_que_se_desea_hacer_backup"
	    exit $ERROR_DIRECTORIO
	fi
    fi

    if [ $counter -eq 2 ]
    then
	maquina=$line
	ping -c $NUMERO_PING $maquina

	if [ $? -ne 0 ]
	then
	    echo "[PING]: No tenemos acceso a la máquina: $maquina"
	    exit $ERROR_PING
	fi
    fi

    if [ $counter -eq 3 ]
    then
	ruta_del_directorio_destino_del_backup_en_horas=$line
	if [ ! -b $ruta_del_directorio_destino_del_backup_en_horas ]
	then
	    echo "[DIRECTORIO DESTINO PARA HACER EL BACKUP]: No existe el directorio $ruta_del_directorio_destino_del_backup_en_horas"
	    exit $ERROR_DIRECTORIO
	fi
	
	#ssh $maquina '/tmp/mount.sh /tmp/mount.conf RES=$?; rm /tmp/mount.sh; rm /tmp/mount.conf; exit $RES' &> /dev/null
    fi

    if [ $counter -eq 4 ]
    then
	horas=$line
	if [ ! $horas -ge 0 -a $horas -le 24 ]
	then
	    echo "[Horas]: El numero de horas no es correcto"
	    exit $ERROR_HORAS
	fi
    fi	
    let counter+=1
done < $FICHERO_PERFIL

#aqui va el mandato
rsync $ruta_del_directorio_del_que_se_desea_hacer_backup $ruta_del_directorio_destino_del_backup_en_horas

