#!/bin/bash

#DNS server to request
TARGETIP=141.1.1.1  
#request on which port the USB Camera is connected
echo ".... send initial request to get webcam status..."
bs=`lsusb | grep Logitech | cut -c5-7`
dve=`lsusb | grep Logitech | cut -c16-18`
	echo "Webcam connected to BUS" $bs ", port" $dve
	echo "Webcam ready, setting parameter and options...."
		sleep 2
		
# take image in  high resolution and save it as a image file - modify the path as you need		
fswebcam -v -r 2048x1488 -s 5 --jpeg 95 /var/www/motion/lastpic.jpg
		sleep 2
# checking internet connection	
ping -c4 ${TARGETIP} > /dev/null               
                                               
if [ $? != 0 ]                               
	then                                         
		echo "ok...checking network connection...WiFi seems down, restarting USB Device..."
		ifdown --force wlan0                     
		ifup wlan0                               
	else                                        
		echo "ok...checking network connection ... WiFi seems up."           
fi

#upload image with curl ftp to the public webserver
	echo "connecting to public webserver... submitting last shot..."
		sleep 1                                  
			curl -T /var/www/motion/lastpic.jpg  ftp://ftpuser:ftppassword@yourdomain.fr/lastpic.jpg
			curl -T /var/www/motion/lastpic.jpg  ftp://ftpuser:ftppassword@yourdomain.fr/siko/liveview_`date +_%Y_%m_%d_%H-`00.jpg
		sleep 1
		
#reset USB Port connected to webcam. look at https://gist.github.com/x2q/5124616 for implementing "usbreset" first!		
	echo "...done .... force to reset USB Port" 
		sleep 2
sudo usbreset /dev/bus/usb/$bs/$dve
		sleep 25
#restarting shell in background after 25sec. rest		
sudo /etc/start_webcam.sh &
