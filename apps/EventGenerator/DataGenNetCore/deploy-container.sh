#!/bin/bash -v
set -x

az account set -s "<your subs name (not the id!)"

declare acrName="yourregistry"
declare acrServer="yourregistry.azurecr.io"
declare acrPassword="xxxpppzzz"

# log in to Azure Container Registry
az acr login --name "${acrName}" --username ${acrName} --password ${acrPassword} 

# (re) build docker images, tag, push to acr
docker build . -t datagen:slow --build-arg VELOCITY="slow"
docker tag datagen:slow "${acrServer}"/datagen:slow
docker push "${acrServer}"/datagen:slow

docker build . -t datagen:fast --build-arg VELOCITY="fast"
docker tag datagen:fast "${acrServer}"/datagen:fast
docker push "${acrServer}"/datagen:fast

docker build . -t datagen:faster --build-arg VELOCITY="faster"
docker tag datagen:faster "${acrServer}"/datagen:faster
docker push "${acrServer}"/datagen:faster

docker build . -t datagen:insane --build-arg VELOCITY="insane"
docker tag datagen:insane "${acrServer}"/datagen:insane
docker push "${acrServer}"/datagen:insane


kubectl create secret docker-registry acr-auth-ravenswoodregistry --docker-server $acrServer \
    --docker-username $acrName --docker-password $acrPassword --docker-email cse@microsoft.com
