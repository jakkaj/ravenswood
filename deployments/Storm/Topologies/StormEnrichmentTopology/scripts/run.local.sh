#!/usr/bin/env bash

set -o xtrace

# MUST RUN THIS SCRIPT FROM PARENT FOLDER
# Example: ./scripts/run.local.sh

# Clean and Package
mvn clean package

# Run
# This requires the storm client: 
# http://storm.apache.org/downloads.html
# http://storm.apache.org/releases/current/Setting-up-development-environment.html

storm jar "$(pwd)/target/StormEnrichmentTopology-1.0-SNAPSHOT.jar" \
    org.apache.storm.flux.Flux \
    --local \
    --filter "$(pwd)/dev.properties" \
    "$(pwd)/resources/enricher.yaml"

# storm jar "$(pwd)/target/StormEnrichmentTopology-1.0-SNAPSHOT.jar" \
#     org.apache.storm.flux.Flux \
#     --local \
#     --filter "$(pwd)/dev.properties" \
#     "$(pwd)/resources/writer.yaml"