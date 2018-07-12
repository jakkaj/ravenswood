#!/bin/bash

## USage svc_route.sh svc2 70 30

. ./loadconfigs.sh

export svc=$1
export V1Split=$2
export V2Split=$3

./lib/trafficsplit.sh