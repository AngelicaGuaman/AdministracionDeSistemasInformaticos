#!/bin/bash
 
ERROR_PARAMETROS=70
ERROR_PATRON=71
ERROR_LINEA=72
ERROR_DISPOSITIVO=73
ERROR_PING=74
 
NUMERO_PING=2
 
EXITO=0
 
if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi
 
apt-get -y install nfs-common > /dev/null
 
FICHERO_PERFIL=$1
 
numero_lineas=$(cat $FICHERO_PERFIL | wc -l)
 
if [ $numero_lineas -eq 0 ]
then
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener más de una linea"
    exit $ERROR_LINEA
fi
 
while read line
do
    numero_palabras=$(echo $line | wc -w)
 
    if [ ! $numero_palabras -ne 3 ]
    then
    echo "[PATRON DE LINEA]: El patron de la linea $line es incorrecto"
    exit $ERROR_PATRON
    fi
 
    words=($line)
 
    maquina=${words[0]}
    ruta_de_directorio_remoto=${words[1]}
    punto_de_montaje=${words[2]}
 
    ping -c $NUMERO_PING $maquina
 
    if [ $? -ne 0 ]
    then
    echo "[PING]: No tenemos acceso a la máquina: $maquina"
    exit $ERROR_PING
    fi
 
    if [ ! -b $ruta_de_directorio_remoto ]
    then
    echo "[DISPOSITIVO]: No existe el dispositivo $ruta_de_directorio_remoto"
    exit $ERROR_DISPOSITIVO
    fi
 
    if [ ! -b $punto_de_montaje ]
    then
    echo "[DISPOSITIVO]: No existe el dispositivo $punto_de_montaje"
    exit $ERROR_DISPOSITIVO
    fi
	
	#Instalación de los paquetes necesarios
    apt-get install portmap nfs-common > /dev/null
	/etc/init.d/portmap restart
    
	#mount -t nfs ip_del_servidor:ruta_del_directorio_remoto punto_de_montaje
	echo $maquina + ":" + $ruta_del_directorio_remoto + " " + $punto_de_montaje + " " + "rw,hard,intr 0 0" >> /etc/fstab
     
	#Recargar el fichero /etc/fstab
	mount -a
done < $FICHERO_PERFIL