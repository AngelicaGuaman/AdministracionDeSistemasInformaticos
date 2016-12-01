#!/bin/bash
 
ERROR_PARAMETROS=60
ERROR_PATRON=61
ERROR_LINEA=62
ERROR_DIRECTORIO_EXPORTADO=63
 
if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi
 
FICHERO_PERFIL=$1
 
numero_lineas=$(cat $FICHERO_PERFIL | wc -l)
 
if [ $numero_lineas -eq 0 ] 
then
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener mas de una linea"
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
 
    ruta_directorio_exportado=$line
     
    if [ ! -d $ruta_directorio_exportado]
	then
		echo "[DIRECTORIO_EXPORTADO]: No existe la ruta del directorio exportado $ruta_directorio_exportado"
		exit $ERROR_DIRECTORIO_EXPORTADO
	else
		mkdir $ruta_directorio_exportado
    fi
 
done < $FICHERO_PERFIL
 
#Instalación de los paquetes nfs-kernel-server, nfs-common y rpcbind
apt-get install nfs-kernel-server nfs-common rpcbind > /dev/null
    
#Se reinicia la maquina para poner en marcha NFS
sudo reboot
    
#Iniciar servidor Portmap
/etc/init.d/portmap start
#Reinicio del servidor NFS
/etc/init.d/nfs-kernel-server restart

