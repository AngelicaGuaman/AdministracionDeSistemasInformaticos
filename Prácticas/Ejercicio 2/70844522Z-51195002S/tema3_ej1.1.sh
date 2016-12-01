#!/bin/bash 

clear 

if [ $# -gt 5 -o $# -lt 1 -o $# -eq 2 -o $# -eq 4 ]
then 
	echo "Uso: $0 <nombre base> [ -n <num usuarios> ] [ -g <grupo> ]" 
	exit 1
fi

#El nombre base es obligatorio 
NOMBRE_BASE=$1
PAM_NUM=$2  
#EL resto de parametros son opcionales 
NUM_USUARIOS=$3
PAM_USU=$4
GRUPO=$5  
#Solo se le ha pasado el parametro del nombre de usuario

if [ $# -eq 1 ]
then 
	NUM_USUARIOS=5
	GRUPO=$NOMBRE_BASE
	PAM_NUM="-n"
	PAM_USU="-g"
elif [ $# -eq 3 ]
then
	GRUPO=$NOMBRE_BASE
	PAM_USU="-g"
fi

if [ "$PAM_NUM" != "-n" -o "$PAM_USU" != "-g" ]
then
	echo "Parámetros incorrectos Uso: $0 <nombre base> [ -n <num usuarios> ] [ -g <grupo> ]"
	exit 1
fi

#posible ejecucion ./crearConjunto.sh prueba -n 5 -g grupol 
#empezamos desde 1 por lo que el bucle tiene que ser igual al valor del parametro

COUNTER=1

while [ $COUNTER -le $NUM_USUARIOS ]; do 
	if grep -qw $GRUPO /etc/group 
	then 
		echo No se pudo añadir el grupo, ya existe 
	else 
		sudo addgroup $GRUPO 
		echo se añade el grupo
	fi
	echo Se añade el usuario con el grupo determinado 
	sudo adduser $NOMBRE_BASE""$COUNTER --ingroup $GRUPO 
	let COUNTER+=1
done
