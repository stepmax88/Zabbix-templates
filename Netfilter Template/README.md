![Certificate expiration date template](https://upload.wikimedia.org/wikipedia/commons/b/bf/Zabbix_logo.png "Certificate expiration date template")

# Zabbix Template Netfilter (ipset, iptables)

## Zabbix template for ipset and iptables monitoring.

## Author: Maxim Stepanuk (stepanukmaxim@icloud.com)

### Requires

Zabbix >=3.4 (because the template uses dependent items and value preprocessing features that were introduced in 3.4)

### Metrics
| Metric             | Description                                                                            |
|--------------------|----------------------------------------------------------------------------------------|
| ipset.discovery    | Automatically recognize ipsets on the server                                           |
| ipset.members      | Data item prototype: Shows available ipsets and its elements in the form of IP.        | 
|                    | Has two states Added and Removed                                                       |
| ipset.time_members | Data item prototype: Show added items as IP addresses in the ipset list and the amount |
|                    | of time remaining before it is removed from the list                                   |
|                    | (Automatically applies to ipset timeout only)                                          |
|                    | Example:                                                                               |
|                    | ipset create <name_ipset> hash:ip (hash:net) timeout 3600                              |
| service.netfilter  | Status service netfilter-persistant                                                    |
| service.ipset      | Status service ipset                                                                   |
| service.iptables   | Status service iptables                                                                |


### Triggers
| Trigger                                            | Description                                                    |
|----------------------------------------------------|----------------------------------------------------------------|
| {#IP} remove in {#IPSET} ipset                     | Trigger prototype: Removing an element from an ipset list      |
| {#IP} add in {#IPSET} ipset                        | Trigger prototype: Adding an item to an ipset list             |
| {#TIMEIP} add in ipset {#TIMEIPSET} on {#TIMEOUT}s | Trigger prototype: Adding an element to the ipset timeout list |
| IPset/IPtables/Netfilter service is down           | Status service                                                 |


## Installation

### You need to configure servers as shown below:

1. Copy "netfilter.conf" into your zabbix_agent include folder (default: /etc/zabbix/zabbix_agentd.d/) or manually 
add that UserParameter to config:


        UserParameter=ipset.discovery, /etc/zabbix/zabbix-netfilter.pl 2>/dev/null
        UserParameter=ipset.members[*],if [ "$2" = 'No members' ]; then echo '2'; else sudo ipset list $1 | grep -x "$2" | cut -d' ' -f1 | wc -l; fi
        UserParameter=ipset.time_members[*], sudo ipset list $1 | grep "$2" | cut -d' ' -f3
        UserParameter=service.netfilter, systemctl | grep "netfilter-persistent.service" | wc -l
        UserParameter=service.ipset, systemctl | grep "ipset.service" | wc -l
        UserParameter=service.iptables, systemctl | grep "iptables.service" | wc -l

2. Copy "zbx_netfilter.sudoers" into /etc/sudoers.d or manually add that rule:


        zabbix  ALL=NOPASSWD: /usr/sbin/ipset list
        zabbix  ALL=NOPASSWD: /usr/sbin/ipset list *

3. Import "template_netfilter.xml" into zabbix as template
4. Copy "zabbix-netfilter.pl" into /etc/zabbix
5. Restart zabbix_agent

## Testing

        zabbix_get -s <ip> -k 'ipset.discovery'

### EXAMPLE:


  {
        "data":[
        {
                "{#IPSET}":"<name_ipset>",
                "{#IP}":"<ip_addresses>"
        }
        ,
        {
                "{#TIMEIPSET}":"<name_ipset>",
                "{#TIMEIP}":"<ip_addresses>",
                "{#TIMEOUT}":"<ipset_timeout>"
        }
        ]
  }


        zabbix_get -s <ip> -k 'ipset.members["<name_ipset>","<ip_addresses>"]'
#
        zabbix_get -s <ip> -k 'service.netfilter'
#
        zabbix_get -s <ip> -k 'service.ipset'
#
        zabbix_get -s <ip> -k 'service.ipset'
