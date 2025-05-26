check_for_env_content()
{
    IP="$1"
    STOP=0

    mkdir -p temp/$IP

    wget "http://$IP/.env" -q --no-verbose -O temp/$IP/env.txt --timeout=$TIMEOUT
    CHECK_SIZE=$(du -b temp/$IP/env.txt | cut -f1)

    if [ -f temp/$IP/env.txt ]
    then

        if [ $CHECK_SIZE -gt 40 ]
        then
            CHECK_FOR_SCAMMER_HTML=$(cat temp/$IP/env.txt | grep -i 'html' | wc -l)

            if [ $CHECK_FOR_SCAMMER_HTML != 0 ]
            then
                STOP=1
            fi

            CHECK_FOR_SCAMMER_SCRIPT=$(cat temp/$IP/env.txt | grep -i '<script>' | wc -l)

            if [ $CHECK_FOR_SCAMMER_SCRIPT != 0 ]
            then
                STOP=1
            fi
        
            CHECK_IF_ENV_IS_BINARY_FILE=$(file temp/$IP/env.txt | grep data | wc -l)

            if [ $CHECK_IF_ENV_IS_BINARY_FILE != 0 ]
            then
                STOP=1
            fi

            if [ $STOP == 0 ]
            then
                ENV_STATUS=1
                mkdir -p output/$IP

                if [ -f output/$IP/env.txt ]
                then
                    rm output/$IP/env.txt
                fi

                mv temp/$IP/env.txt output/$IP/env.txt
            fi
        fi
    fi
}