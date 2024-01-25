#!/usr/bin/perl

use warnings FATAL => 'all';
use strict;

my $first = 1;
print "{\n";
print "\t\"data\":[\n\n";

for (`sudo ipset list | grep Name | sed 's/\r/ /' | cut -d' ' -f2`)
{
    (my $ipset_name) = m/(\S+)/;
    my $check_members = `sudo ipset list "$ipset_name" | grep "^[1-9]" | cut -d' ' -f1 | wc -l`;
    my $timeout_ipset = `sudo ipset list "$ipset_name" | grep "Header" | grep timeout | wc -l`;
    my $timeout = `sudo ipset list "$ipset_name" | grep "Header" | grep timeout | cut -d' ' -f9 | tr -d '\n'`;

    if($timeout_ipset > 0){
      if($check_members < 1){
      }
      else{
       for (`sudo ipset list "$ipset_name" | grep "^[1-9]" | cut -d' ' -f1`)
       {
       (my $ip) = m/(\S+)/;
           print "\t,\n" if not $first;
           $first = 0;
           print "\t{\n";
           print "\t\t\"{#TIMEIPSET}\":\"$ipset_name\",\n";
           print "\t\t\"{#TIMEIP}\":\"$ip\",\n";
           print "\t\t\"{#TIMEOUT}\":\"$timeout\"\n";
           print "\t}\n";
       }
      }
    }else{
      if($check_members < 1){
           print "\t,\n" if not $first;
           $first = 0;
           print "\t{\n";
           print "\t\t\"{#IPSET}\":\"$ipset_name\",\n";
           print "\t\t\"{#IP}\":\"No members\"\n";
           print "\t}\n";
      }
      else{
       for (`sudo ipset list "$ipset_name" | grep "^[1-9]" | cut -d' ' -f1`)
       {
       (my $ip) = m/(\S+)/;
           print "\t,\n" if not $first;
           $first = 0;
           print "\t{\n";
           print "\t\t\"{#IPSET}\":\"$ipset_name\",\n";
           print "\t\t\"{#IP}\":\"$ip\"\n";
           print "\t}\n";
       }
      }
    }
}

print "\n\t]\n";
print "}\n";