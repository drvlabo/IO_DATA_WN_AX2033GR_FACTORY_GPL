#!/bin/sh
#MSTC MBA SW Sean, add for configure files for platform

if [ $# -lt 2 ]; then
	echo "Usage: configure.sh <Platform Name> <Profile Name>"
	echo "e.g.,  configure.sh mt7621 micap3340c"
	exit
fi

PLATFORM=$1
PROFILE=$2

if ! [ -a project ]; then
	echo "error! project dir not exist!"
	exit
fi

if ! [ -a project/$PLATFORM ]; then
	echo "error! project/$PLATFORM not exist!"
	exit
fi

if ! [ -a project/$PLATFORM/$PROFILE ]; then
	echo "error! project/$PLATFORM/$PROFILE not exist!"
	exit
fi

if ! [ -a project/$PLATFORM/$PROFILE/config-3.10 ]; then
	echo "error! project/$PLATFORM/$PROFILE/config-3.10 not exist!"
	exit
fi

if ! [ -a project/$PLATFORM/$PROFILE/.config ]; then
	echo "error! project/$PLATFORM/$PROFILE/.config not exist!"
	exit
fi

if ! [ -a project/$PLATFORM/$PROFILE/configure.sh ]; then
	echo "error! project/$PLATFORM/$PROFILE/configure.sh not exist!"
	exit
fi

echo "Copy Default kernel config file to target/linux/ramips/$PLATFORM/config-3.10"
cp project/$PLATFORM/$PROFILE/config-3.10 target/linux/ramips/$PLATFORM/config-3.10

echo "Copy Default kernel config file to target/linux/ramips/$PLATFORM/profiles/00-default.mk"
cp project/$PLATFORM/$PROFILE/00-default.mk target/linux/ramips/$PLATFORM/profiles/00-default.mk

echo "Copy Default config file to .config"
cp project/$PLATFORM/$PROFILE/.config .config

project/$PLATFORM/$PROFILE/configure.sh $PLATFORM $PROFILE

echo "Done!"

