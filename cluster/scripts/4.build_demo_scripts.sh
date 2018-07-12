!#/bin/bash

. ./loadconfigs.sh

cat >> ../builds/x_kill.sh <<EOF
storm.zookeeper.servers:
- "$1"
EOF