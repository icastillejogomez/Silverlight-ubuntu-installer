#!/bin/bash

# funcion fin para salir del script
function fin(){
	echo "Finalizando la ejecucion del scipt"
	unset REPOSITORIO
	unset SALIDA
	unset CONFIRMACION
	unset PAQUETE
}

# trap para capturar las señales de salida del script
trap "fin; exit 2;" INT TERM 

# Comprobamos si se ejecuta como root el script
if [ "$EUID" -ne 0 ]; then 
	echo "Este script se debe ejecutar como root" 
 	exit 1
fi

# Variables del script
REPOSITORIO="ppa:pipelight/stable"
SALIDA=0
PAQUETE="pipelight-multi"
CONFIRMACION=

# Incluimos el repositorio si el usuario lo desea
function comprobar_repositorio(){
	echo -n "¿Desea instalar el repositorio $REPOSITORIO? [ s / n ] >> "
	read CONFIRMACION
	case "$CONFIRMACION" in
	s) sudo add-apt-repository -y $REPOSITORIO > /dev/null 2> /dev/null 
	SALIDA=$?
	if [ $SALIDA != 0 ]; then 
		echo "Hubo un error añadiendo el repositorio $REPOSITORIO"
		fin
		exit $SALIDA
	else
		echo "Repositorio $REPOSITORIO instalado correctamente"
	fi ;;
	n) echo "El programa continuara sin instalar el repositorio $REPOSITORIO" ;;
	*) echo "Debe presionar s o n para continuar." 
	comprobar_repositorio ;;
	esac
}
comprobar_repositorio

# Actualizamos los paquetes 
echo -n "Actualizando los paquetes..."
sudo apt-get update > /dev/null 2>&1
if [ $? != 0 ]; then 
	echo " Hubo un error actualizando los paquetes"
	fin
	exit 3
else
	echo " Paquetes actualizados correctamente"
fi

# Intalamos pipelight-multi
echo -n "Instalando el paquete $PAQUETE..."
sudo apt-get install -y --install-recommends $PAQUETE > /dev/null 2>&1
if [ $? != 0 ]; then 
	echo " Hubo un error instalando el paquete $PAQUETE"
	fin 
	exit 4
else
	echo " $PAQUETE instalado correctamente"
fi

# Actualizamos el plugin pipelight
echo -n "Actualizando el plugin pipelight..."
sudo pipelight-plugin --update > /dev/null 2>&1
if [ $? != 0 ]; then 
	echo " Hubo un error actualizando el plugin pipelight"
	fin 
	exit 4
else
	echo " Plugin actualizado correctamente"
fi

# Activamos silverlight
echo -n "Activando silverlight.."
echo "Y" | pipelight-plugin --enable silverlight > /dev/null 2>&1
if [ $? != 0 ]; then 
	echo " Hubo un error activando silverlight"
	fin 
	exit 5
else
	echo " Silverlight activado correctamente"
fi

# Creamos el plugin para mozilla-firefox
echo -n "Creando el plugin para mozilla-firefox..."
sudo pipelight-plugin --create-mozilla-plugins > /dev/null 2>&1
if [ $? != 0 ]; then 
	echo " Hubo un error creando el plugin para mozilla-firefox"
	fin 
	exit 6
else
	echo " Plugin creado correctamente"
fi

# Esta ultima linea evita el error 6030 de yomvi en Ubuntu
echo -n "Bajando a la version 5.0 para poder correr en Ubuntu (Firefox)"
echo "Y" | sudo pipelight-plugin --disable silverlight --enable silverlight5.0 > /dev/null 2>&1
if [ $? != 0 ]; then 
	echo " Hubo un error bajando a la version 5.0"
	fin 
	exit 6
else
	echo " Instalacion de Silverlight5.0 terminada corretamente"
fi

# Finalizando el programa
fin
exit 0
