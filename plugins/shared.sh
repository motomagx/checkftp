USER_LIST=( admin root anonymous )
PASSWORD_LIST=( admin root anonymous )
DNS="8.8.8.8,8.8.4.4,208.67.222.222,208.67.220.220"
TIMEOUT=2      # curl/wget timeout flag
MAX_ACTIVE_CONNECTIONS=1500
MIN_RAM=256000 # minimum free memory required (KB)


_echo()
{
    if [ $DEBUG == 1 ]
    then
        echo "$1"
    fi
}

show_date()
{
    VALUE_DATE="$(date +%d/%m/%Y)"
    VALUE_HOUR="$(date +%H:%M:%S)"
    echo "[$VALUE_DATE $VALUE_HOUR]"
}

CONNECTIONS_EXCEEDED=0
RAM_EXCEEDED=0
COUNTER_CONNECTIONS=0

check_for_max_ative_connections()
{
    CONNECTIONS_EXCEEDED=0
    COUNTER_CONNECTIONS=$(find temp/connections/ -maxdepth 1 -type f | wc -l)

    if [ $COUNTER_CONNECTIONS -gt $MAX_ACTIVE_CONNECTIONS ]
    then
        CONNECTIONS_EXCEEDED=1
    fi
}

check_for_ram_consumption()
{
    RAM_EXCEEDED=0
	RAM_CONSUMPTION="`cat /proc/meminfo | grep MemFree`"
	RAM_CONSUMPTION=${RAM_CONSUMPTION/"MemFree:"/}
	RAM_CONSUMPTION=${RAM_CONSUMPTION/" kB"/}

	if [ $RAM_CONSUMPTION -lt $MIN_RAM ]
    then
        RAM_EXCEEDED=1
    fi
}