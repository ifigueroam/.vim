#!/bin/bash

# funcion que muestra los procesos zombies
function muestraZombies
{
    clear
    echo ""
# mostramos los encabezados en un formato de colores =)
    echo -e '\E[37;44m'"33[1mPPID     PID   Estado  Usuario  Proceso 33[0m"
# explicacion por pasos
  # mostramos los procesos en un formato definido de la siguiente forma
  # pid, ppid, state, user, comm con el comando ps -eo pid,ppid,state,user,comm
  # con awk hacemos un conteo de los zombies existentes basandonos en la columna 3 (state) haciendo un filtro
  # a saber, un proceso puede tener los siguientes estados
  # S - Sleeping
  # R - Running
  # Z - Zombie
  # con awk filtramos a aquellos que tengan en la columna state el estado Z
  # despues mostramos los zombies y cuantos son
  
    UNIX95= ps -eo ppid,pid,state,user,comm | awk 'BEGIN { count=0 } $3 ~ /Z/ { count++; print $1"\t",$2"\t",$3"\t",$4"\t",$5 } END { print "\nHay " count " proceso en estado zombie." }'
    echo ""
}

# funcion que mata los procesos zombies
function mataZombies
{
# leemos el PPID del proceso que se desea matar  y guardamos el valor en la variable PROCESOPARAMATAR
    read -p "Escribe el PPID para terminar el proceso o 'exit' para cerrar este script' : " PROCESOPARAMATAR
# en caso de que el usuario desee salir basta con que escriba salir o presione enter
    if [ "$PROCESOPARAMATAR" = "exit" ] || [ "$PROCESOPARAMATAR" = "" ]
    then
        exit
    fi
# seleccionamos el proceso que ha sido leido pero sin escribir nada a la salida estandar
    ps -p $PROCESOPARAMATAR | grep -q $PROCESOPARAMATAR
# en caso de que la instruccion anterior haya sido satisfactoria, el estado es cero, por lo que significa que 
# ha encontrado una ocurrencia, es decir, el proceso zombie existe
    if [ $? -eq 0 ]
    then
# explicacion por pasos
  # ps -o pid,user,state,comm -p $idProceso regresa una lista en el orden que se ha pedido  del proceso
  # con awk filtramos los procesos en base a la columna 1 y mostraños que el proceso con NOMBRE esta siendo ejecutado
  # por el usuario USUARIO y esta en estado ESTADO
        UNIX95= ps -o pid,user,state,comm -p $PROCESOPARAMATAR | \
        awk '$1 ~ /^[0-9]*$/ { print "El proceso " $4 " con PID " $1 " esta siendo ejecutado por el usuario " $2 " y esta actualmente en proceso " $3 }'
# confirmamos, el usuario escribe Y  o N y se guarda en la variable CONFIRMACION
  read -p "Se solicita su confirmacion para terminar con el proceso con el PID $PROCESOPARAMATAR ? Y|N : " CONFIRMACION
# si ha escrito Y o y
        if [ "$CONFIRMACION" = "Y" ] || [ "$CONFIRMACION" = "y" ]
        then
# matamos el proceso con la señal -9
            kill -9 $PROCESOPARAMATAR
            echo ""
# se confirma que se ha matado el proceso y si quiere empezar de nuevo, la respuesta se guarda en la variable RETORNO
            read -p "Ha terminado el proceso con PID $PROCESOPARAMATAR. Desea regresar? Y/N : " RETORNO
        else
# llamamos a la funcion mataZombies 
            mataZombies
        fi
    else
# el usuario escribio un PID invalido
        echo "PID Invalido. Intente de nuevo."
        echo ""
# se llama a la funcion mataZombies
        mataZombies
    fi
}

#funcion para mostrar la ayuda
function help
{
    echo ""
    echo "Uso: shaman [-h | help -d]"
    echo "-d muestra los procesos en estado zombie"
    echo "-h | help : ayuda"
    echo ""
    exit
}

#veficamos que el primer argumento sea -h o help
if [ "$1" = "-h" ] || [ "$1" = "help" ]
then
#llamamos a la funcion ayuda
    help
fi

#si el primer argumento es -d
if [ "$1" = "-d" ]
then
#llamamos a la funcion muestraZombies
    muestraZombies
else
#en ese caso contrario se muestran los procesos zombies y se invoca a la funcion mataZombies
    muestraZombies
    mataZombies
fi
#bucle de retorno
if [ "$RETORNO" = "Y" ] || [ "$RETORNO" = "y" ]
then
    muestraZombies
    mataZombies
fi
echo ""
