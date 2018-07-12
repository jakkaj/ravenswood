#!/bin/bash

## USage 5.header_route.sh svc3 v2 v1 stromuserSegment '.*2.*'
#watch -n .2 curl svc3-20-11/api/enrich -H 'stromuserSegment:2'

. ./loadconfigs.sh

export svc=$1
export TargetVersion=$2
export OtherVersion=$3
export HeaderName=$4
export HeaderRegex=$5




./lib/headerroute.sh