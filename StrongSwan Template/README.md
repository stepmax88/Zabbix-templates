# Zabbix Strongswan Template

## Zabbix template for ipsec monitoring.

## Author: Maxim Stepanuk (stepanukmaxim@icloud.com)

### Requires

Zabbix >=3.4 (because the template uses dependent items and value preprocessing features that were introduced in 3.4)

### Metrics
| Metric          | Description                                  |
|-----------------|----------------------------------------------|
| ipsec.discovery | Automatically recognize ipsecs on the server |
| ipsec.conname   | Show ipsec connection name                   |
| ipsec.conip     | Show ipsec remote IP addresses               |
| ipsec.state     | Show status ipsec connection in strongswan   |
| ipsec.ping      | Show status remote client                    |


### Triggers
| Trigger                  | Description                                                                              |
|--------------------------|------------------------------------------------------------------------------------------|
| IPSEC VPN is down on ... | Prototype trigger: Status ipsec connections down Critical/higt/warning                   |
|                          | If you need a special emergency/high notification for special IPsec connections,         |
|                          | such as site-to-site or site-to-client, in the macro value, you need to specify the name |
|                          | of the IPsec connection or an expression such as (ˆDC*, Site* ...)                       |
|                          | by default all notifications are warning                                                 |
|                          | Macros: {$NAME_IPSEC_CRITICAL} and {$NAME_IPSEC_HIGH}                                    | 
| IPsec process is down    | Status service                                                                           |



## Installation

You need to configure servers as shown below:

Copy "strongswan.conf" into your zabbix_agent include folder (default: /etc/zabbix/zabbix_agentd.d/) or manually add that UserParameter to config:

> ***UserParameter***=ipsec.discovery,/etc/zabbix/zabbix-conip.pl 2>/dev/null

> ***UserParameter***=ipsec.conname[*],cat /etc/swanctl/conf.d/*.conf | grep -vE "(^#|^$)" | grep -A1 "conn" | egrep -v "conn|--" | sed -e "s/[ {]//g" | grep $1

> ***UserParameter***=ipsec.conip[*],sudo swanctl -l -P -i $1 | grep "remote-host" | sed -e "s/[^0-9.]//g"

> ***UserParameter***=ipsec.ping[*],fping -r 5 $1 2>/dev/null | grep alive | wc -l

> ***UserParameter***=ipsec.state[*],sudo swanctl -l -P -i $1 | grep "state = INSTALLED" | wc -l

Restart zabbix_agent

Copy "zbx_ipsec.sudoers" into /etc/sudoers.d or manually add that rule:

> zabbix    ALL=(ALL:ALL) NOPASSWD:/usr/sbin/swanctl

Import "strongswan_template.xml" into zabbix as template

## Testing

> zabbix_get -s <ip> -k 'ipsec.discovery'

## EXAMPLE:
###  {
###        "data":[
###        {
###                "{#CONNAME}":"<name_ipsec>",
###                "{#CONIP}":"<ip_addresses>"
###        }
###        ,
###        {
###                "{#CONNAME}":"<name_ipsec>",
###                "{#CONIP}":"<ip_addresses>"
###        }
###        ]
###   }

> zabbix_get -s <ip> -k 'ipsec.state["<name_ipsec>"]'

> zabbix_get -s <ip> -k 'ipsec.service'
