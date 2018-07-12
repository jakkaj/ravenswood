echo "Please make sure you've updated the config.json file"

sleep 3

. ./loadconfigs.sh

az account show 1> /dev/null

if [ $? != 0 ];
then
	az login
fi

. ./1.create_networks.sh

echo "Finished networks and storage"

sleep 5

. 2.a.create_aks.sh &
. 2.b.create_acsengine.sh &


echo "Waiting for scripts..."

wait

echo "Cluster set up scripts complete"
sleep 5

. 3.config_cluster.sh

echo "Done!"
