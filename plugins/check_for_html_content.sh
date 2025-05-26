GENERIC_DVR_DEVICE="Generic DVR Device"

FIND=( "Apache" "RouterOS" "DD-WRT" "TP-Link" "Samrox" "linkid=66138" "Geonode" "Apache2" "It works!" "Horde" "phpList" "Zimbra" "pfSense" "Elastix" "Arris" "Kanji" "Integrated Management Module" "Huayra" "/imagenes/prueba1.jpg" "Polycom" "SonicWALL" "macos server" "Citrix Access Gateway" "LinkID=209093" "Cisco Small Business Router" "<title>INTELBRAS</title>" "Web Maintenance Console" "Apache HTTP Server" "DVR Components" "<title>Vivo</title>" "Peplink" "SpeedTouch" "<body>This site is running <a href='http://www.TeamViewer.com'>" "D-Link Systems" "ownCloud" "loginbtnon" "lalogin" "Tomcat" "XenServer" "tbLoginFrame" "phpinfo()" "ATEN International" "HTTP Host Not Configured" "WebPanel" "Samsung DVR" "Forbidden" "/framework/cookie/client/cookie.html" "Hikvision" "NETGEAR" "Under Construction" "nginx" "<title>Google</title>" "OpenWRT" "NAS OS" "{{szErrorTip}}" "NetSuveillanceWebCookie" "<title>Roteador Wireless" "Phone Adapter Configuration Utility" "Hikvision" "Management Console</TITLE>" "/cgi-bin/firmware.cgi?formNumber=200" "Access Error: Data follows" "<title>WebPro</title>" "/dude/toplogo.jpg" '<td align="left"><a href="http://www.dlink.com.' "<title>DSLink" "Grandstream" "/webApps/Layout/" "Linksys Smart" "prew_downloadplugin" "doc/script/global_config.js" "OnOpenNetPlayByTime" '"/doc/page/login.asp?_"' 'class="mclcontainer">' "DVR System" "NetVideoOCX.cab" "Plesk" )

FIND_TEXT=( "Apache file page" "RouterOS/Mikrotik login" "DD-WRT Main Page" "TP-Link login" "Samrox/DD-WRT" "Internet Information Services" "Geonode" "Apache" "Apache" "Horde login" "phpList" "Zimbra client" "pfSense" "Elastix login" "Arris Cable Modem" "Kanji Cable Modem" "IBM Integrated Management Module" "Huayra" "$GENERIC_DVR_DEVICE" "Polycom" "Dell SonicWALL" "Mac OS X Server" "Citrix Access Gateway" "Internet Information Services" "Cisco Small Business Router" "Intelbras DVR/Cable Modem login" "Web Maintenance Console" "Apache HTTP Server Test Page" "$GENERIC_DVR_DEVICE" "Vivo Cable Modem" "Peplink" "SpeedTouch Cable Modem" "TeamViewer Server" "D-Link Wifi/Switch Device login" "ownCloud" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "Tomcat" "Citrix XenServer" "Intelbras Router/Cable Modem" "phpinfo()" "Supermicro login page" "HTTP Host Not Configured" "WebPanel" "Samsung DVR" '"Forbidden"' "HP Printer web server" "Hikvision DVR device" "NETGEAR router/cable modem" '"Under Construction"' "nginx" "Google (load balance IP)" "OpenWRT" "NAS/Storage device" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "INTELBRAS WiFi router" "Cisco Phone Adapter Configuration Utility" "$GENERIC_DVR_DEVICE" "AudioCodes Management Console" "INTELBRAS WiFi router" "Unauthorized access" "NEC device" "Mikrotik Dude" "DLink router" "DSLink router" "Grandstream device" "HP Multifunctional Printer" "Linksys WiFi router" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "Plesk" )


check_for_html_content()
{
    IP="$1"
    STOP_HTML_SEARCHING=0

    mkdir -p temp/$IP

    if [ -f temp/$IP/index.htm ]
    then
        rm temp/$IP/index.htm
    fi

    wget "http://$IP" -q --no-verbose -O temp/$IP/index.htm
    CHECK_SIZE=$(du -b temp/$IP/index.htm | cut -f1)

    if [ -f temp/$IP/index.htm ]
    then
        if [ $CHECK_SIZE -gt 1 ]
        then
            _echo "$IP HTTP OK"
        fi

        COUNTER_HTML_CHECKER=0

        while [ $STOP_HTML_SEARCHING == 0 ]
        do
            if [ "x${FIND[$COUNTER_HTML_CHECKER]}" != "x" ]
            then

                CHECK_HTML=$(cat temp/$IP/index.htm | grep -i "${FIND[$COUNTER_HTML_CHECKER]}" | wc -l)
                if [ $CHECK_HTML != 0 ]
                then
                    HTML_TITLE_TEXT="${FIND_TEXT[$COUNTER_HTML_CHECKER]}"
                    HTML_STATUS=1
                    STOP_HTML_SEARCHING=1
                fi

                COUNTER_HTML_CHECKER=$((COUNTER_HTML_CHECKER+1))
            else
                STOP_HTML_SEARCHING=1
            fi
        done
    fi
}