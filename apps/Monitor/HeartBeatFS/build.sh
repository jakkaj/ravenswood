#!/bin/bash

docker build -t heartbeatfslocal --build-arg "HEART_BEAT_FILE=/heart.txt" .
docker run -it --rm heartbeatfslocal bash