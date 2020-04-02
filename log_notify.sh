
#!/bin/bash

USAGE=$(cat <<-END

    Make a JSON config_file_name.json with content:

[
    {
        "name": "LOG file 1",
        "path": "/path/to/log.log",
        "command": "/bin/bash somekind_scripts.sh LOG_MESSAGE",
        "filters":
            [
                {
                	"name": "Month",
                	"filter": "Jan",
                	"ignore": "" 
                },
                {
                	"name": "Filter Title",
                	"filter": "Filter String",
                	"ignore": "Text" 
                },
                {
                	"name": "Third filter", 
                	"filter": "Text",
                	"ignore": "Text" 
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

    *Note that LOG_MESSAGE which contains the log that was hit in self
     It's is not mandatory to use.
    
    How to run:
    ./script.sh config_file.json
    or
    ./path/to/script.sh /path/to/config_file.json
 
END
)
	

# Our custom function
startWatching(){
  	LOGNR=$1 
	LOGFILE=`jq -r '.['$LOGNR'].path' "$CONFIGFILE"`
	LOGNAME=`jq -r '.['$LOGNR'].name' "$CONFIGFILE"`
	COMMAND=`jq -r '.['$LOGNR'].command' "$CONFIGFILE"`

	if [[ "$COMMAND" -eq "" ]]; then
		echo "!!!!ERROR: No command defined; Skipping ${LOGNAME}"
		echo ""
		exit 0
	fi

	FILTERCOUNT=`jq '.['$LOGNR'].filters | length' "$CONFIGFILE"` 
	echo "Loading Config for ${FILTERCOUNT} log(s)"

	if [[ -f "${LOGFILE}" ]]; then
		echo "__________________${LOGNAME}__________________"
		echo "Name: ${LOGNAME}"
		echo "File: ${LOGFILE}"
		echo "Filters"
	    #get FILTERS and make array
	    for (( j = 0; j < $FILTERCOUNT ; j++ )); do
			fnr=$((j+1))
			#get filternames
			fname=`jq -r '.['$LOGNR'].filters['$j'].name' "$CONFIGFILE"`
    		echo "$fnr: $fname"
			FILTERNAMEARRAY+=(${fname// /.})
			#get filters
    		value=`jq -r '.['$LOGNR'].filters['$j'].filter' "$CONFIGFILE"`
    		echo " '$value'"
			FILTERARRAY+=(${value// /.})
			#get ignore
    		ignore=`jq -r '.['$LOGNR'].filters['$j'].ignore' "$CONFIGFILE"`
    		echo "Ignore: '$ignore'"
			IGNOREARRAY+=(${ignore// /.})

			sleep 5
			unset $value
			unset $fname
			unset $ignore

       	done

    	echo "_________________________________________________________"
	  	echo "$(date)"
	  	echo "Start Watching: $LOGFILE ...."
		tail -fn0 $LOGFILE | \
		while read LINE ; do
			for ((k = 0; k < $FILTERCOUNT; k++))
			do
				
				if [[ "$LINE" == *"${FILTERARRAY["$k"]//./ }"* && "$LINE" != *"${IGNOREARRAY["$k"]//./ }"* && "$LINE" != *"${LOGNAME}"* ]]; then
					echo "_________________START ${LOGNAME} NOTIFY_________________"
		        	echo "${LOGNAME} Filter Name: '${FILTERNAMEARRAY[$k]//./ }'"
		        	echo "${LOGNAME} Filter: '${FILTERARRAY[$k]//./ }'"
		        	echo "${LOGNAME} Log: $LINE"
		       		MESSAGE="${LOGNAME}: FILTER NAME: '${FILTERNAMEARRAY[$k]}' FILTER: '${FILTERARRAY[$k]}' LOG: $LINE"
					MESSAGE=${MESSAGE//./ }
		        	echo "${LOGNAME} Message: $MESSAGE"
		        	echo "${LOGNAME} Command: $COMMAND"
		        	EXCECUTE="${COMMAND/LOG_MESSAGE/"\""$MESSAGE"\""}"
					eval $EXCECUTE
		        	echo "_________________END ${LOGNAME} NOTIFY___________________"
		        fi		
			done		
		done
	else
	    echo "!!!!ERROR: Log file ${LOGFILE} does not exist."
		echo "$USAGE"
	fi

}


#######START##############
  

#load config file

if [[ $1 == */* ]]; then
	CONFIGFILE=$1
else
	PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
	CONFIGFILE=$PARENT_PATH/$1
fi

echo "Processing Config file: $CONFIGFILE"


if [[ -f "$CONFIGFILE" ]]; then

	if jq -e . >/dev/null 2>&1 <<< cat "$CONFIGFILE"; then
	    echo "Config JSON file Valid"
		logcount=`jq -r 'length' "$CONFIGFILE"`
	    #get LOGPATH 
	    for (( i = 0; i < $logcount ; i++ )); do
	    	sleep 2
	    	startWatching $i & # Put a function in the background
		done
	else
	    echo "!!!!ERROR: Failed to parse JSON file ${LOGFILE}"
		echo "$USAGE"
		exit 0	
	fi
else 
	echo "!!!!ERROR: Config file not present"
	echo "$USAGE"
	exit 0
fi

wait 
echo "All done"
exit 0

#######################