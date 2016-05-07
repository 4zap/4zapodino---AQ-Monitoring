# 4zapodino---AQ-Monitoring
AQ Control and Monitoring of a saltwater tank

This is a privat project on a raspberry pi2 - raspian wheezy
It is a low budget project which need no expensive hardware.
The biggest investment is your time to get this running.

in this repository i collect all my scripts and steps i made to monitor my saltwater AQ tank as easy as possible in a digital way. Maybe it will help you to setup your own project. 


Functions status:

- Live image AQ intervall, visible on my public website
- Live image with date and time save as a copy ( i will make some timelaps movies out of them later ...)
- measuring temperatures in the main tank, technical tank, refill tank, raspberry case - submit status to public website, create temperature graphs and save longterm in a database. submit graphs to public website
- measuring EC and pH Values, handled like temperature values (in preparation)
- measuring water level in the single tanks (in preperation)
- switch and control the electric devices -> lights, heater, refill water, cooling fans, skimmer
- switch manually all devices on an website interface
- sending alarm messages in case of technical failures, flooding or overheating (works on the basic...must be expanded)
- 

Still thinking about:
- connecting UMTS/LTE Stick as fallback for the internet landline. Adds easy SMS functions for alarm messages
- using a medical dose pump to keep the pH stable high, refill soluted Mg,Ca,etc.
- add control for cooling fans above the tank
- adding LED controllers to my cidly aquabars to control & dimm
- writing an smartphone app to access my 4zapodino worldwide (after some securitry modifications)


Attention please!: I am using the whole project in an completly local network enviroment. There is no way to access my raspberrys from outside my network. So there was no need for me to tighten up my security against the services running on my raspian. If you want to use this in an public enviroment i take no responsability for your rasbperrys health. Make sure you are able to modify this code and the raspberry as you need it not to get hacked. Maybe consider the use of SFTP instead FTP....and such things...

