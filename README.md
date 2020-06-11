logstash-modsecurity
====================

Modsecurity audit log ingestor configuration for Logstash

### Releases

[Version 1.4.0](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.4.0): see: [PR #48](https://github.com/bitsofinfo/logstash-modsecurity/pull/48), [PR #49](https://github.com/bitsofinfo/logstash-modsecurity/pull/49)

[Version 1.3.0](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.3.0): Fixes issues w/ Logstash 7.x see: [PR #46](https://github.com/bitsofinfo/logstash-modsecurity/pull/46)

[Version 1.2.2](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.2.2): Adds compatibility for ModSecurity 2.9.1+, should still be compatible w/ audit logs produced by <= 2.9.0. See [#34](https://github.com/bitsofinfo/logstash-modsecurity/issues/34) and [PR #42](https://github.com/bitsofinfo/logstash-modsecurity/pull/42)

[Version 1.2.1](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.2.1): Various Logstash 5.x fixes

[Version 1.2](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.2): For the logstash 5.x line

[Version 1.1.1](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.1.1): Fix for logstash versions up to 2.x line

[Version 1.1](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.1): Minor fixes for 1.5.x. Works with Logstash 1.3.3, 1.4.1+, 1.5.x+. Single monolithic configuration file.

[Version 1.0](https://github.com/bitsofinfo/logstash-modsecurity/releases/tag/1.0): Works with Logstash 1.3.3 and 1.4.1+ (NOT 1.5.x). Single monolithic configuration file.

MASTER/TRUNK: In-progress.

### Links

see: http://logstash.net/  
see: http://www.slideshare.net/prajalkulkarni/attack-monitoring-using-elasticsearch-logstash-and-kibana  
see: https://github.com/SpiderLabs/ModSecurity/wiki/ModSecurity-2-Data-Formats  
see: http://bitsofinfo.wordpress.com/2013/09/19/logstash-for-modsecurity-audit-logs/  

license: http://www.apache.org/licenses/LICENSE-2.0

### Overview

This example (working) configuration file has been used as the basis to process millions of ModeSecurity audit logs with lots of different variance in regards to which A-K sections are present. At a minimum this is a good starting point to start tackling a complex log format and you can customize it to you needs.

Also note that ModSecurity Audit logs can definately contains some very sensitive data (like user passwords etc). So you might want to also take a look at using Logstash's Cipher filter to secure certain message fields in transit if you are sending these processed logs somewhere else: [http://bitsofinfo.wordpress.com/2014/06/25/encrypting-logstash-data/](http://bitsofinfo.wordpress.com/2014/06/25/encrypting-logstash-data/)

You should not need to, however IF you go ahead and EDIT the custom ruby filter blocks, please be aware of https://logstash.jira.com/browse/LOGSTASH-1375 as if you introduce any error into the custom ruby blocks, one single error for one event, will take down the whole pipeline.

This config file for whatever reason will not run if you try to add the "-- web" option onto the logstash flat jar. This has been reported to the developers. Recommend you run this without the "-- web" option and just hook up Kibana separately.

Also recommend you start logstash like "java -jar logstash-x.x.x-flatjar.jar agent -v -f /yourConf.conf"  The "-v" will give verbose output and help you debug issues. Also DON'T run in "-v" mode in a prod environment as you will end up outputting a ton of data to your console and/or logstash stdout capture file. (if you have one)

### How to use the modularized configuration

The logstash configuration for Modsecurity is split into several configuration files to allow the user to select exactly those parts, he needs for his use-case, while still maintain compatibility with the upstream configuration, provided in this Github repository.

There are two ways to deploy logstash-modsecurity:

1. Concatenate the needed parts of the logstash-modsecurity configuration to a logstash configuration file.
2. Create symlinks in the logstash configuration directory to the needed files.

In the second case Logstash has to be pointed to the directory where the configuration including the symlinks is residing. The configuration files (including the symlinks) are then read and concatenated by logstash in lexicographical order.

The deployment process is supported by the provided script `deploy.sh`.

Further note for Centos/Red Hat/Fedora Systems
----------------------------------------------

If logstash has been installed from the logstash repository (http://www.logstash.net/docs/1.4.2/repositories), follow these steps:

1. Set the path in logstash-modsecurity.conf to path => "/var/log/httpd/modsec_audit.log"
2. Copy logstash-modsecurity.conf to /etc/logstash/conf.d
3. Copy logstash_modsecurity_patterns to /opt/logstash/patterns/
4. Give read access to the logstash user on /var/log/httpd/modsec_audit.log

`setfacl -m u:logstash:r /var/log/httpd/modsec_audit.log`

5. Restart the logstash agent

`systemctl restart logstash`

6. Confirm mod_security messages are logged to standard output

`tail -f /var/log/logstash/logstash.stdout`


### Sample output event
```
{
  "@timestamp": "2013-09-17T09:46:16.088Z",
  "@version": "1",
  "host": "razzle2",
  "path": "/Users/bof/who2/zip4n/logstash/modseclogs/proxy9/modsec_audit.log.1",
  "tags": [
    "multiline"
  ],
  "rawSectionA": "[17/Sep/2013:05:46:16 --0400] MSZkdwoB9ogAAHlNTXUAAAAD 192.168.0.9 65183 192.168.0.136 80",
  "rawSectionB": "POST /xml/rpc/soapservice-v2 HTTP/1.1\nContent-Type: application/xml\nspecialcookie: tb034=\nCache-Control: no-cache\nPragma: no-cache\nUser-Agent: Java/1.5.0_15\nHost: xmlserver.intstage442.org\nAccept: text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2\nConnection: keep-alive\nContent-Length: 93\nIncoming-Protocol: HTTPS\nab0044: 0\nX-Forwarded-For: 192.168.1.232",
  "rawSectionC": {
    "id": 2,
    "method": "report",
    "stuff": [
      "kborg2@special292.org",
      "X22322mkf3"
    ],
    "xmlrpm": "0.1a"
  },
  "rawSectionF": "HTTP/1.1 200 OK\nX-SESSTID: 009nUn4493\nContent-Type: application/xml;charset=UTF-8\nContent-Length: 76\nConnection: close",
  "rawSectionH": "Message: Warning. Match of \"rx (?:^(?:application\\\\/x-www-form-urlencoded(?:;(?:\\\\s?charset\\\\s?=\\\\s?[\\\\w\\\\d\\\\-]{1,18})?)??$|multipart/form-data;)|text/xml)\" against \"REQUEST_HEADERS:Content-Type\" required. [file \"/opt/niner/modsec2/pp7.conf\"] [line \"69\"] [id \"960010\"] [msg \"Request content type is not allowed by policy\"] [severity \"WARNING\"] [tag \"POLICY/ENCODING_NOT_ALLOWED\"]\nApache-Handler: party-server-time2\nStopwatch: 1379411176088695 48158 (1771* 3714 -)\nProducer: ModSecurity for Apache/2.7 (http://www.modsecurity.org/); core ruleset/1.9.2.\nServer: Whoisthat/v1 (Osprey)",
  "modsec_timestamp": "17/Sep/2013:05:46:16 --0400",
  "uniqueId": "MSZkdwoB9ogAAHlNTXUAAAAD",
  "sourceIp": "192.168.0.9",
  "sourcePort": "65183",
  "destIp": "192.168.0.136",
  "destPort": "80",
  "httpMethod": "POST",
  "requestedUri": "/xml/rpc/soapservice-v2",
  "incomingProtocol": "HTTP/1.1",
  "requestBody": {
    "id": 2,
    "method": "report",
    "stuff": [
      "kborg2@special292.org",
      "X22322mkf3"
    ],
    "xmlrpm": "0.1a"
  },
  "serverProtocol": "HTTP/1.1",
  "responseStatus": "200 OK",
  "requestHeaders": {
    "Content-Type": "application/xml",
    "specialcookie": "8jj220021kl==j2899IuU",
    "Cache-Control": "no-cache",
    "Pragma": "no-cache",
    "User-Agent": "Java/1.5.1_15",
    "Host": "xmlserver.intstage442.org",
    "Accept": "text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2",
    "Connection": "keep-alive",
    "Content-Length": "93",
    "Incoming-Protocol": "HTTPS",
    "ab0044": "0",
    "X-Forwarded-For": "192.168.1.232"
  },
  "responseHeaders": {
    "X-SESSTID": "009nUn4493",
    "Content-Type": "application/xml;charset=UTF-8",
    "Content-Length": "76",
    "Connection": "close"
  },
  "auditLogTrailer": {
    "Apache-Handler": "party-server-time2",
    "Stopwatch": "1379411176088695 48158 (1771* 3714 -)",
    "Producer": "ModSecurity for Apache/2.7 (http://www.modsecurity.org/); core ruleset/1.9.2.",
    "Server": "Whoisthat/v1 (Osprey)",
    "messages": [
      {
        "info": "Warning. Match of \"rx (?:^(?:application\\\\/x-www-form-urlencoded(?:;(?:\\\\s?charset\\\\s?=\\\\s?[\\\\w\\\\d\\\\-]{1,18})?)??$|multipart/form-data;)|text/xml)\" against \"REQUEST_HEADERS:Content-Type\" required.",
        "file": "/opt/niner/modsec2/pp7.conf",
        "line": "69",
        "id": "960010",
        "msg": "Request content type is not allowed by policy",
        "severity": "WARNING",
        "tag": "POLICY/ENCODING_NOT_ALLOWED"
      }
    ]
  },
  "event_date_microseconds": 1.37941116E15,
  "event_date_milliseconds": 1.37941117E12,
  "event_date_seconds": 1.3794112E9,
  "event_timestamp": "2013-09-17T09:46:16.088Z",
  "XForwardedFor-GEOIP": {
    "ip": "192.168.1.122",
    "country_code2": "XZ",
    "country_code3": "BRZ",
    "country_name": "Brazil",
    "continent_code": "SA",
    "region_name": "12",
    "city_name": "Vesper",
    "postal_code": "",
    "timezone": "Brazil/Continental",
    "real_region_name": "Region Metropolitana"
  },
  "matchedRules": [
    "SecRule \"REQUEST_METHOD\" \"@rx ^POST$\" \"phase:2,status:400,t:lowercase,t:replaceNulls,t:compressWhitespace,chain,t:none,deny,log,auditlog,msg:'POST request must have a Content-Length header',id:960022,tag:PROTOCOL_VIOLATION/EVASION,severity:4\"",
    "SecRule \"REQUEST_FILENAME|ARGS|ARGS_NAMES|REQUEST_HEADERS|XML:/*|!REQUEST_HEADERS:Referer\" \"@pm jscript onsubmit onchange onkeyup activexobject vbscript: <![cdata[ http: settimeout onabort shell: .innerhtml onmousedown onkeypress asfunction: onclick .fromcharcode background-image: .cookie onunload createtextrange onload <input\" \"phase:2,status:406,t:lowercase,t:replaceNulls,t:compressWhitespace,t:none,t:urlDecodeUni,t:htmlEntityDecode,t:compressWhiteSpace,t:lowercase,nolog,skip:1\"",
    "SecAction \"phase:2,status:406,t:lowercase,t:replaceNulls,t:compressWhitespace,nolog,skipAfter:950003\"",
    "SecRule \"REQUEST_HEADERS|XML:/*|!REQUEST_HEADERS:'/^(Cookie|Referer|X-OS-Prefs)$/'|REQUEST_COOKIES|REQUEST_COOKIES_NAMES\" \"@pm gcc g++\" \"phase:2,status:406,t:lowercase,t:replaceNulls,t:compressWhitespace,t:none,t:urlDecodeUni,t:htmlEntityDecode,t:lowercase,nolog,skip:1\""
  ],
  "secRuleIds": [
    "960022",
    "960050"
  ]
}
```
