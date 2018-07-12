!#/bin/bash

ACSENGINE_VERSION=0.18.9

wget -O acs-engine.tar.gz https://github.com/Azure/acs-engine/releases/download/v${ACSENGINE_VERSION}/acs-engine-v${ACSENGINE_VERSION}-linux-amd64.tar.gz 
tar -xvf acs-engine.tar.gz
mv acs-engine-v${ACSENGINE_VERSION}-linux-amd64/acs-engine /usr/local/bin
chmod +x /usr/local/bin/acs-engine
rm acs-engine.tar.gz
rm -rf acs-engine-v${ACSENGINE_VERSION}-linux-amd64