#!/bin/bash

## USage svc_route.sh svc1 v1

. ./loadconfigs.sh

export svc=$1
export targetversion=$2


./lib/set.sh