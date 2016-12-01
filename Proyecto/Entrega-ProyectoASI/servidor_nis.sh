#!/bin/bash
 
ERROR_PARAMETROS=70
ERROR_PATRON=71
ERROR_LINEA=72
 
EXITO=0
 
if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_perfil>"
    exit $ERROR_PARAMETROS
fi
 
FICHERO_PERFIL=$1
 
numero_lineas=$(cat $FICHERO_PERFIL | wc -l)
 
if [ $numero_lineas -eq 0 ]
then
     echo "[FICHERO PERFIL]: El fichero $FICHERO_PERFIL tiene $numero_lineas lineas y debe tener una línea"
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
 
    nombre_del_dominio_nis=$line
        
done < $FICHERO_PERFIL

#Instalación del paquete NIS y PORTMAP
sudo apt-get install portmap -y
sudo apt-get install nis -y

#Nombre del dominio NIS
domainname $nombre_del_dominio_nis

#Creación de usuario que permitiremos via NIS
if [ $(id -u) -eq 0 ]; then
	read -p "Introducir usuario : " usuario
	read -s -p "Introducir contraseña : " contrasenha
	egrep "^$usuario" /etc/passwd > /dev/null
	if [ $? -eq 0 ]; then
		echo "$usuario existente!"
		exit 1
	else
		password=$(perl -e 'print crypt($ARGV[0], "contraseña")' $contraseña)
		useradd -m -p $password $usuario
		[ $? -eq 0 ] && echo "El usuario ha sido creado" || echo "No se pudo crear el usuario"
	fi
else
	echo "Sólo root puede añadir un usuario al sistema"
	exit 2
fi

#Modificaciones para que los servicios NIS y shadowing no se interrumpan
egrep "^$:x:" /etc/passwd 
if [ $? -eq 0 ]; then
	echo "Passwords shadowed"
	touch /home/practicas/fichero_Auxiliar
	sed 's/usuario/#usuario/' /etc/shadow > /home/practicas/fichero_Auxiliar
	mv /home/practicas/fichero_Auxiliar /etc/shadow
	exit 1
else
	exit 1
fi

#Modificación del fichero /etc/passwd
linea_shadow=$(grep -e "usuario3" shadow.txt)
IFS=':' read -a campos_shadow <<< "$linea_shadow"

linea_passwd=$(grep -e "usuario3" passwd.txt)
IFS=':' read -a campos_passwd <<< "$linea_passwd"

cont=0
for x in ${campos_passwd[@]}
do
	if [ $cont -eq 0 ]
	then
		linea_final=$x
	elif [ $cont -eq 1 ]
	then
		linea_final+=":${campos_shadow[1]}"
	else
		linea_final+=":$x"
	fi
	let cont+=1
done

touch /home/practicas/aux_file.txt
sed "s/$linea_passwd/$linea_final/g" /etc/passwd > home/practicas/aux_file.txt
mv aux_file.txt /etc/passwd

#Iniciar servicios necesarios 
/usr/sbin/ypserv start
/usr/sbin/rpc.yppasswd
/usr/sbin/rpc.ypxfrd

#Creación de mapas NIS
/usr/lib/yp/ypinit -m

rpcinfo -p