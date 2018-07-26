#!/bin/bash


echo $setter
#helm init
echo "Update Configs"
helm template $setter -f ../Helm/configs/values.yaml ../Helm/configs | kubectl $kcommand -f -

echo "Create Storage PVC"
helm template $setter -f ../Helm/storage/values.yaml ../Helm/storage | kubectl $kcommand -f -

echo "Create Storage PVC"
helm template $setter -f ../Helm/heartbeat/values.yaml ../Helm/heartbeat | kubectl $kcommand -f -

echo "Update ZooKeeper"
helm template $setter -f ../Helm/zookeeper/values.yaml ../Helm/zookeeper | kubectl $kcommand -f -
if [ "$kcommand" == "create" ]; then
    echo "Letting ZK get a head start"
    sleep 60
fi
echo "Update Nimbus"
helm template $setter -f ../Helm/nimbus/values.yaml ../Helm/nimbus | kubectl $kcommand -f -
if [ "$kcommand" == "create" ]; then
    echo "Letting Nimbus get a head start"
    sleep 10
fi
echo "Update Supervisor"
helm template $setter -f ../Helm/supervisor/values.yaml ../Helm/supervisor | kubectl $kcommand -f -
echo "Update UI"
helm template $setter -f ../Helm/ui/values.yaml ../Helm/ui | kubectl $kcommand -f -

echo "Update Routes"
helm template $setter -f ../Istio/base/values.yaml ../Istio/base | kubectl $kcommand -f -

echo "Update Services"
helm template $setter -f ../Helm/services/values.yaml ../Helm/services | kubectl $kcommand -f -