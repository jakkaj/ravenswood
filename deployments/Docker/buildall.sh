#!/bin/bash

docker build -t jakkaj/stormbase -f ./base/Dockerfile ./base

docker build -t jakkaj/nimbus -f ./nimbus/Dockerfile ./nimbus

docker build -t jakkaj/stormui -f ./ui/Dockerfile ./ui

docker build -t jakkaj/stormsupervisor -f ./supervisor/Dockerfile ./supervisor

docker build -t jakkaj/stormtopology -f ./topology/Dockerfile ./topology


