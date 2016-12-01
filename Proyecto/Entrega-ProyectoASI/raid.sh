#!/bin/bash

ERROR_PARAMETROS=20
ERROR_PATRON=21
ERROR_LINEA=22
ERROR_DISPOSITIVO=23
ERROR_NIVEL_RAID=24

EXITO=0

if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi

apt-get -y install mdadm > /dev/null

FICHERO_PERFIL=$1

numero_lineas=$(cat $FICHERO_PERFIL | wc -l)

if [ $numero_lineas -ne 3 ]
then
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener 3 lineas"
    exit $ERROR_LINEA
fi

counter=1
while read line
do
    numero_palabras=$(echo $line | wc -w)

    if [ $counter -eq 1 -a $numero_palabras -eq 1 ] 
    then
	dispositivo=$line

        #ESTE PUNTO HAY QUE VERLO QUE NO SE SI HAYA QUE CREAR EL FICHERO
    elif [ $counter -eq 2 -a $numero_palabras -eq 1 ]
    then 
	nivel_de_raid=$line
	
	if [ $nivel_de_raid -gt 5 ]
	then
	    echo "[RAID]: El nivel de raid $nivel_de_raid es incorrecto"
	    exit $ERROR_NIVEL_RAID
	fi
	    
    elif [ $counter -eq 3 -a $numero_palabras -ge 1 ]
    then
	devices=$line
	numero_devices=$(echo $line | wc -w)
	for device in $devices
	do
	    if [ ! -b $device ]
	    then
		echo "[DISPOSITIVO]: No existe el dispositivo $device"
		exit $ERROR_DISPOSITIVO
	    fi
	done
    else
	echo "[PATRON DE LINEA]: El patron de la linea $line es incorrecto"
	exit $ERROR_PATRON
    fi
	
    let counter+=1

done < $FICHERO_PERFIL

mdadm --create $dispositivo --level=$nivel_de_raid --raid-devices=$numero_devices $devices

 