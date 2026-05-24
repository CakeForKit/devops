#!/bin/bash

STATS=$(curl -s http://localhost/nginx_status)

ACTIVE=$(echo "$STATS" | grep "Active connections" | awk '{print $3}')
READING=$(echo "$STATS" | grep "Reading" | awk '{print $2}')
WRITING=$(echo "$STATS" | grep "Writing" | awk '{print $4}')
WAITING=$(echo "$STATS" | grep "Waiting" | awk '{print $6}')
ACCEPTED=$(echo "$STATS" | awk 'NR==3{print $1}')
HANDLED=$(echo "$STATS" | awk 'NR==3{print $2}')
REQUESTS=$(echo "$STATS" | awk 'NR==3{print $3}')

cat > /var/lib/node_exporter/textfile_collector/nginx_metrics.prom << EOF
# HELP nginx_active_connections Active connections
# TYPE nginx_active_connections gauge
nginx_active_connections $ACTIVE
# HELP nginx_reading_connections Reading connections
# TYPE nginx_reading_connections gauge
nginx_reading_connections $READING
# HELP nginx_writing_connections Writing connections
# TYPE nginx_writing_connections gauge
nginx_writing_connections $WRITING
# HELP nginx_waiting_connections Waiting connections
# TYPE nginx_waiting_connections gauge
nginx_waiting_connections $WAITING
# HELP nginx_accepted_connections Total accepted connections
# TYPE nginx_accepted_connections counter
nginx_accepted_connections $ACCEPTED
# HELP nginx_handled_connections Total handled connections
# TYPE nginx_handled_connections counter
nginx_handled_connections $HANDLED
# HELP nginx_total_requests Total requests
# TYPE nginx_total_requests counter
nginx_total_requests $REQUESTS
nginx_up 1
EOF