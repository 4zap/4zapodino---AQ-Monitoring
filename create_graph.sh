
#!/bin/bash

#Arbeitsverzeichnis
DIR="/var/www/motion"
#farben fÃ¼r linie
temp_COLOR="#CC7016"
temp_shadow="#EC9D48"
temp1_COLOR="#1598C3"
temp1_shadow="#48C4EC"
temp2_COLOR="#CC3118"
temp2_shadow="#EA644A"
temp3_COLOR="#006600"
temp3_shadow="#33cc00"
temp4_COLOR="#24BC14"
temp4_shadow="#54EC48"

# starte perl skript zur Temperaturabfrage und DB Eintragung
echo suche DS18B20 Temperatur MessfÃ¼hler....     lese Werte......
aplay /var/www/motion/espeak/ansage.wav
espeak  -v mb-de5 "Starte_ Tempratur_ Messungn_" | mbrola -e /usr/share/mbrola/de5 - /tmp/mbrola.wav -s 80 -g 1 -p 6
aplay /var/www/motion/espeak/a11.wav
perl /var/www/motion/get_temp.pl
sleep 3
echo Werte erfasst... schreibe Werte in Round Robin Datenbank ...
sleep 1

#Ausgabe auf Grad Celsius setzen
TEMP_SCALE="C"
sleep 2

################################Alarmeinstellungen###################
echo "Ã¼berprÃ¼fe Werte auf evtl. Notfallbenachrichtigungen"
temp3=$(/usr/bin/rrdtool graph /dev/null --start -900  DEF:temp1average=/var/www/motion/hometemp3.rrd:temp3:AVERAGE PRINT:temp1average:AVERAGE:"%3.4lf"|tail -1)
temp3=$(echo "scale=2; $temp3/1" | bc |tr . ,)   # Umwandlung in ganze Zahl
temp2=$(/usr/bin/rrdtool graph /dev/null --start -900  DEF:temp1average=/var/www/motion/hometemp2.rrd:temp2:AVERAGE PRINT:temp1average:AVERAGE:"%3.4lf"|tail -1)
temp2=$(echo "scale=2; $temp2/1" | bc |tr . ,)   # Umwandlung in ganze Zahl
temp5=$(/usr/bin/rrdtool graph /dev/null --start -900  DEF:temp1average=/var/www/motion/hometemp5.rrd:temp5:AVERAGE PRINT:temp1average:AVERAGE:"%3.4lf"|tail -1)
temp5=$(echo "$temp5/1" | bc)   # Umwandlung in ganze Zahl
tempAQ=$(/usr/bin/rrdtool graph /dev/null --start -900 DEF:temp1average=/var/www/motion/hometemp3.rrd:temp3:AVERAGE PRINT:temp1average:AVERAGE"%3.4lf"|tail -1)
tempAQ=$(echo "$tempAQ/1" | bc)

#echo $temp3 | tr . ,
echo $temp3 " CÂ°"
echo $temp2 " C"
echo $temp5 " CÂ°"
echo $temoAQ

##########einzelne Temperaturen auf Status vergleichen

if [ $temp3 \> 26,2 ]
	then
		echo "Achtung, Temperatur Ã¼berprÃ¼fen,Level kritisch"
####Status Grafik hochladen auf öffentlichen Webserver
		curl -T /var/www/motion/alert_orange/temp_status.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_status.gif
