**Log Filter Notifier**

This script monitor's log files (or another text based files) and run's a specified command when a key 'word' or 'phrase' is hit.
The parameters like log file name,path,command and filters must be specified in a jSON formatted file

A command could be for instance to send the LOG through Telegram
```
/usr/local/sbin/telegram-notify --quiet --text LOG_MESSAGE
```

The 'LOG_MESSAGE' contains the actual log.


Make a JSON config_file_name.json with content:
```
[
    {
        "name": "LOG file 1",
        "path": "/path/to/log.log",
        "command": "/bin/bash somekind_scripts.sh LOG_MESSAGE",
        "filters":
            [
                { 
                	"name": "Month", "
                	filter": "Jan" 
                },
                { 
                	"name": "Filter Title", 
                	"filter": "Filter String" 
                },
                { 
                	"name": "Third filter", 
                	"filter": "Text" 
                }
            ]
},
    {
        "name": "System LOG",
        "path": "/path/to/syslog",
        "command": "perl somekind_scripts.pl LOG_MESSAGE",
        "filters":
            [
                { "name": "Server Name", "filter": "Server" },
                { "name": "Error filter", "filter": "ERR" }
            ]
    }
]
```

Note that LOG_MESSAGE which contains the log that was hit. 
Its not mandatory to use.
    
How to run:

```
./script.sh config_file.json
```
or
```
/path/to/script.sh /path/to/config_file.json
```


This script can be runned as a sevice.

For Ubuntu: In /etc/systemd/system make log_notify.service with content:

```
[Unit]
Description=log_notify Service
After=multi-user.target

[Service]
Type=simple
ExecStart=/bin/bash /path/to/script.sh /path/to/config_file.json
StandardOutput=syslog
StandardError=syslog
User=root
Restart=on-failure
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=log_notify


[Install]
WantedBy=multi-user.target
```
```
systemctl enable log_notify
```
```
systemctl start log_notify
```
