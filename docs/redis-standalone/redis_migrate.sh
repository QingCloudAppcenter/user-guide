#!/bin/bash

######
###	Migrates the keys responding to the pattern specified on the command line, using DUMP/RESTORE, supports authentication differently from MIGRATE
######

KEYS_MATCHER="\*"
SOURCE_HOST=localhost
SOURCE_PASSWORD=foobared
SOURCE_PORT=6379
SOURCE_SCHEMA=0
TARGET_HOST=localhost
TARGET_PASSWORD=foobared
TARGET_PORT=6379
TARGET_SCHEMA=0
LOG_FILE="redis-migrate.log"

if [[ -z "$KEYS_MATCHER" ]]; then
	echo -e "Please provide a KEYS matcher, like *~cache"
	exit 1
fi

echo "***	Migrating keys matching $KEYS_MATCHER"

redis-cli -h $SOURCE_HOST -a $SOURCE_PASSWORD -p $SOURCE_PORT keys $KEYS_MATCHER | while read key; do
	# Preparing TTL
	key_ttl=`redis-cli -h $SOURCE_HOST -a $SOURCE_PASSWORD -p $SOURCE_PORT ttl "$key"`
	if [[ $key_ttl -lt 1 ]]; then
		key_ttl=0
	fi

	echo "Dump/Restore \"$key\", ttl $key_ttl" &>> $LOG_FILE

	key_ttl+="000" # TTL must be in milliseconds when specifying it
	redis-cli --raw -h $SOURCE_HOST -p $SOURCE_PORT -n $SOURCE_SCHEMA -a $SOURCE_PASSWORD DUMP "$key" | head -c -1 | redis-cli -x -h $TARGET_HOST -p $TARGET_PORT -n $TARGET_SCHEMA -a $TARGET_PASSWORD RESTORE "$key" $key_ttl &>> $LOG_FILE
done