####Datei lokal kopieren nach gembird/actual für live ansicht lokaler webserver
		cp /var/www/motion/alert_orange/temp_status.gif  /var/www/motion/gembird/actual/temp_status.gif
	elif [ $temp3 \< 24,2 ]
	then
		echo "Achtung, kÃ¼hlt ab! PrÃ¼fen!"
		aplay /var/www/motion/espeak/ds9intercom.wav
		espeak  -v mb-de5 "aquarium_kühlt_ab_die momentane_tempratur betrÃgt_"$temp3"_grad_celsius" | mbrola -e /usr/share/mbrola/de5/de5  - /tmp/mbrola.wav -s 200
		aÃ¼play /var/www/motion/espeak/a11.wav
		curl -T /var/www/motion/alert_blue/temp_blue.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_status.gif
		cp /var/www/motion/alert_blue/temp_blue.gif  /var/www/motion/gembird/actual/temp_status.gif
	elif [ $temp3 \> 27,3 ]
	then
		echo "Alarm!"
		curl -T /var/www/motion/alert_red/temp_status.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_status.gif
		cp /var/www/motion/alert_red/temp_status.gif  /var/www/motion/gembird/actual/temp_status.gif
	else
		echo "alles ok"
		aplay /var/www/motion/espeak/ansage.wav
		espeak  -v mb-de5 "Die_momentane_Aquarien_temperatur_betrÃ¤gt exackt_"$temp3"_grad_celsius" | mbrola -e /usr/share/mbrola/de5 - /tmp/mbrola.wav -s 90
		#                aplay /var/www/motion/espeak/a11.wav
		curl -T /var/www/motion/alert_green/temp_status.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_status.gif
		cp /var/www/motion/alert_green/temp_status.gif  /var/www/motion/gembird/actual/temp_status.gif
fi
if [ $temp2 \> 26,2 ]
	then
		echo "Achtung, Temperatur ueberpruefen, "temp" Level kritisch"
		curl -T /var/www/motion/alert_orange/temp_status.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempT_status.gif
		cp /var/www/motion/alert_orange/temp_status.gif /var/www/motion/gembird/actual/tempT_status.gif
	elif [ $temp2 \< 25 ]
	then
		echo "Achtung, kuehlt ab! Pruefen!"
		curl -T /var/www/motion/alert_blue/temp_blue.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempT_status.gif
		cp /var/www/motion/alert_blue/temp_blue.gif /var/www/motion/gembird/actual/tempT_status.gif
	elif [ $temp2 \> 28 ]
	then
		echo "Alarm!"
		curl -T /var/www/motion/alert_red/temp_alarm.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempT_status.gif
		cp /var/www/motion/alert_red/temp_alarm.gif /var/www/motion/gembird/actual/tempT_status.gif
	else
		echo "alles ok  x"
		#aplay /var/www/motion/espeak/ansage.wav
		espeak  -v mb-de5 "Die TemperaTur_im_Technik_Becken betrÄgt_eXakt_"$temp2"_grad_celsius" | mbrola -e /usr/share/mbrola/de5 - /tmp/mbrola.wav -s 90
		                aplay /var/www/motion/espeak/a11.wav
		curl -T /var/www/motion/alert_green/tempt_green.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempT_status.gif
		cp /var/www/motion/alert_green/tempt_green.gif /var/www/motion/gembird/actual/tempT_status.gif
fi

if [ $temp5 \> 27 ]
	then
		echo "alles ok. Temp bei "$temp5"CÂ° "
		curl -T /var/www/motion/alert_orange/tempa_critical.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempa_status.gif
		cp /var/www/motion/alert_orange/tempa_critical.gif /var/www/motion/gembird/actual/tempa_status.gif
	elif [ $temp5 \< 25	]
	then
		echo "Abdeckung kalt"
		curl -T /var/www/motion/alert_blue/tempa_blue.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempa_status.gif
		cp /var/www/motion/alert_blue/tempa_blue.gif /var/www/motion/gembird/actual/tempa_status.gif
	elif [ $temp5 \> 34 ]
	then
		echo "Abdeckung extrem warm. Pruefen!"
		curl -T /var/www/motion/alert_red/tempa_alarm.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempa_status.gif
		cp /var/www/motion/alert_red/tempa_alarm.gif /var/www/motion/gembird/actual/tempa_status.gif
	else
		echo "alles ok  x"
		curl -T /var/www/motion/alert_green/tempa_green.gif  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/tempa_status.gif
		cp /var/www/motion/alert_green/tempa_green.gif /var/www/motion/gembird/actual/tempa_status.gif
fi
echo Eintraege erfolgt ....erzeuge Temperaturkurven...

