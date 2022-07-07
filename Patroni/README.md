# Zabbix Patroni Template

## Zabbix template for patroni monitoring.

### Author: Maxim Stepanuk (stepanukmaxim@icloud.com)

## Requires

Zabbix >=3.4 (because the template uses dependent items and value preprocessing features that were introduced in 3.4)

## Metrics
|      Metric                                      | Description                                                                        |
|--------------------------------------------------|------------------------------------------------------------------------------------|
| Patroni service is running                       |
| Patroni info: Patroni version                    |
| Patroni info: Patroni state.                     |
| Patroni info: Patroni scope.                     |
| Patroni info: Patroni role.                      |
| Patroni info: Patroni database_system_identifier |
| Patroni info: Patroni pending_restart            |
| Patroni config: Ttl                              | 
| Patroni config: Retry_timeout                    |
| Patroni config: Loop_wait                        |
| Patroni config: Maximum_lag_on_failover          |
| Patroni config: pql - work_mem                   |
| Patroni config: pql - shared_buffers             |
| Patroni config: pql - port                       |
| Patroni config: pql - maintenance_work_mem       |
| Patroni cluster: Name members        	           |                 |



## Triggers
|     Trigger                  |  Description                         |
|------------------------------|--------------------------------------|
| Change patroni role          | AVERAGE: Change role Master/Replica  |
| Patroni service is down      | HIGH: Status service                 |
| Change patroni configuration | INFO: Change configuration.          |
| Change patroni leader        | HIGH: Change leader                  |
| Change patroni version       | INFO: Change version                 |
| Change patroni state.        | AVERAGE: Change state members.       |

## Installation

You need to configure servers as shown below:

Copy "patroni.conf" into your zabbix_agent include folder (default: /etc/zabbix/zabbix_agentd.d/) or manually add that UserParameter to config:

> ***UserParameter***=patroni.info[*], curl -s http://$1:$2/patroni

> ***UserParameter***=patroni.config[*], curl -s http://$1:$2/config

> ***UserParameter***=patroni.cluster[*], curl -s http://$1:$2/cluster

> ***UserParameter***=patroni.history[*], curl -s http://$1:$2/history

> ***UserParameter***=patroni.discovery[*], curl -s http://$1:$2/cluster | jq '.members[].name' | sed -e ':a;N;$$!ba;s/\n/ /g' -e s/\"//g -e 's/\(\w\+[^ ]*\)/{"{#MEMBERS}":"\1"}/g' -e 's/.*/{"data":[\0]}/' -e 's/ /,/g'

> ***UserParameter***=patroni.members.lag[*], curl -s --get http://$2:$3/cluster | jq . | grep -A 8 -B 1 $1 | sed 's/},/}/g'

### If you use DCS=Consul
> ***UserParameter***=patroni.leader[*], curl --header "X-Consul-Token: $1" -s --get http://localhost:8500/v1/kv/service/$2/leader | jq -r '.[0]["Value"]' | base64 -d

Restart zabbix_agent
Import "template_patroni.xml" into zabbix as template

## Testing

> zabbix_get -s <ip> -k ''
  
> zabbix_get -s <ip> -k '["<name>"]'
  
> zabbix_get -s <ip> -k ''
