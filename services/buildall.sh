#!/bin/bash

docker build -t jakkaj/svca:latest -f ./Service1/Dockerfile ./Service1

docker build -t jakkaj/svcb:latest -f ./Service2/Dockerfile ./Service2

