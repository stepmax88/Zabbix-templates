# Certificate expiration date Template

## Zabbix template for monitoring expiration date site certificate.

## Author: Maxim Stepanuk (stepanukmaxim@prostep.com.ua)

### Requires

Zabbix >=3.4 (because the template uses dependent items and value preprocessing features that were introduced in 3.4)

### Metrics
| Metric             | Description                                                                         |
|--------------------|-------------------------------------------------------------------------------------|
| ssl.discovery      | Automatically calculates the expiration date for sites from a macro                 |
| ssl.days           | Data item prototype: Shows the certificate expiration date for sites from the macro | 


### Triggers
| Trigger                                        | Description                                                                                                                         |
|------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| The certificate of the site expires after days | Trigger prototype: The expiration date of the site certificate is less than macros {$WARN_DAYS_SSL_CHECK} or {$HIGH_DAYS_SSL_CHECK} |


## Installation

You need to configure servers as shown below:

Copy "cert_expiration_date.conf" into your zabbix_agent include folder (default: /etc/zabbix/zabbix_agentd.d/) or 
manually add that UserParameter to config:

    UserParameter=ssl.discovery[*], echo "{\n\n\t\"data\":[\n\n$$(for h in $1; do echo "\t,\n\t{\n\t\t\"{#SITE}\":\"$$h\",\n \t\t\"{#DAYS_EXPIRE}\":\"$$(( ($$(date -d "$$(echo | openssl s_client -servername $$h -connect $$h 2>/dev/null | openssl x509 -noout -enddate | sed -e 's#notAfter=##')" '+%s') - $$(date '+%s')) / 86400 ))\"\n\t}"; done)\n\n\t]\n}\n" | sed -e '5d'
    UserParameter=ssl.days[*], echo -n $(( ($$(date -d "$$(echo | openssl s_client -servername $1 -connect $1 2>/dev/null | openssl x509 -noout -enddate | sed -e 's#notAfter=##')" '+%s') - $$(date '+%s')) / 86400 ))

*Note: Add the -e switch after echo if it doesn't work*

Restart zabbix_agent

Import "template_cert_expire_date.xml" into zabbix as template

## Testing

    zabbix_get -s <ip> -k 'ssl.discovery[amazon.com:443 google.com:443]'

*  {
        "data":[
        {
                "{#SITE}":"amazon.com:443",
                "{#DAYS_EXPIRE}":"56"
        }
        ,
        {
                "{#SITE}":"google.com:443",
                "{#DAYS_EXPIRE}":"60"
        }
        ]
    }*


    zabbix_get -s <ip> -k 'ssl.days[<site>:443]'