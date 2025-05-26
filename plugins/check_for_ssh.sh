check_for_ssh()
{
    IP="$1"
    STOP=0
    COUNTER_SSH=0

    while [ $STOP == 0 ]
    do
        if [ "x${USER_LIST[$COUNTER_SSH]}" != "x" ]
        then
        echo sshpass -p "${PASSWORD_LIST[$COUNTER_SSH]}" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$TIMEOUT "${USER_LIST[$COUNTER_SSH]}@$IP" 'exit'

            sshpass -p "${PASSWORD_LIST[$COUNTER_SSH]}" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$TIMEOUT "${USER_LIST[$COUNTER_SSH]}@$IP" 'exit' 

            echo status $?

            if [ $? == 0 ]; then
                SSH_STATUS=1
                SSH_USER_FOUND="${USER_LIST[$COUNTER_SSH]}"
                SSH_PASSWORD_FOUND="${PASSWORD_LIST[$COUNTER_SSH]}"
                STOP=1
            fi

            COUNTER_SSH=$(($COUNTER_SSH+1))

            if [ "x${USER_LIST[$COUNTER_SSH]}" == "x" ]
            then
                STOP=1
            fi
        fi

    done
}

