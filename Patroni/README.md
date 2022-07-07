####### Zabbix Patroni Template

###A Zabbix template for patroni monitoring.

### Author: Maxim Stepanuk (stepanukmaxim@icloud.com)

## Requires

Zabbix >=3.4 (because the template uses dependent items and value preprocessing features that were introduced in 3.4)

##Metrics
|      Metric      | Description                                                                        |
|------------------|------------------------------------------------------------------------------------|
| ipset.discovery  | Automatically recognize ipsets on the server                                       |


##Triggers
|     Trigger                  |  Description                         |
|------------------------------|--------------------------------------|
| Change patroni role          | Change role Master/Replica           |
| IPset service is down        | Status service                       |
| Change patroni configuration | 
| Change patroni leader        | 

##Installation

You need to configure servers as shown below:

Copy "patroni.conf" into your zabbix_agent include folder (default: /etc/zabbix/zabbix_agentd.d/) or manually add that UserParameter to config:

> ***UserParameter***=patroni.info[*], curl -s http://$1:$2/patroni
> ***UserParameter***=patroni.config[*], curl -s http://$1:$2/config
> ***UserParameter***=patroni.cluster[*], curl -s http://$1:$2/cluster
> ***UserParameter***=patroni.history[*], curl -s http://$1:$2/history
> ***UserParameter***=patroni.discovery[*], curl -s http://$1:$2/cluster | jq '.members[].name' | sed -e ':a;N;$$!ba;s/\n/ /g' -e s/\"//g -e 's/\(\w\+[^ ]*\)/{"{#MEMBERS}":"\1"}/g' -e 's/.*/{"data":[\0]}/' -e 's/ /,/g'
> ***UserParameter***=patroni.discoverymembers.lag[*], curl -s --get http://$2:$3/cluster | jq . | grep -A 8 -B 1 $1 | sed 's/},/}/g'
# If you use DCS=Consul
> ***UserParameter***=patroni.leader[*], curl --header "X-Consul-Token: $1" -s --get http://localhost:8500/v1/kv/service/$2/leader | jq -r '.[0]["Value"]' | base64 -d


Restart zabbix_agent



Import "template_patroni.xml" into zabbix as template

##Testing

zabbix_get -s <ip> -k 'ipset.discovery'
zabbix_get -s <ip> -k 'ipset.members["<name_ipset>"]'
zabbix_get -s <ip> -k 'ipset.service'
