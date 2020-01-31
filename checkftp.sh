#!/bin/bash

# CheckFTP 
# https://github.com/motomagx/checkftp

VERSION=0.2

A=179	      # 1º IP block
B=127	      # 2º IP block
C=0 	      # 3º IP block
D=1 	      # 4º IP block

TIMEOUT=10     # curl timeout flag
MIN_RAM=256000 # minimum free memory required (KB)

IP_FILE="`date +%d-%m-%Y`_`date +%Hh%Mm%S`"
IP_FILE="ip_file"
PARAM="$1"
GENERIC_DVR_DEVICE="DVR device (unknown brand)"

FIND=( "Apache" "RouterOS" "DD-WRT" "TP-Link" "Samrox" "linkid=66138" "Geonode" "Apache2" "It works!" "Horde" "phpList" "Zimbra" "pfSense" "Elastix" "Arris" "Kanji" "Integrated Management Module" "Huayra" "/imagenes/prueba1.jpg" "Polycom" "SonicWALL" "macos server" "Citrix Access Gateway" "LinkID=209093" "Cisco Small Business Router" "<title>INTELBRAS</title>" "Web Maintenance Console" "Apache HTTP Server" "DVR Components" "<title>Vivo</title>" "Peplink" "SpeedTouch" "<body>This site is running <a href='http://www.TeamViewer.com'>" "D-Link Systems" "ownCloud" "loginbtnon" "lalogin" "Tomcat" "XenServer" "tbLoginFrame" "phpinfo()" "ATEN International" "HTTP Host Not Configured" "WebPanel" "Samsung DVR" "Forbidden" "/framework/cookie/client/cookie.html" "Hikvision" "NETGEAR" "Under Construction" "nginx" "<title>Google</title>" "OpenWRT" "NAS OS" "{{szErrorTip}}" "NetSuveillanceWebCookie" "<title>Roteador Wireless" "Phone Adapter Configuration Utility" "Hikvision" "Management Console</TITLE>" "/cgi-bin/firmware.cgi?formNumber=200" "Access Error: Data follows" "<title>WebPro</title>" "/dude/toplogo.jpg" '<td align="left"><a href="http://www.dlink.com.' "<title>DSLink" "Grandstream" "/webApps/Layout/" "Linksys Smart" "prew_downloadplugin" "doc/script/global_config.js" "OnOpenNetPlayByTime" '"/doc/page/login.asp?_"' 'class="mclcontainer">' "DVR System" "NetVideoOCX.cab" "Plesk" )

FIND_TEXT=( "Apache file page" "RouterOS/Mikrotik login" "DD-WRT Main Page" "TP-Link login" "Samrox/DD-WRT" "Internet Information Services" "Geonode" "Apache" "Apache" "Horde login" "phpList" "Zimbra client" "pfSense" "Elastix login" "Arris Cable Modem" "Kanji Cable Modem" "IBM Integrated Management Module" "Huayra" "$GENERIC_DVR_DEVICE" "Polycom" "Dell SonicWALL" "Mac OS X Server" "Citrix Access Gateway" "Internet Information Services" "Cisco Small Business Router" "Intelbras DVR/Cable Modem login" "Web Maintenance Console" "Apache HTTP Server Test Page" "$GENERIC_DVR_DEVICE" "Vivo Cable Modem" "Peplink" "SpeedTouch Cable Modem" "TeamViewer Server" "D-Link Wifi/Switch Device login" "ownCloud" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "Tomcat" "Citrix XenServer" "Intelbras Router/Cable Modem" "phpinfo()" "Supermicro login page" "HTTP Host Not Configured" "WebPanel" "Samsung DVR" '"Forbidden"' "HP Printer web server" "Hikvision DVR device" "NETGEAR router/cable modem" '"Under Construction"' "nginx" "Google (load balance IP)" "OpenWRT" "NAS/Storage device" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "INTELBRAS WiFi router" "Cisco Phone Adapter Configuration Utility" "$GENERIC_DVR_DEVICE" "AudioCodes Management Console" "INTELBRAS WiFi router" "Unauthorized access" "NEC device" "Mikrotik Dude" "DLink router" "DSLink router" "Grandstream device" "HP Multifunctional Printer" "Linksys WiFi router" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "$GENERIC_DVR_DEVICE" "Plesk" )

if [ $USER != "root" ]
then
	echo "NEED BE ROOT, B1TCH!"
	exit
fi

if [ "$PARAM" == "clear" ]
then
	if [ -d ftp ]
	then
		rm -r ftp
		echo "Cache limpo."
	fi
fi

if [ ! -d ftp ]
then
	mkdir ftp
fi

if [ ! -d "ftp/ramdisk" ]
then
	mkdir "ftp/ramdisk"
fi

if [ ! -d "ftp/ip" ]
then
	mkdir "ftp/ip"
fi


if [ -f "ftp/$IP_FILE.htm" ]
then
	rm "ftp/$IP_FILE.htm"
fi

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
}

