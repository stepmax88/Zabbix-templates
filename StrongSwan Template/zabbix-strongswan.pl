#!/usr/bin/perl

use warnings FATAL => 'all';
use strict;

my $first = 1;
print "{\n";
print "\t\"data\":[\n\n";

for (`cat /etc/swanctl/conf.d/*.conf | grep -PA2 "remote_addrs|conn" | grep -e " " | egrep -v "conn|local|fragmentation" | sed -e 's/{//' -e 's/remote_addrs =//' -e 's/ //g' | tr '\n' ' ' | paste -d ' ' | sed -e 's/%//g' | awk -v RS=' ' 'ORS = NR % 2 ? RS : "\t\t"' | tr '\t\t' '\n' | awk 'NF'`)
{
    (my $con_name, my $con_ip) = m/(\S+) (\S+)/;

    my $ip = `sudo swanctl -l -P -i $con_name | grep "remote-host" | sed -e "s/[^0-9.]//g"| tr -d '\n'`;
    my $con_state = `sudo swanctl -l -P -i $con_name | grep "remote-host" | sed -e "s/[^0-9.]//g" |  wc -l`;
    my $any = ( 'any' );
    if($con_state > 0){
       print "\t,\n" if not $first;
       $first = 0;
       print "\t{\n";
       print "\t\t\"{#CONNAME}\":\"$con_name\",\n";
       print "\t\t\"{#CONIP}\":\"$ip\"\n";
       print "\t}\n";
    }elsif($con_ip = $any){
       $first = 0;
    }else{
       print "\t,\n" if not $first;
       $first = 0;
       print "\t{\n";
       print "\t\t\"{#CONNAME}\":\"$con_name\",\n";
       print "\t\t\"{#CONIP}\":\"$con_ip\"\n";
       print "\t}\n";
    }
}

print "\n\t]\n";
print "}\n";
