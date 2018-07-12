#!/usr/bin/env bash

set -o xtrace

# MUST RUN THIS SCRIPT FROM PARENT FOLDER
# Example: ./scripts/run.local.sh

# Clean and Package
mvn clean package

# Set environment variables
export topology_name="lacetop"
export eventhub_read_policy_name="reader"
export eventhub_read_policy_key="<read policy key>"
export eventhub_namespace="laceehns01"
export eventhub_name="laceeh01"
export eventhub_partitions="2"
export enrichbolt_parallelism="2"
export cosmoswriterbolt_parallelism="2"
export cosmos_service_endpoint="Create here: https://ms.portal.azure.com/#create/Microsoft.DocumentDB | thing you need looks like this -> https://xxxx.documents.azure.com:443/"
export cosmos_key="<cosmos key>"
export cosmos_database_name="testdb"
export cosmos_collection_name="testcollection"
export enrich_url1="http://13.76.1.109:8001"
export enrich_url2="http://52.230.64.147:8001"
export enrich_url3="http://137.116.151.114:8001"

# Run
# This requires the storm client: 
# http://storm.apache.org/downloads.html
# http://storm.apache.org/releases/current/Setting-up-development-environment.html

storm jar "$(pwd)/target/StormEnrichmentTopology-1.0-SNAPSHOT.jar" \
    org.apache.storm.flux.Flux \
    --local \
    --env-filter \
    "$(pwd)/resources/enricher-env.yaml"


# storm jar "$(pwd)/target/StormEnrichmentTopology-1.0-SNAPSHOT.jar" \
#     org.apache.storm.flux.Flux \
#     --local \
#     --env-filter \
#     "$(pwd)/resources/enricher-env.yaml"
#     -c 'nimbus.seeds=["nimbus-12jordo-133-0.nimbus-hs-12jordo-133.default.svc.cluster.local:6627"]'

# storm jar myTopology-0.1.0-SNAPSHOT.jar org.apache.storm.flux.Flux --remote my_config.yaml -c 'nimbus.seeds=["localhost"]'