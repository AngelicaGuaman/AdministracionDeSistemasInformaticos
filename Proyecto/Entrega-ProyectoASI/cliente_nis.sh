#!/bin/bash
 
ERROR_PARAMETROS=50
ERROR_PATRON=51
ERROR_LINEA=52
 
EXITO=0
 
if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi
 
FICHERO_PERFIL=$1
 
numero_lineas=$(cat $FICHERO_PERFIL | wc -l)
 
if [ $numero_lineas -ne 2 ]
then
    echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener 2 lineas"
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
    nombre_del_dominio_nis=$line
    else
    servidor_nis_al_que_se_desea_conectar=$line
    fi
     
    let counter+=1
done < $FICHERO_PERFIL

#Instalación del paquete Nis y Portmap
sudo apt-get install nis -y > /dev/null

#Configuración del nombre del dominio
domainname $nombre_del_dominio_nis

#Modificación del fichero /etc/nsswitch.conf añadiendo al final de cada lina la palabra "nis"
touch /home/practicas/ficheroAuxiliar
sed 's/\n/ nis/' /etc/nsswitch.conf > /home/practicas/ficheroAuxiliar
sudo mv /home/practicas/ficheroAuxiliar /etc/nsswitch.conf

#Modificación del fichero /etc/yp.conf añadiendo ypserver <ip_del_servidor_nis>
echo "ypserver " + $servidor_nis_al_que_se_desea_conectar >> /etc/yp.conf

#Modificación de los ficheros /etc/passwd, /etc/group y /etc/shadow de la siguiente manera
echo "+::::::" >> /etc/passwd 
echo "+:::" >> /etc/group
echo "+::::::::" >> /etc/shadow

#Reinicio de los servicios Nis y Portmap
/etc/init.d/nis restart
/etc/init.d/portmap restart

#Borramos reglas de firewall para evitar errores en la conexióm
iptables -F