logstash-modsecurity
====================

Modsecurity audit log ingestor configuration for Logstash

**author**: bitsofinfo.g[at]gmail.com

### Overview 

Tested and running in production environments w/ logstash v.1.3.3 and v1.4.1+ (does NOT work with Logstash 1.4.0)

see: http://logstash.net/

see: https://github.com/SpiderLabs/ModSecurity/wiki/ModSecurity-2-Data-Formats

see: http://bitsofinfo.wordpress.com/2013/09/19/logstash-for-modsecurity-audit-logs/

license: http://www.apache.org/licenses/LICENSE-2.0

### Overview

This example configuration file has been used as the basis to process many ModeSecurity audit logs with lots of different variance in regards to which A-K sections are present. At a minimum this is a good starting point to start tackling a complex log format and you can customize it to you needs.

Also note that ModSecurity Audit logs can definately contains some very sensitive data (like user passwords etc). So you might want to also take a look at using Logstash's Cipher filter to secure certain message fields in transit if you are sending these processed logs somewhere else: [http://bitsofinfo.wordpress.com/2014/06/25/encrypting-logstash-data/](http://bitsofinfo.wordpress.com/2014/06/25/encrypting-logstash-data/)

You should not need to, however IF you go ahead and EDIT the custom ruby filter blocks, please be aware of https://logstash.jira.com/browse/LOGSTASH-1375 as if you introduce any error into the custom ruby blocks, one single error for one event, will take down the whole pipeline.

This config file for whatever reason will not run if you try to add the "-- web" option onto the logstash flat jar. This has been reported to the developers. Recommend you run this without the "-- web" option and just hook up Kibana separately.

Also recommend you start logstash like "java -jar logstash-x.x.x-flatjar.jar agent -v -f /yourConf.conf"  The "-v" will give verbose output and help you debug issues. Also DON'T run in "-v" mode in a prod environment as you will end up outputting a ton of data to your console and/or logstash stdout capture file. (if you have one)

Further note for Centos/Red Hat/Fedora Systems
----------------------------------------------

If logstash has been installed from the logstash repository (http://www.logstash.net/docs/1.4.2/repositories), follow these steps:

1. Set the path in logstash-modsecurity.conf to path => "/var/log/httpd/modsec_audit.log"
2. Copy logstash-modsecurity.conf to /etc/logstash/conf.d
3. Copy logstash_modsecurity_patterns to /opt/logstash/patterns/
4. Give read access to the logstash user on /var/log/httpd/modsec_audit.log

`setfacl -m u:logstash:r /var/log/httpd/modsec_audit.log

5. Restart the logstash agent

`systemctl restart logstash

6. Confirm mod_security messages are logged to standard output

`tail -f /var/log/logstash/logstash.stdout

