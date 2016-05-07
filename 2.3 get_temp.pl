#!/usr/bin/perl
use LWP::UserAgent;
 
my $dir = '/var/www/motion';
my $metar_url = 'http://weather.noaa.gov/pub/data/observations/metar/stations/EDDB.TXT';
my $is_celsius = 1; #set to 1 if using Celsius
 
my $ua = new LWP::UserAgent;
$ua->timeout(120);
my $request = new HTTP::Request('GET', $metar_url);
my $response = $ua->request($request);
my $metar= $response->content();
 
$metar =~ /([\s|M])(\d{2})\//g;
$outtemp = ($1 eq 'M') ? $2 * -1 : $2; #'M' in a METAR report signifies below 0 temps
$outtemp = ($is_celsius) ? $outtemp + 0 : ($outtemp * 9/5) + 32;
 
$modules = `cat /proc/modules`;
if ($modules =~ /w1_therm/ && $modules =~ /w1_gpio/)
{
        #modules installed
}
else
{
        $gpio = `sudo modprobe w1-gpio`;
        $therm = `sudo modprobe w1-therm`;
}
 
$outputAQ1 = "";
$outputAQ2 = "";
$outputAQ3 = "";
$outputAQ4 = "";
$outputAQ5 = "";
$attempts = 0;
while ($outputAQ1 !~ /YES/g && $attempts < 5)
{
        $outputAQ1 = `sudo cat /sys/bus/w1/devices/28-0316026252ff/w1_slave 2>&1`;
        if($outputAQ1 =~ /No such file or directory/)
        {
                print "Could not find DS18B20\n";
                last;
        }
        elsif($outputAQ1 !~ /NO/g)
        {
                $outputAQ1 =~ /t=(\d+)/i;

                $temp = ($is_celsius) ? ($1 / 1000) : ($1 / 1000) * 9/5 + 32;
                $rrd = `/usr/bin/rrdtool update $dir/hometemp.rrd N:$temp:$outtemp`;
        }
 
        $attempts++;
}
while ($outputAQ2 !~ /YES/g && $attempts < 5)
{
        $outputAQ2 = `sudo cat /sys/bus/w1/devices/28-0316025f66ff/w1_slave 2>&1`;
        if($outputAQ2 =~ /No such file or directory/)
        {
                print "Could not find DS18B20\n";
                last;
        }
        elsif($outputAQ2 !~ /NO/g)
        {
                $outputAQ2 =~ /t=(\d+)/i;
                $temp2 = ($is_celsius) ? ($1 / 1000) : ($1 / 1000) * 9/5 + 32;
                $rrd = `/usr/bin/rrdtool update $dir/hometemp2.rrd N:$temp2:`;
        }

        $attempts++;
}
 
while ($outputAQ3 !~ /YES/g && $attempts < 5)
{
        $outputAQ3 = `sudo cat /sys/bus/w1/devices/28-0316025d79ff/w1_slave 2>&1`;
        if($outputAQ3 =~ /No such file or directory/)
        {
                print "Could not find DS18B20\n";
                last;
        }
        elsif($outputAQ3 !~ /NO/g)
        {
                $outputAQ3 =~ /t=(\d+)/i;
                $temp3 = ($is_celsius) ? ($1 / 1000) : ($1 / 1000) * 9/5 + 32;
                $rrd = `/usr/bin/rrdtool update $dir/hometemp3.rrd N:$temp3:`;
        }

        $attempts++;
}
while ($outputAQ4 !~ /YES/g && $attempts < 5)
{
        $outputAQ4 = `sudo cat /sys/bus/w1/devices/28-0316025d6dff/w1_slave 2>&1`;
        if($outputAQ4 =~ /No such file or directory/)
        {
                print "Could not find DS18B20\n";
                last;
        }
        elsif($outputAQ4 !~ /NO/g)
        {
                $outputAQ4 =~ /t=(\d+)/i;
                $temp4 = ($is_celsius) ? ($1 / 1000) : ($1 / 1000) * 9/5 + 32;
                $rrd = `/usr/bin/rrdtool update $dir/hometemp4.rrd N:$temp4:`;
        }

        $attempts++;
}
while ($outputAQ5 !~ /YES/g && $attempts < 5)
{
        $outputAQ5 = `sudo cat /sys/bus/w1/devices/28-0316027c00ff/w1_slave 2>&1`;
        if($outputAQ5 =~ /No such file or directory/)
        {
                print "Could not find DS18B20\n";
                last;
        }
        elsif($outputAQ5 !~ /NO/g)
        {
                $outputAQ5 =~ /t=(\d+)/i;
                $temp5 = ($is_celsius) ? ($1 / 1000) : ($1 / 1000) * 9/5 + 32;
                $rrd = `/usr/bin/rrdtool update $dir/hometemp5.rrd N:$temp5:`;
        }

        $attempts++;
}

####system ("clear");
print "Pi Case Temp $temp C°\n";
print "TQ Department temp. $temp2 C°\n";
print "AQ Water Temp. $temp3\C°\n";
print "AQ Reverse Osmosis Tank $temp4 C°\n";
print "AQ rooftop $temp5 C°\n";
print "Berlin has an acutal outside temp. of  $outtemp C°\n";

