#!/bin/bash

ERROR_CONFIGURACION=100
FICHERO_NO_EXISTE=101
ERROR_PATRON=102
NO_EXISTE_SERVICIO=103
ERROR_PING=104
ERROR_COPIAR_FICHERO=105

NUMERO_PING=2

EXITO=0

if [ $# -ne 1 ]
then
    echo "uso: $0 <fichero_de_configuracion>"
    exit $ERROR_CONFIGURACION
fi

FICHERO_CONFIGURACION=$1

if [ ! -f $FICHERO_CONFIGURACION ]
then
    echo "El fichero $FICHERO_CONFIGURACION no existe"
    exit $FICHERO_NO_EXISTE
fi

while read line
do
    numero_palabras=$(echo $line | wc -w)

    primera=${line:0:1}

    if [ $numero_palabras -eq 0 -o "$primera" == "#" ]
    then
	continue
    fi
    
    if [ $numero_palabras -lt 3 -o $numero_palabras -gt 3 ]
    then
	echo "[PATRON]: Error en el patron $line"
	exit $ERROR_PATRON
    fi
    
    words=($line)
    
    maquina=${words[0]}
    servicio=${words[1]}
    fichero_perfil=${words[2]}

    ping -c $NUMERO_PING $maquina > /dev/null

    if [ $? -ne 0 ]
    then
	echo "[PING]: No tenemos acceso a la máquina: $maquina"
	exit $ERROR_PING
    fi
    
    if [ ! -f $fichero_perfil ]
    then
	echo "[FICHERO PERFIL]: El fichero $fichero_perfil no existe"
	exit $FICHERO_NO_EXISTE
    fi

    if [ "$servicio" == "mount" ]
    then
	echo "Se está realizando MOUNT en la $maquina"
	scp mount.sh $maquina:/tmp/mount.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar mount.sh en $maquina"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	echo "Se copia el script para poder ejecutar el servicio"

	scp $fichero_perfil $maquina:/tmp/mount.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar mount.conf en $maquina"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	echo "Se copia el fichero de perfil para poder ejecutar el servicio"

	ssh $maquina '/tmp/mount.sh /tmp/mount.conf RES=$?; exit $RES' &> /dev/null
	
	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[MOUNT]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[MOUNT]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
	
    elif [ "$servicio" == "raid" ]
    then
	scp raid.sh $maquina:/tmp/raid.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar raid.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/raid.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar raid.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/raid.sh /tmp/raid.conf RES=$?; rm /tmp/raid.sh; rm /tmp/raid.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[RAID]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[RAID]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi

    elif [ "$servicio" == "lvm" ]
    then
	scp lvcreate.sh $maquina:/tmp/lvcreate.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar lvcreate.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/lvcreate.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar lvcreate.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/lvcreate.sh /tmp/lvcreate.conf RES=$?; rm /tmp/lvcreate.sh; rm /tmp/lvcreate.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[LVM]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[LVM]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
    elif [ "$servicio" == "nis_server" ]
    then
	scp servidor_nis.sh $maquina:/tmp/servidor_nis.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar servidor_nis.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/servidor_nis.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar servidor_nis.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/servidor_nis.sh /tmp/servidor_nis.conf RES=$?; rm /tmp/servidor_nis.sh; rm /tmp/servidor_nis.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[SERVIDOR NIS]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[SERVIDOR NIS]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
    elif [ "$servicio" == "nis_client" ]
    then
	scp cliente_nis.sh $maquina:/tmp/cliente_nis.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar cliente_nis.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/cliente_nis.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar cliente_nis.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/cliente_nis.sh /tmp/cliente_nis.conf RES=$?; rm /tmp/cliente_nis.sh; rm /tmp/cliente_nis.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[CLIENTE NIS]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[CLIENTE NIS]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
    elif [ "$servicio" == "nfs_server" ]
    then
	scp servidor_nfs.sh $maquina:/tmp/servidor_nfs.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar servidor_nfs.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/servidor_nfs.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar servidor_nfs.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/servidor_nfs.sh /tmp/servidor_nfs.conf RES=$?; rm /tmp/servidor_nfs.sh; rm /tmp/servidor_nfs.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[SERVIDOR NFS]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[SERVIDOR NFS]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
    elif [ "$servicio" == "nfs_client" ]
    then
	scp cliente_nfs.sh $maquina:/tmp/cliente_nfs.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar cliente_nfs.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/cliente_nfs.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar cliente_nfs.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/cliente_nfs.sh /tmp/cliente_nfs.conf RES=$?; rm /tmp/cliente_nfs.sh; rm /tmp/cliente_nfs.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[CLIENTE NFS]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[CLIENTE NFS]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
    elif [ "$servicio" == "backup_server" ]
    then
	scp servidor_backup.sh $maquina:/tmp/servidor_backup.sh &> /dev/null
	
	if [ $? -ne 0]
        then
	    echo "[SCP]: No se ha podido copiar servidor_backup.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/servidor_backup.conf &> /dev/null

        if [ $? -ne 0]
        then
	    echo "[SCP]: No se ha podido copiar servidor_backup.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/servidor_backup.sh /tmp/servidor_backup.conf RES=$?; rm /tmp/servidor_backup.sh; rm /tmp/servidor_backup.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[SERVIDOR BACKUP]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[SERVIDOR BACKUP]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
    elif [ "$servicio" == "backup_client" ]
    then
	scp cliente_backup.sh $maquina:/tmp/cliente_backup.sh &> /dev/null
	
	if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar cliente_backup.sh"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	scp $fichero_perfil $maquina:/tmp/cliente_backup.conf &> /dev/null

        if [ $? -ne 0 ]
        then
	    echo "[SCP]: No se ha podido copiar cliente_backup.conf"
            exit $ERROR_COPIAR_FICHERO
        fi
        
	ssh $maquina '/tmp/cliente_backup.sh /tmp/cliente_backup.conf RES=$?; rm /tmp/cliente_backup.sh; rm /tmp/cliente_backup.conf; exit $RES' &> /dev/null

	RES=$?
	if [ $RES -eq 0 ]
	then
	    echo "[CLIENTE BACKUP]: Se ha ejecutado con exito el script"
	    exit $EXITO
	else
	    echo "[CLIENTE BACKUP]: Hubo problemas al ejecutar el script"
	    exit $RES
	fi
    else
	echo "[SERVIDOR]: No existe el servicio"
	exit $NO_EXISTE_SERVICIO
    fi
done < $FICHERO_CONFIGURACION


