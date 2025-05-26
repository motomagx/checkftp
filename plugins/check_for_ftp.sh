check_for_ftp()
{
    IP="$1"
    STOP=0
    COUNTER_FTP=0

    while [ $STOP == 0 ]
    do
        # ftp:
        curl -u ${USER_LIST[$COUNTER_FTP]}:${PASSWORD_LIST[$COUNTER_FTP]} "ftp://$IP" --silent --head --connect-timeout $TIMEOUT

        if [ $? -eq 0 ]; then
            FTP_STATUS=1
            STOP=1

            FTP_USER_FOUND="${USER_LIST[$COUNTER_FTP]}"
    		FTP_PASSWORD_FOUND="${PASSWORD_LIST[$COUNTER_FTP]}"
        fi
    
        # sftp:
        curl -u ${USER_LIST[$COUNTER_FTP]}:${PASSWORD_LIST[$COUNTER_FTP]} "sftp://$IP" --silent --head --connect-timeout $TIMEOUT

        if [ $? -eq 0 ]; then
            SFTP_STATUS=1
            STOP=1

         	SFTP_USER_FOUND="${USER_LIST[$COUNTER_FTP]}"
    		SFTP_PASSWORD_FOUND="${PASSWORD_LIST[$COUNTER_FTP]}"
        fi

        if [ "x${USER_LIST[$COUNTER_FTP]}" == "x" ]
        then
            STOP=1
        fi

        COUNTER_FTP=$(($COUNTER_FTP+1))
    done
}

