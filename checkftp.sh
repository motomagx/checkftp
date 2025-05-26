#!/bin/bash

# CheckFTP 
# https://github.com/motomagx/checkftp

# Deps: axel wget nmap bc
# Fuck Putin!

VERSION=0.5
INPUT="$1"
SOLO=0
DEBUG=0
DNS="8.8.8.8,8.8.4.4,208.67.222.222,208.67.220.220"

if [ "x$1" == "x" ]
then
	echo "Input an IP, modafuka!"
	exit
fi

if [ "x$2" == "xsolo" ]
then
	SOLO=1
fi

mkdir -p temp

rm -r temp/*
rm wget-log*
clear

INPUT=( ${INPUT//'.'/' '} )

A=${INPUT[0]}
B=${INPUT[1]}
C=${INPUT[2]}
D=${INPUT[3]}

IP_FILE="`date +%d-%m-%Y`_`date +%Hh%Mm%S`"

# Load plugins:

source plugins/check_for_ping.sh
source plugins/shared.sh
source plugins/check_for_env.sh
source plugins/check_for_ftp.sh
source plugins/check_for_ssh.sh
source plugins/check_for_html_content.sh

echo -e "CheckFTP multiscan script v$VERSION\n"
echo -e "Starting IP: $1, end: 255.255.255.0"
echo -e "Press Control+C to stop.\n"
echo -e "For best performance, set randisk at temp dir:"
echo -e "sudo mount -t tmpfs -o size=1G tmpfs temp\n"
echo -e "TIMEOUT=$TIMEOUT, MAX_ACTIVE_CONNECTIONS=$MAX_ACTIVE_CONNECTIONS, MIN_RAM=$MIN_RAM\n"


# increase () increments the IP number. If it is 256, it receives the value of 1
# (except B and C) and the previous digit is incremented, applying
# the same rule. If A is equal to 256, the script is terminated.

increase()
{
	D=$(($D+1))

	if [ $D == 256 ]
	then
		D=1
		C=$(($C+1))
	fi

	if [ $C == 256 ]
	then
		C=0
		B=$(($B+1))
	fi

	if [ $B == 256 ]
	then
		B=1
		A=$(($A+1))
	fi

	if [ "$A.$B.$C.$D" == "255.255.255.255" ]
	then
		exit
	fi
}

run()
{
	IP="$1"

    mkdir -p temp/connections/
	touch temp/connections/$IP.lock

	check_for_ping $IP $TIMEOUT
	
	if [ $PING == 1 ]
	then
		HTML_TITLE=""
		HTML_STATUS=0
		HTML_STATUS=0
		ENV_STATUS=0
		FTP_STATUS=0
		SFTP_STATUS=0
		SSH_STATUS=0
		SSH_USER_FOUND=""
		SSH_PASSWORD_FOUND=""
		SSH_TEXT_START=""
		SSH_TEXT_END=""
		SFTP_USER_FOUND=""
		SFTP_PASSWORD_FOUND=""
		SFTP_TEXT_START=""
		SFTP_TEXT_END=""
		FTP_USER_FOUND=""
		FTP_PASSWORD_FOUND=""
		FTP_TEXT_START=""
		FTP_TEXT_END=""
		HTML_TEXT_START=""
		HTML_TEXT_END=""

		#check_for_html_content $IP
		check_for_env_content $IP
		#check_for_ftp $IP
		#check_for_ssh $IP # broken, FIX exiting at valid password

		IS_SOMETHING_ENABLED_ON_THIS_IP="$(($HTML_STATUS+$ENV_STATUS+$SSH_STATUS+$FTP_STATUS+$SFTP_STATUS))"

		if [ $ENV_STATUS == 1 ]
		then
			ENV_STATUS_TEXT="\033[32m[ENV]\033[0m" # found .env
		else
			ENV_STATUS_TEXT="\033[31m[ENV]\033[0m" # no .env :(
		fi

		if [ $FTP_STATUS == 1 ]
		then
			FTP_STATUS_TEXT="\033[32m[FTP]\033[0m" # found .env
			FTP_TEXT_START="[FTP: "
			FTP_TEXT_END="]"
			FTP_TWO_DOTS=":"

		else
			FTP_STATUS_TEXT="\033[31m[FTP]\033[0m" # no .env :(
		fi

		if [ $SFTP_STATUS == 1 ]
		then
			SFTP_STATUS_TEXT="\033[32m[SFTP]\033[0m" # found .env
			SFTP_TEXT_START="[SFTP: "
			SFTP_TEXT_END="]"
			SFTP_TWO_DOTS=":"
		else
			SFTP_STATUS_TEXT="\033[31m[SFTP]\033[0m" # no .env :(
		fi

		if [ $SSH_STATUS == 1 ]
		then
			SSH_STATUS_TEXT="\033[32m[SSH]\033[0m" # found .env
			SSH_TEXT_START="[SSH: "
			SSH_TEXT_END="]"
			SSH_TWO_DOTS=":"
		else
			SSH_STATUS_TEXT="\033[31m[SSH]\033[0m" # no .env :(
		fi

		if [ $HTML_STATUS == 1 ]
		then
			HTML_STATUS_TEXT="\033[32m[HTTP]\033[0m" # found .env
			HTML_TEXT_START="[HTTP: "
			HTML_TEXT_END="]" # no .env :(

		else
			HTML_STATUS_TEXT="\033[31m[HTTP]\033[0m" # no .env :(
		fi

		if [ $IS_SOMETHING_ENABLED_ON_THIS_IP != 0 ]
		then
			echo -e "$(show_date) $(printf '[%-15s]' $IP) $HTML_STATUS_TEXT $FTP_STATUS_TEXT $SFTP_STATUS_TEXT $SSH_STATUS_TEXT $ENV_STATUS_TEXT $HTML_TEXT_START $HTML_TITLE_TEXT$HTML_TEXT_END $SFTP_TEXT_START$SFTP_USER_FOUND$SFTP_TWO_DOTS$SFTP_PASSWORD_FOUND$SFTP_TEXT_END $FTP_TEXT_START$FTP_USER_FOUND$FTP_TWO_DOTS$FTP_PASSWORD_FOUND$FTP_TEXT_END $SSH_TEXT_START$SSH_USER_FOUND$SSH_TWO_DOTS$SSH_PASSWORD_FOUND$SSH_TEXT_END"
		fi
	fi

	rm temp/connections/$IP.lock
}



# Suns solo (just check the IP and exit) or until IP = 255.255.255.255
if [ $SOLO == 1 ]
then
	echo "Running solo"
	run "$A.$B.$C.$D"
else
	while true
	do
		SLEEP=0

		mkdir -p temp/connections/
		check_for_max_ative_connections
		check_for_ram_consumption

		if [ $CONNECTIONS_EXCEEDED == 1 ]
		then
			SLEEP=1
		fi

		if [ $RAM_EXCEEDED == 1 ]
		then
			SLEEP=1
		fi

		if [ $SLEEP == 0 ]
		then
			run "$A.$B.$C.$D" &
			increase
		else
			_echo "Sleep ram_exc:$RAM_EXCEEDED conn_exc:$CONNECTIONS_EXCEEDED  conn_count:$COUNTER_CONNECTIONS"
			sleep 0.5
		fi
	done
fi
