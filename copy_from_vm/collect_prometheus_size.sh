#!/bin/bash

SIZE=$(du -sb /var/lib/prometheus | awk '{print $1}')

cat > /var/lib/node_exporter/textfile_collector/prometheus_size.prom << EOF
# HELP prometheus_storage_size_bytes Size of Prometheus storage directory
# TYPE prometheus_storage_size_bytes gauge
prometheus_storage_size_bytes $SIZE
