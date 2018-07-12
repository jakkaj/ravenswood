#!/bin/sh

cat >> conf/storm.yaml <<EOF
storm.local.dir: "/tmp"
EOF

#Configs are mapped in to $CONFIG_BASE
echo "nimbus.seeds:" >> conf/storm.yaml
cat $CONFIG_BASE/nimbusnodes >> conf/storm.yaml


echo "storm.zookeeper.servers:" >> conf/storm.yaml
cat $CONFIG_BASE/zookeepernodes >> conf/storm.yaml

cat conf/storm.yaml
