#!/bin/bash

# Simple script to check status of services

# configure these
HUB_HOST=${1}

EXIT_CODE=0

# check etcd
SVC_STATUS=$(nc -z "${HUB_HOST}" 4001)
if [ $? = "0" ]; then
  echo "etcd up"
else
  echo "etcd down"
  EXIT_CODE=1
fi

# check rabbitmq
SVC_STATUS=$(nc -z "${HUB_HOST}" 5672)
if [ $? = "0" ]; then
  echo "rabbitmq up"
else
  echo "rabbitmq down"
  EXIT_CODE=1
fi

# check mongo
SVC_STATUS=$(nc -z "${HUB_HOST}" 27017)
if [ $? = "0" ]; then
  echo "mongodb up"
else
  echo "mongodb down"
  EXIT_CODE=1
fi

# check grid-hub
SVC_STATUS=$(curl -s -I "${HUB_HOST}":4444 | head -n 1|cut -d$' ' -f2)
if [ "${SVC_STATUS}" = "200" ]; then
  echo "grid-hub up"
else
  echo "grid-hub down"
  EXIT_CODE=1
fi

# check seleniumvbox-frontend
SVC_STATUS=$(curl -s "${HUB_HOST}":3000/status)
if [ "${SVC_STATUS}" = "up" ]; then
  echo "seleniumvbox-frontend up"
else
  echo "seleniumvbox-frontend down"
  EXIT_CODE=1
fi

if [ "${EXIT_CODE}" = "0" ]; then
  echo "All status checks completed successfully."
fi

exit "${EXIT_CODE}"
