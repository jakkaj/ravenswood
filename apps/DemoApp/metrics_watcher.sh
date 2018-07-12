#!/bin/bash

# Set these!
export rg_name=lacestorm
export ehns_name=laceehns01
export now="$(date --date '-5 min' --utc +%FT%TZ)" # Last 5 min of metrics

metrics() {

    # Metric list: https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-supported-metrics?redirectedfrom=MSDN#microsofteventhubnamespaces

    az monitor metrics list --resource $ehns_name \
        --resource-group $rg_name \
        --resource-type Microsoft.EventHub/namespaces \
        --metric IncomingMessages \
        --start-time "$now" \
        --output table

    az monitor metrics list --resource $ehns_name \
        --resource-group $rg_name \
        --resource-type Microsoft.EventHub/namespaces \
        --metric OutgoingMessages \
        --start-time "$now" \
        --output table
}

export -f metrics

# Every 10 seconds
# Note that az cli monitor queries can be a bit slow.

watch -n 10 --exec bash -c metrics 