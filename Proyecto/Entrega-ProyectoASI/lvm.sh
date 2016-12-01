#!/bin/bash

ERROR_PARAMETROS=30
ERROR_PATRON=31
ERROR_LINEA=32
ERROR_DISPOSITIVO=33

if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi

apt-get -y install lvm2 > /dev/null 

FICHERO_PERFIL=$1

numero_lineas=$(cat $FICHERO_PERFIL | wc -l)

if [ $numero_lineas -lt 3 ]
then
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener más de 2 lineas"
    exit $ERROR_LINEA
fi

counter=1
while read line
do
    numero_palabras=$(echo $line | wc -w)

    if [ $counter -eq 1 -a $numero_palabras -eq 1 ] 
    then
	grupo=$line
    elif [ $counter -eq 2 -a $numero_palabras -gt 1 ]
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
	    
	lvmdiskscan
	pvcreate $devices
	pvdisplay
	vgcreate $grupo $devices
	vgdisplay
	    
    elif [ $counter -ge 3 -a $numero_palabras -eq 2 ]
    then
	words=($line)

	nombre_del_volumen=${words[0]}
	tamanho_del_volumen=${words[1]}
	    
    #HAY que comprobar el tamaño del volumen

	lvcreate --name $nombre_del_volumen --size $tamanho_del_volumen $grupo
 	      
    else
	echo "[PATRON DE LINEA]: El patron de la linea $line es incorrecto"
	exit $ERROR_PATRON
    fi
	
    let counter+=1
done < $FICHERO_PERFIL