#Aquarium Wassertemperatur der letzten Stunde
rrdtool graph $DIR/temp_hourly.png \
--start -1h \
--step -2 \
--slope-mode \
--font DEFAULT:6: \
--title "Wassertemperatur der letzten Stunde" \
--watermark "`date`" \
--right-axis-label "Celsius" \
--upper-limit 27 --lower-limit 24 --rigid \
DEF:temp2=$DIR/hometemp2.rrd:temp2:AVERAGE \
LINE:temp2$temp1_COLOR:"Technikbecken                                          " \
GPRINT:temp2:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                     "  \
GPRINT:temp2:AVERAGE:"->Durchschnitt letzte Stunde \:%2.2lf°C                            "  \
GPRINT:temp2:MAX:"->Maximum letzte Stunde \:%2.2lf°C                                  "  \
DEF:temp5=$DIR/hometemp5.rrd:temp5:AVERAGE \
LINE:temp5$temp4_COLOR:"AQ Abdeckung Innen                                         " \
GPRINT:temp5:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp5:AVERAGE:"->Durchschnitt letzte Stunde \:%2.2lf°C                               "  \
GPRINT:temp5:MAX:"->Maximum letzte Stunde \:%2.2lf°C                                     "  \
DEF:temp3=$DIR/hometemp3.rrd:temp3:AVERAGE \
LINE:temp3$temp2_COLOR:"Aquarium                                               " \
GPRINT:temp3:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp3:AVERAGE:"->Durchschnitt letzte Stunde \:%2.2lf°C                            "  \
GPRINT:temp3:MAX:"->Maximum letzte Stunde \:%2.2lf°C                            "  \
GPRINT:temp3:MIN:"->Minimum letzte Stunde \:%2.2lf°C                            "  \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$temp_COLOR:"Gehaeusetemp. Raspberry PI                                      " \
GPRINT:temp:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp:MAX:"->Maximum letzte Stunde\:%2.2lf°C                            "  \
DEF:temp4=$DIR/hometemp4.rrd:temp4:AVERAGE \
LINE:temp4$temp3_COLOR:"Osmosetank                                           " \
AREA:temp4$temp3_shadow \
GPRINT:temp4:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp4:MAX:"->Maximum letzte Stunde\:%2.2lf°C   "  \


###Ã#TEST SCJATTEM
rrdtool graph $DIR/temp_hourly1.png \
--start -1h \
--step -2 \
--slope-mode \
DEF:temp4=hometemp4.rrd:temp4:AVERAGE \
AREA:temp4$temp3_shadow:"ffff\:%2.2lf " \
LINE1:temp4$temp3_COLOR:"fff\:%2.2lf " \


#Aquarium Wassertemperatur des letzen Tages
rrdtool graph $DIR/temp_all_daily.png \
--start -24h \
--slope-mode \
--font DEFAULT:6: \
--title "Wassertemperatur des letzen Tages" \
--watermark "`date`" \
--right-axis-label "Celsius" \
--upper-limit 32 --lower-limit 19 --rigid \
DEF:temp2=$DIR/hometemp2.rrd:temp2:AVERAGE \
LINE:temp2$temp1_COLOR:"Technikbecken                                          " \
GPRINT:temp2:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                     "  \
GPRINT:temp2:AVERAGE:"->Durchschnitt letzter Tag \:%2.2lf°C                            "  \
GPRINT:temp2:MAX:"->Maximum letzter Tag\:%2.2lf°C                                  "  \
DEF:temp5=$DIR/hometemp5.rrd:temp5:AVERAGE \
LINE:temp5$temp4_COLOR:"AQ Abdeckung Innen                                         " \
GPRINT:temp5:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp5:AVERAGE:"->Durchschnitt letzter Tag \:%2.2lf°C                               "  \
GPRINT:temp5:MAX:"->Maximum letzter Tag\:%2.2lf°C                                     "  \
DEF:temp3=$DIR/hometemp3.rrd:temp3:AVERAGE \
LINE:temp3$temp2_COLOR:"Aquarium                                               " \
GPRINT:temp3:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp3:AVERAGE:"->Durchschnitt letzter Tag \:%2.2lf°C                            "  \
GPRINT:temp3:MAX:"->Maximum letzter Tag\:%2.2lf°C                            "  \
GPRINT:temp3:MIN:"->Minimum letzter Tag \:%2.2lf°C                            "  \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$temp_COLOR:"Gehaeusetemp. Raspberry PI                                      " \
GPRINT:temp:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp:MAX:"->Maximum letzter Tag\:%2.2lf°C                            "  \
DEF:temp4=$DIR/hometemp4.rrd:temp4:AVERAGE \
LINE:temp4$temp3_COLOR:"Osmosetank                                           " \
GPRINT:temp4:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp4:MAX:"->Maximum letzter Tag\:%2.2lf°C                            "  \



