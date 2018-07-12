#!/bin/sh

#/configure.sh ${ZOOKEEPER_SERVICE_HOST:-$1} ${NIMBUS_SERVICE_HOST:-$2}
/configure.sh

exec bin/storm supervisor
