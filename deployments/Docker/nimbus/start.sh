#!/bin/sh

#/configure.sh

cat >> conf/storm.yaml <<EOF
storm.local.dir: "/tmp"
EOF

echo "storm.zookeeper.servers:" >> conf/storm.yaml
cat $CONFIG_BASE/zookeepernodes >> conf/storm.yaml

cat conf/storm.yaml


exec bin/storm nimbus