test_protocols()
{
	IP1="$1"
	FTP_ON=0
	HTTP_ON=0
	CHECK=0
	TEST_CONTENT_HTTP="`curl $IP1 --connect-timeout "$TIMEOUT" --silent`"

	if [ "x$TEST_CONTENT_HTTP" != "x" ]
	then
		#echo "IP $IP1 com HTTP ativo"

		if [ ! -d "ftp/ip/$IP1" ]
		then
			mkdir "ftp/ip/$IP1"
		fi

		wget "$IP1" -O "ftp/ip/$IP1/http.htm" --timeout=$TIMEOUT -q

		STATUS_HTTP="[HTTP] "
		HTTP_ON=1
		CHECK=1
	fi

	TEST_CONTENT_FTP="`curl ftp://$IP1 --connect-timeout "$TIMEOUT" --silent`"

	if [ "x$TEST_CONTENT_FTP" != "x" ]
	then
		#echo "IP $IP1 com FTP ativo"

		if [ ! -d "ftp/ip/$IP1" ]
		then
			mkdir "ftp/ip/$IP1"
		fi

		wget "ftp://$IP1" -O "ftp/ip/$IP1/ftp.htm" --timeout=$TIMEOUT -q

		STATUS_FTP="[FTP] "
		FTP_ON=1
		CHECK=1
	fi

	if [ ! -f "ftp/$IP_FILE.htm" ]
	then
		CODE="
<head>
<style type='text/css'>
.title {
	font-size: x-large;
	font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
}
.text {
	font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
	font-size: small;
}
.text_center {
	font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
	font-size: small;
	text-align: center;
}
.div_title {
	border-bottom-style: solid;
	border-bottom-width: 1px;
	border-bottom-color: #0000FF;
}
.text_center_link {
	font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
	font-size: small;
	text-align: center;
	color: #0000FF;
	text-decoration: none;
}

</style>
</head>

<p class='title'>CheckFTP v$VERSION<br><span class='text'><span class='auto-style1'>
<br><a href='https://github.com/motomagx/checkftp' target='_blank'>https://github.com/motomagx/checkftp</a></td><br>

<br>
Date: `date +%d/%m/%Y` - Time: `date +%Hh%Mm%Ss` - Start: $A.$B.$C.$D - End: 255.255.255.0<br>Pages that are blank or require browser authentication will be ignored.</span></span></p>
<table cellpadding='0' cellspacing='0' style='width: 800'>
	<tr class='text_center'>
		<td class='text_center' style='width: 20%; height: 30'>
		<div class='div_title'>
			Date/Hour</div>
		</td>
		<td class='text_center' style='width: 20%; height: 30'>
		<div class='div_title'>
			IP tracker</div>
		</td>
		<td style='width: 30%; height: 30'>
		<div class='div_title'>
			HTTP</div>
		</td>
		<td style='width: 30%; height: 30'>
		<div class='div_title'>
			FTP</div>
		</td>
	</tr> 
</table>"
		echo "$CODE" > "ftp/$IP_FILE.htm"
	fi

	if [ $CHECK == 1 ]
	then
		HTTP_TEXT="HTTP"

		if [ "`cat ftp/$IP_FILE.htm | grep $IP | wc -l`" == 0 ]
		then
			TIME="`date +%H:%M:%S`"
			BASE_TEXT=""

			if [ $FTP_ON == 1 ]
			then
				FTP_TEXT="[FTP]"
			else
				FTP_TEXT=""
			fi

			DESCRIPTION=""
			TEXT_LOG=""
			TEXT_LOG1=""

			if [ -f "ftp/ip/$IP1/http.htm" ]
			then

				DU=( `du "ftp/ip/$IP1/http.htm"` )
				DU="${DU[0]}"

				COUNTER_FIND=0

				if [ "$DU" != 0 ]
				then
					while [ "x${FIND[$COUNTER_FIND]}" != "x" ]
					do
						TEST_FIND=`cat "ftp/ip/$IP1/http.htm" | grep -i "${FIND[$COUNTER_FIND]}" | wc -l`

						if [ "$TEST_FIND" != "0" ]
						then
							DESCRIPTION="${FIND_TEXT[$COUNTER_FIND]}"
							HTTP_TEXT="$DESCRIPTION"
							TEXT_LOG="${FIND_TEXT[$COUNTER_FIND]}"
							TEXT_LOG1="- $TEXT_LOG"
						fi

						COUNTER_FIND=$(($COUNTER_FIND+1))
					done
				else
					DESCRIPTION="Empty or login page."
					HTTP_TEXT="$DESCRIPTION"
					TEXT_LOG="$DESCRIPTION"
					TEXT_LOG1="- $TEXT_LOG"
				fi
			fi

			HTML="
<table style='width: 800'><tr><td class='text_center' style='width: 20%'>`date +%d/%m/%Y` - `date +%H:%M:%S`</td>
		<td class='text_center' style='width: 20%'>
		<a href='https://www.ip-tracker.org/locator/ip-lookup.php?ip=$IP1' target='_blank'>$IP1</a>
		</td>
		<td class='text_center_link' style='width: 30%'>
		<span class='text_center_link'>
		<a href='http://$IP1' target='_blank'>$HTTP_TEXT</a></span></td>
		<td style='width: 30%' class='text_center_link'>
		<a href='ftp://$IP1' target='_blank'>$FTP_TEXT</a></td>
</tr></table>"

			if [ "$DU" != 0 ]
			then
				echo "$HTML" >> "ftp/$IP_FILE.htm"
			fi
		fi

		echo "[$TIME] - $IP1 - $STATUS_HTTP$STATUS_FTP$TEXT_LOG1"
	fi
}

run()
{
	IP="$1"
	ping -c 5 -W 2 $IP -q > /dev/null
	STATUS="$?"

	if [ $STATUS == 0 ]
	then
		#echo "IP $IP ativo"
		test_protocols "$IP"
	fi
}

while true
do
	#echo "$A.$B.$C.$D"
	increase

	TEST="`cat /proc/meminfo | grep MemFree`"
	TEST=${TEST/"MemFree:"/}
	TEST=${TEST/" kB"/}

	if [ $TEST -lt $MIN_RAM ]
	then
		sleep 1
	else
		#if [ -f "ftp/ip/$A.$B.$C.$D/http.htm" ]
		#then
		#	echo "Ignoring: $A.$B.$C.$D" &
		#else
			run "$A.$B.$C.$D" &
		#fi
	fi
done

