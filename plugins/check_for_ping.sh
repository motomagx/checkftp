PING=0

check_for_ping()
{
	IP="$1"
	ping -c 5 -W 2 $IP -q > /dev/null
	STATUS="$?"

	if [ $STATUS == 0 ]
	then
		_echo "Ping $IP return OK"
        PING=1
	fi
}