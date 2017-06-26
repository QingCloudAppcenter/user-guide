#!/bin/bash

######
###	Migrates the keys responding to the pattern specified on the command line, using DUMP/RESTORE, supports authentication differently from MIGRATE
######
SOURCE_HOST=localhost
SOURCE_PASSWORD=
SOURCE_PORT=6379
TARGET_HOST=localhost
TARGET_PASSWORD=
TARGET_PORT=6380
LOG_FILE="redis-migrate.log"
REDIS_PATH=`whereis redis-cli | cut -d: -f2`

if [ -z $REDIS_PATH ]; then
	echo "Cannot find redis-cli path"
	exit 1
fi

function usage()
{
	echo "./redis_migrate -f [源地址:端口号] -t [目标地址:端口号] [-a 源地址密码] [-p 目标地址密码]"
}

ARGS=`getopt -a -o f:a:t:p:k:h -l from:,auth:,target:,password:,help -- "$@"`
[ $? -ne 0 ] && usage
eval set -- "$ARGS"

while true ; do
	case "$1" in
		-f|--from)
			SOURCE_HOST=`echo $2 | cut -d: -f1`
			SOURCE_PORT=`echo $2 | cut -d: -f2`
			shift
			;;
		-a|--auth)
			SOURCE_PASSWORD="-a $2"
			shift
			;;
		-t|--target)
			TARGET_HOST=`echo $2 | cut -d: -f1`
			TARGET_PORT=`echo $2 | cut -d: -f2`
			shift
			;;
		-p|--password)
			TARGET_PASSWORD="-a $2"
			shift
			;;
		-h|--help)
			usage
			;;
		--)
			shift
			break
			;;
	esac
shift
done

$REDIS_PATH -h $SOURCE_HOST $SOURCE_PASSWORD -p $SOURCE_PORT keys \* | while read key; do
	# Preparing TTL
	key_ttl=`$REDIS_PATH -h $SOURCE_HOST $SOURCE_PASSWORD -p $SOURCE_PORT ttl "$key"`
	if [[ $key_ttl -lt 1 ]]; then
		key_ttl=0
	fi

	echo "Dump/Restore \"$key\", ttl $key_ttl" &>> $LOG_FILE

	key_ttl+="000" # TTL must be in milliseconds when specifying it
	$REDIS_PATH --raw -h $SOURCE_HOST -p $SOURCE_PORT $SOURCE_PASSWORD DUMP "$key" | head -c -1 | $REDIS_PATH -x -h $TARGET_HOST -p $TARGET_PORT $TARGET_PASSWORD RESTORE "$key" $key_ttl &>> $LOG_FILE
done
