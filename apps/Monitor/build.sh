#!/bin/bash

echo Gday


docker build -t jakkaj/monheartbeatfs:latest -f HeartBeatFS/Dockerfile ./HeartBeatFS
docker build -t jakkaj/monheartmonfs:latest -f HeartMonitorFS/Dockerfile ./HeartMonitorFS

docker push jakkaj/monheartbeatfs:latest
docker push jakkaj/monheartmonfs:latest
