![](https://upload.wikimedia.org/wikipedia/commons/b/bf/Zabbix_logo.png)

# Zabbix Patroni Template

## Zabbix template for patroni monitoring.

### Author: Maxim Stepanuk (stepanukmaxim@prostep.com.ua)

## Requires

Zabbix >=3.4 (because the template uses dependent items and value preprocessing features that were introduced in 3.4)

## Metrics (version 2)
| Metric                                           | Description                                                                       |
|--------------------------------------------------|-----------------------------------------------------------------------------------|
| Patroni service is running                       | Status service                                                                    |
| Patroni info: Patroni version                    | Version Patroni app                                                               |
| Patroni info: Scope                              | Patroni cluster name                                                              |
| Patroni info: Patroni database_system_identifier | Database System ID                                                                |
| Patroni info: Patroni pending_restart            | True or False                                                                     |
| Patroni config: Ttl                              | Period of time before the automatic fail-over process starts                      |
| Patroni config: Retry_timeout                    | Timeout for retrying DCS and Postgres operations                                  |
| Patroni config: Loop_wait                        | The number of seconds the loop will sleep                                         |
| Patroni config: Maximum_lag_on_failover          | The maximum bytes a follower may lag to be able to participate in leader election |
| Patroni config: Work_mem                         | Sets the base maximum memory size                                                 |
| Patroni config: Shared_buffers                   | Memory that the db server will use for shared memory buffers                      |
| Patroni config: Port                             | TCP port that the server is listening on                                          |
| Patroni config: Maintenance_work_mem             | Sets the max amount of mem for database maintenance operations                    |
| Patroni history                                  |                                                                                   | 
| Patroni leader (Consul)                          |                                                                                   |
| (Prototype) Patroni state: (node)                | Patroni state running/streaming                                                   |
| (Prototype) Patroni role: (node)                 | Patroni role leader/replica/sync_standby                                          |
| (Prototype) Patroni lag: (node - role)           | Replication delay                                                                 | 


## Triggers (version 2)
| Trigger                                                    | Description                               |
|------------------------------------------------------------|-------------------------------------------|
| Change patroni database_system_identifier                  | INFO: Change DB_ID                        |
| Change patroni version                                     | INFO: Change version                      |
| Patroni configuration changed to {HOST.NAME}               | AVERAGE: Change configuration             |
| Patroni pending restart                                    | AVERAGE: Patroni node need restart        |
| Patroni service is down on {HOST.NAME}                     | HIGH: Status service                      | 
| (Prototype) Patroni lags {#NODE_NAME}                      | HIGH: Excess size maximum_lag_on_failover | 
| (Prototype) Change patroni leader: New leader {#NODE_NAME} | HIGH: Change leader                       |


## Installation (version 2)

1. Import "version 2/patroni_template.xml" into zabbix as template
2. Configure macros {$LISTEN_PORT_PATRONI},{$LISTEN_IP_PATRONI},{$CONSUL.URL},{$CONSUL.TOKEN},{$CONSUL.PATRONI_SERVICE_NAME}

## HOW TO DISCOVERY MEMBERS PATRONI

1. Main data element - Patroni Cluster (HTTP agent)

2. Preprocessing (JavaScript)



        var data = JSON.parse(value);
        result = { "data": []};
        data.members.forEach(function (member) {
            result.data.push({   
            "{#NODE_STATE}": member.state,
            "{#NODE_API_URL}": member.api_url,
            "{#NODE_PORT}": member.port,
            "{#NODE_TIMELINE}": member.timeline,
            "{#NODE_HOST}": member.host,
            "{#NODE_NAME}": member.name,
            "{#NODE_ROLE}": member.role
            });
        });
        return JSON.stringify(result);


## Installation (version 1)

You need to configure servers as shown below:

1. Copy "patroni.conf" into your zabbix_agent include folder (default: /etc/zabbix/zabbix_agentd.d/) or manually add that UserParameter to config:
 

        UserParameter=patroni.info[*], curl -s http://$1:$2/patroni
        UserParameter=patroni.config[*], curl -s http://$1:$2/config
        UserParameter=patroni.cluster[*], curl -s http://$1:$2/cluster
        UserParameter=patroni.history[*], curl -s http://$1:$2/history
        UserParameter=patroni.discovery[*], curl -s http://$1:$2/cluster | jq '.members[].name' | sed -e ':a;N;$$!ba;s/\n/ /g' -e s/\"//g -e 's/\(\w\+[^ ]*\)/{"{#MEMBERS}":"\1"}/g' -e 's/.*/{"data":[\0]}/' -e 's/ /,/g'
        UserParameter=patroni.members.lag[*], curl -s --get http://$2:$3/cluster | jq . | grep -A 8 -B 1 $1 | sed 's/},/}/g'

##### If you use DCS=Consul
    UserParameter=patroni.leader[*], curl --header "X-Consul-Token: $1" -s --get http://localhost:8500/v1/kv/service/$2/leader | jq -r '.[0]["Value"]' | base64 -d

2. Import "version 1/patroni_template.xml" into zabbix as template
3. Restart zabbix_agent

## Testing
  
    zabbix_get -s <ip> -k '["<name>"]'

