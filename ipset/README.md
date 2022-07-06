# Zabbix IPset Template

## Zabbix template for ipset monitoring.

## Author: Maxim Stepanuk (stepanukmaxim@icloud.com)

### Requires

Zabbix >=3.4 (because the template uses dependent items and value preprocessing features that were introduced in 3.4)

### Metrics

|      Metric      | Description                                                                        |
| ipset.discovery  | Automatically recognize ipsets on the server                                       |
|------------------|------------------------------------------------------------------------------------|
| ipset.newmembers | Showing new blocked ip addresses in the ipset list (applies only to ipset timeout) |
|                  | Example:                                                                           |
|                  | ipset create <name_ipset> hash:ip (hash:net) timeout 3600                          |
|------------------|------------------------------------------------------------------------------------|
| ipset.members    | Show membership in ipsets                                                          |
|------------------|------------------------------------------------------------------------------------|
| ipset.service    | Status service                                                                     |
|------------------|------------------------------------------------------------------------------------|

### Triggers

|     Trigger           |  Description                                                                  |
| IP blocked            | IP blocked for time in ipset                                                  |
| IPset service is down | Status service                                                                |

## Installation

You need to configure servers as shown below:

Copy "ipset.conf" into your zabbix_agent include folder (default: /etc/zabbix/zabbix_agentd.d/) or manually add that UserParameter to config:

UserParameter=ipset.discovery, sudo ipset list | grep Name | sed 's/\r/ /' | cut -d' ' -f2 | sed ':a;N;$!ba;s/\n/, /g' | sed -e 's/^.*:\W\+//' -e 's/\(\w\+[^, ]*\)/{"{#IPSET}":"\1"}/g' -e 's/.*/{"data":[\0]}/'
UserParameter=ipset.newmembers[*], sudo ipset list $1 | grep -A 100 "Members:" | grep -v "Members:" | grep "35..$" | cut -d' ' -f1
UserParameter=ipset.members[*], sudo ipset list $1 | grep -A 100 "Members:" | grep -v "Members:" | cut -d' ' -f1
UserParameter=ipset.service, systemctl status ipset | grep -q running;echo $?

Restart zabbix_agent

Copy "zbx_ipset.sudoers" into /etc/sudoers.d or manually add that rule:

zabbix  ALL=NOPASSWD: /usr/sbin/ipset list
zabbix  ALL=NOPASSWD: /usr/sbin/ipset list *

Import "template_ipset.xml" into zabbix as template

## Testing

zabbix_get -s <ip> -k 'ipset.discovery'
zabbix_get -s <ip> -k 'ipset.members["<name_ipset>"]'
zabbix_get -s <ip> -k 'ipset.service'