#clear
echo ...erzeuge Graph fuer die letzte Woche
sleep 2
#Aquarium Wassertemperatur der letzten Woche
rrdtool graph $DIR/temp_all_weekly.png \
--start -1w \
--slope-mode \
--font DEFAULT:6: \
--title "Wassertemperatur der letzten Woche" \
--watermark "`date`" \
--right-axis-label "Celsius" \
--upper-limit 35 --lower-limit 18 --rigid \
DEF:temp2=$DIR/hometemp2.rrd:temp2:AVERAGE \
LINE:temp2$temp1_COLOR:"Technikbecken                                          " \
GPRINT:temp2:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                     "  \
GPRINT:temp2:AVERAGE:"->Durchschnitt letzte Woche \:%2.2lf°C                            "  \
GPRINT:temp2:MAX:"->Maximum letzte Woche \:%2.2lf°C                                  "  \
DEF:temp5=$DIR/hometemp5.rrd:temp5:AVERAGE \
LINE:temp5$temp4_COLOR:"AQ Abdeckung Innen                                         " \
GPRINT:temp5:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp5:AVERAGE:"->Durchschnitt letzte Woche  \:%2.2lf°C                               "  \
GPRINT:temp5:MAX:"->Maximum letzte Woche \:%2.2lf°C                                     "  \
DEF:temp3=$DIR/hometemp3.rrd:temp3:AVERAGE \
LINE:temp3$temp2_COLOR:"Aquarium                                               " \
GPRINT:temp3:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp3:AVERAGE:"->Durchschnitt letzte Woche  \:%2.2lf°C                            "  \
GPRINT:temp3:MAX:"->Maximum letzte Woche \:%2.2lf°C                            "  \
GPRINT:temp3:MIN:"->Minimum letzte Woche \:%2.2lf°C                            "  \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$temp_COLOR:"Gehaeusetemp. Raspberry PI                                      " \
GPRINT:temp:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp:MAX:"->Maximum letzte Woche \:%2.2lf°C                            "  \
DEF:temp4=$DIR/hometemp4.rrd:temp4:AVERAGE \
LINE:temp4$temp3_COLOR:"Osmosetank                                           " \
GPRINT:temp4:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp4:MAX:"->Maximum letzte Woche \:%2.2lf°C                            "  \

