#!/bin/sh

/configure.sh

exec bin/storm jar "./StormEnrichmentTopology-1.0-SNAPSHOT.jar" \
    org.apache.storm.flux.Flux \
    --remote \
    --env-filter \
    "./enricher-env.yaml"
