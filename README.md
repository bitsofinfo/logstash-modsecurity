logstash-modsecurity
====================

Example Modsecurity audit log ingestor configuration for Logstash

author bitsofinfo.g[at]gmail.com

built/tested w logstash v1.3.3 (does NOT work with Logstash 1.4, in process... waiting till 1.4.1 see: https://groups.google.com/d/msg/logstash-users/ACdShuxOFZY/ygMSk1M72-kJ)

see: http://logstash.net/

see: https://github.com/SpiderLabs/ModSecurity/wiki/ModSecurity-2-Data-Formats

see: http://bitsofinfo.wordpress.com/2013/09/19/logstash-for-modsecurity-audit-logs/

license: http://www.apache.org/licenses/LICENSE-2.0

NOTE: this is not perfect and I am no Ruby expert however this worked when processing quite a bit of high volume mod-sec logs with lots of different variations in what A-K sections were and were not present. At a minimum its a good starting point to start tackling a complex log format.

You should not need to, however IF you go ahead and EDIT the custom ruby filter blocks, please be aware of https://logstash.jira.com/browse/LOGSTASH-1375 as if you introduce any error into the custom ruby blocks, one single error for one event, will take down the whole pipeline.

This config file for whatever reason will not run if you try to add the "-- web" option onto the logstash flat jar. This has been reported to the developers. Recommend you run this without the "-- web" option and just hook up Kibana separately.

Also recommend you start logstash like "java -jar logstash-x.x.x-flatjar.jar agent -v -f /yourConf.conf"  The "-v" will give verbose output and help you debug issues. Also DON'T run in "-v" mode in a prod environment as you will end up outputting a ton of data to your console and/or logstash stdout capture file. (if you have one)



