#!/bin/bash
rrdtool create hometemp2.rrd --start N --step 300 \
DS:temp2:GAUGE:600:U:U \
DS:outtemp:GAUGE:600:U:U \
RRA:AVERAGE:0.5:1:12 \
RRA:AVERAGE:0.5:1:288 \
RRA:AVERAGE:0.5:12:168 \
RRA:AVERAGE:0.5:12:720 \
RRA:AVERAGE:0.5:288:365 \
