###Shell script to read values out of database, check values if alarm is needed, create graphs and upload images to webserver


#!/bin/bash
#Word Dir
DIR="/var/www/motion"
#line colours for the array
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

# start perl script get_temp.pl to read values
echo "starting perl script...reading values...."
perl /etc/rrd/get_temp.pl

#define Grad Celsius
TEMP_SCALE="C"

################################reading database values###################
echo "compare related values if further actions needed"
temp3=$(/usr/bin/rrdtool graph /dev/null --start -900  DEF:temp1average=/var/www/motion/hometemp3.rrd:temp3:AVERAGE PRINT:temp1average:AVERAGE:"%3.4lf"|tail -1)
temp3=$(echo "scale=2; $temp3/1" | bc)   
temp2=$(/usr/bin/rrdtool graph /dev/null --start -900  DEF:temp1average=/var/www/motion/hometemp2.rrd:temp2:AVERAGE PRINT:temp1average:AVERAGE:"%3.4lf"|tail -1)
temp2=$(echo "$temp2/1" | bc)   
temp5=$(/usr/bin/rrdtool graph /dev/null --start -900  DEF:temp1average=/var/www/motion/hometemp5.rrd:temp5:AVERAGE PRINT:temp1average:AVERAGE:"%3.4lf"|tail -1)
temp5=$(echo "$temp5/1" | bc)   
tempAQ=$(/usr/bin/rrdtool graph /dev/null -- start -900 DEF:temp1average=/var/www/motion/hometemp3.rrd:temp3:AVERAGE PRINT:temp1average:AVERAGE"%2.1lf"|tail -1)
tempAQ=$(echo "$tempAQ/1" | bc)



if [ $temp3 \> 26,2 ]
	then
		echo "Warning, temperature rising"
		#ADD ACTION HERE...... you can use sendmail and other tools to setup notifications to alert
		
	elif [ $temp3 \< 24,2 ]
	then
		echo "Temperature is cooling down! Check!"
		#ADD ACTION HERE...... you can use sendmail and other tools to setup notifications to alert
	elif [ $temp3 \> 27,3 ]
	then
		echo "Alarm!"
		#ADD ACTION HERE...... you can use sendmail and other tools to setup notifications to alert

	else
		echo "all ok"
		#ADD ACTION HERE...... you can use sendmail and other tools to setup notifications to alert
fi


#creating graph for the last hour
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
echo "transit graphs to website"

curl -T /var/www/motion/temp_hourly.png  ftp://ftpuser:ftppassword@yourdomain.com/temp_hourly.png
curl -T /var/www/motion/temp_daily.png  ftp://ftpuser:ftppassword@yourdomain.com/temp_daily.png
curl -T /var/www/motion/temp_all_daily.png  ftp://ftpuser:ftppassword@yourdomain.com/temp_all_daily.png
curl -T /var/www/motion/temp_weekly.png  ftp://ftpuser:ftppassword@yourdomain.com/temp_weekly.png
curl -T /var/www/motion/temp_all_weekly.png  ftp://ftpuser:ftppassword@yourdomain.com/temp_all_weekly.png
curl -T /var/www/motion/temp_all_monthly.png  ftp://ftpuser:ftppassword@yourdomain.com/temp_all_monthly.png
curl -T /var/www/motion/temp_all_year.png  ftp://ftpuser:ftppassword@yourdomain.com/temp_all_year.png

sudo /etc/return_temp.sh &