echo $temp3
#clear
echo .... erzeuge Graph fÃ¼r die letzten 30 Tage
sleep 2
#Aquarium Wassertemperatur des letzen Monats
rrdtool graph $DIR/temp_all_monthly.png \
--start -4w \
--slope-mode \
--font DEFAULT:6: \
--title "Wassertemperatur des letzen Monats" \
--watermark "`date`" \
--right-axis-label "temp" \
--upper-limit 34 --lower-limit 18 --rigid \
DEF:temp2=$DIR/hometemp2.rrd:temp2:AVERAGE \
LINE:temp2$temp1_COLOR:"Technikbecken                                          " \
GPRINT:temp2:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                     "  \
GPRINT:temp2:AVERAGE:"->Durchschnitt letzter Monat \:%2.2lf°C                            "  \
GPRINT:temp2:MAX:"->Maximum letzter Monat \:%2.2lf°C                                  "  \
DEF:temp5=$DIR/hometemp5.rrd:temp5:AVERAGE \
LINE:temp5$temp4_COLOR:"AQ Abdeckung Innen                                         " \
GPRINT:temp5:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp5:AVERAGE:"->Durchschnitt letzter Monat \:%2.2lf°C                               "  \
GPRINT:temp5:MAX:"->Maximum letzter Monat \:%2.2lf°C                                     "  \
DEF:temp3=$DIR/hometemp3.rrd:temp3:AVERAGE \
LINE:temp3$temp2_COLOR:"Aquarium                                               " \
GPRINT:temp3:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp3:AVERAGE:"->Durchschnitt letzter Monat \:%2.2lf°C                            "  \
GPRINT:temp3:MAX:"->Maximum letzter Monat \:%2.2lf°C                            "  \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$temp_COLOR:"Gehaeusetemp. Raspberry PI                                      " \
GPRINT:temp:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                  "  \
GPRINT:temp:MAX:"->Maximum letzter Monat \:%2.2lf°C                            "  \
DEF:temp4=$DIR/hometemp4.rrd:temp4:AVERAGE \
LINE:temp4$temp3_COLOR:"Osmosetank                                           " \
GPRINT:temp4:LAST:"->Aktuelle Temperatur\:%2.2lf°C                                   "  \
GPRINT:temp4:MAX:"->Maximum letzter Monat \:%2.2lf°C                            "  \
#clear
echo $temp3
echo erzeuge Graph fÃ¼r das letzte Jahr
sleep 2
#Aquarium Wassertemperatur des letzen Jahres
rrdtool graph $DIR/temp_all_year.png \
--start -1y \
--slope-mode \
--font DEFAULT:6: \
--title "Wassertemperatur des letzen Jahres" \
--watermark "`date`" \
--right-axis-label "temp" \
--upper-limit 34 --lower-limit 18 --rigid \
DEF:temp2=$DIR/hometemp2.rrd:temp2:AVERAGE \
LINE:temp2$temp1_COLOR:"Technikbecken                                          " \
GPRINT:temp2:AVERAGE:"->Durchschnitt letzte Stunde \:%2.2lf°C                            "  \
GPRINT:temp2:MAX:"->Maximum letzte Stunde \:%2.2lf°C                                  "  \
DEF:temp5=$DIR/hometemp5.rrd:temp5:AVERAGE \
LINE:temp5$temp4_COLOR:"AQ Abdeckung Innen                                         " \
GPRINT:temp5:AVERAGE:"->Durchschnitt letzte Stunde \:%2.2lf°C                               "  \
GPRINT:temp5:MAX:"->Maximum letzte Stunde \:%2.2lf°C                                     "  \
DEF:temp3=$DIR/hometemp3.rrd:temp3:AVERAGE \
LINE:temp3$temp2_COLOR:"Aquarium                                               " \
GPRINT:temp3:AVERAGE:"->Durchschnitt letzte Stunde \:%2.2lf°C                            "  \
GPRINT:temp3:MAX:"->Maximum letzte Stunde \:%2.2lf°C                            "  \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$temp_COLOR:"Gehaeusetemp. Raspberry PI                                      " \
GPRINT:temp:MAX:"->Maximum letzte Stunde\:%2.2lf°C                            "  \
DEF:temp4=$DIR/hometemp4.rrd:temp4:AVERAGE \
LINE:temp4$temp3_COLOR:"Osmosetank                                           " \
GPRINT:temp4:MAX:"->Maximum letzte Stunde\:%2.2lf°C                       " \

echo $temp3
echo Uebertrage Graphs auf Webserver knipsfisch.de ..... verbinde zu FTP Server ...
sleep 2
echo verbunden .... Ã¼bertrage Temperaturkurven auf Webseite
curl -T /var/www/motion/temp_hourly.png  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_hourly.png
curl -T /var/www/motion/temp_daily.png  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_daily.png
curl -T /var/www/motion/temp_all_daily.png  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_all_daily.png
curl -T /var/www/motion/temp_weekly.png  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_weekly.png
curl -T /var/www/motion/temp_all_weekly.png  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_all_weekly.png
curl -T /var/www/motion/temp_all_monthly.png  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_all_monthly.png
curl -T /var/www/motion/temp_all_year.png  ftp://w00fa94c:F7e9Z2NcHeP7meEQ@knipsfisch.de/wordpress/aq/temp_all_year.png

sudo $DIR/return_temp.sh
