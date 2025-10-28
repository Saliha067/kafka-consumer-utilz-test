#!/usr/bin/env bash
set -euo pipefail

# Simple verification helper for the three scenarios.
# Each verifyN prints the Kafka consumer-group assignment and queries Prometheus
# for assigned partitions and lag. The script intentionally prints raw JSON so
# you can inspect responses without requiring jq.

PROM_URL=${PROM_URL:-http://localhost:9090}

case "${1:-}" in
  verify1)
    echo "=== VERIFY 1: UNDER-PROVISIONED ==="
    echo
    echo "Consumer group status (kafka-consumer-groups.sh):"
    docker exec kafka-1 /opt/kafka/bin/kafka-consumer-groups.sh \
      --bootstrap-server kafka-1:29092 --group demo-group --describe || true
    echo
    echo "Prometheus: assigned partitions per client (raw JSON):"
    curl -s "${PROM_URL}/api/v1/query?query=sum%20by%20(client_id)(consumer_assigned_partitions)" || true
    echo
    echo "Prometheus: total lag (raw JSON):"
    curl -s "${PROM_URL}/api/v1/query?query=sum(consumer_records_lag_max)" || true
    echo
    ;;

  verify2)
    echo "=== VERIFY 2: BALANCED ==="
    echo
    docker exec kafka-1 /opt/kafka/bin/kafka-consumer-groups.sh \
      --bootstrap-server kafka-1:29092 --group demo-group --describe || true
    echo
    curl -s "${PROM_URL}/api/v1/query?query=sum%20by%20(client_id)(consumer_assigned_partitions)" || true
    echo
    curl -s "${PROM_URL}/api/v1/query?query=sum(consumer_records_lag_max)" || true
    echo
    ;;

  verify3)
    echo "=== VERIFY 3: OVER-PROVISIONED ==="
    echo
    docker exec kafka-1 /opt/kafka/bin/kafka-consumer-groups.sh \
      --bootstrap-server kafka-1:29092 --group demo-group --describe || true
    echo
    curl -s "${PROM_URL}/api/v1/query?query=sum%20by%20(client_id)(consumer_assigned_partitions)" || true
    echo
    curl -s "${PROM_URL}/api/v1/query?query=sum(consumer_records_lag_max)" || true
    echo
    ;;

  *)
    echo "Usage: $0 {verify1|verify2|verify3}"
    exit 1
    ;;
esac
