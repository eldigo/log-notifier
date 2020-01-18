This script monitor's log files (or another text based files) and run's a specified command when a key 'word' or 'phrase' is hit.
The parameters like log file name,path,command and filters must be specified in a jSON formatted file


Make a JSON config_file_name.json with content:
____________________________________________________
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
___________________________________________

    *Note that LOG_MESSAGE which contains the log that was hit in self
     It's is not mandatory to use.
    
    How to run:
    ./script.sh config_file.json
    or
    ./path/to/script.sh /path/to/config_file.json


This script can be runned as a sevice.

For Ubuntu: In /etc/systemd/system make log_notify.service with content:

____________________________________________
[Unit]
Description=log_notify Service
After=multi-user.target
#Conflicts=getty@tty1.service

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
_____________________________________________


systemctl enable log_notify

systemctl start log_notify
