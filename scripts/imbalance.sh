#!/usr/bin/env bash
set -euo pipefail

compose() { docker compose -f docker-compose.yml "$@"; }

case "${1:-}" in
  under)
    compose up -d kafka-1 kafka-2 kafka-3 kafka-ui \
      jmx-kafka-1 jmx-kafka-2 jmx-kafka-3 \
      topic-creator demo-producer prometheus grafana
    compose --profile monitoring up -d consumer1 jmx-consumer1
    echo "✅ UNDER-PROVISIONED: 1 consumer for 20 partitions"
    echo "   Expected: High lag, 100% workload on consumer1"
    echo "   Grafana: http://localhost:3000"
    ;;
  balanced)
    compose up -d kafka-1 kafka-2 kafka-3 kafka-ui \
      jmx-kafka-1 jmx-kafka-2 jmx-kafka-3 \
      topic-creator demo-producer prometheus grafana
    compose --profile monitoring up -d consumer1 jmx-consumer1 consumer2 jmx-consumer2 \
      consumer3 jmx-consumer3 consumer4 jmx-consumer4
    echo "✅ BALANCED: 4 consumers for 20 partitions (5 partitions each)"
    echo "   Expected: Even distribution, low lag"
    echo "   Grafana: http://localhost:3000"
    ;;
  over)
    compose up -d kafka-1 kafka-2 kafka-3 kafka-ui \
      jmx-kafka-1 jmx-kafka-2 jmx-kafka-3 \
      topic-creator demo-producer prometheus grafana
    compose --profile monitoring up -d consumer1 jmx-consumer1 consumer2 jmx-consumer2 \
      consumer3 jmx-consumer3 consumer4 jmx-consumer4 consumer5 jmx-consumer5 consumer6 jmx-consumer6
    echo "✅ OVER-PROVISIONED: 6 consumers for 20 partitions"
    echo "   Expected: Uneven distribution (4,4,4,4,2,2), some underutilized"
    echo "   Grafana: http://localhost:3000"
    ;;
  scale2)
    compose --profile monitoring up -d consumer1 jmx-consumer1 consumer2 jmx-consumer2
    compose --profile monitoring stop consumer3 consumer4 consumer5 consumer6 jmx-consumer3 jmx-consumer4 jmx-consumer5 jmx-consumer6 2>/dev/null || true
    echo "✅ SCALED TO 2 consumers (10 partitions each)"
    ;;
  scale4)
    compose --profile monitoring up -d consumer1 jmx-consumer1 consumer2 jmx-consumer2 \
      consumer3 jmx-consumer3 consumer4 jmx-consumer4
    compose --profile monitoring stop consumer5 consumer6 jmx-consumer5 jmx-consumer6 2>/dev/null || true
    echo "✅ SCALED TO 4 consumers (5 partitions each)"
    ;;
  scale6)
    compose --profile monitoring up -d consumer1 jmx-consumer1 consumer2 jmx-consumer2 \
      consumer3 jmx-consumer3 consumer4 jmx-consumer4 consumer5 jmx-consumer5 consumer6 jmx-consumer6
    echo "✅ SCALED TO 6 consumers (uneven: 4,4,4,4,2,2)"
    ;;
  scale6)
    compose --profile monitoring up -d consumer1 jmx-consumer1 consumer2 jmx-consumer2 \
      consumer3 jmx-consumer3 consumer4 jmx-consumer4 consumer5 jmx-consumer5 consumer6 jmx-consumer6
    echo "✅ SCALED TO 6 consumers (uneven: 4,4,4,4,2,2)"
    ;;
  status)
    echo "📊 Consumer Group Status:"
    docker exec kafka-1 /opt/kafka/bin/kafka-consumer-groups.sh \
      --bootstrap-server kafka-1:29092 \
      --group demo-group \
      --describe 2>/dev/null || echo "Consumer group not active yet"
    ;;
  clean)
    echo "🧹 Cleaning up..."
    compose --profile monitoring down -v --remove-orphans || true
    docker ps -aq --filter "name=kafka-" --filter "name=consumer" --filter "name=jmx-" --filter "name=prometheus" --filter "name=grafana" --filter "name=topic-creator" --filter "name=demo-producer" | xargs -r docker rm -f 2>/dev/null || true
    docker network rm kafka_cg_kafka-net 2>/dev/null || true
    cd "$(dirname "$0")/.."
    rm -rf kafka1-storage kafka2-storage kafka3-storage
    echo "✅ Cleanup complete"
    ;;
  *)
    echo "Usage: ./scripts/imbalance.sh [command]"
    echo ""
    echo "Test Scenarios (20 partitions):"
    echo "  under     - 1 consumer (high lag, overloaded)"
    echo "  balanced  - 4 consumers (optimal: 5 partitions each)"
    echo "  over      - 6 consumers (idle consumers: 4,4,4,4,2,2)"
    echo ""
    echo "Dynamic Scaling:"
    echo "  scale2    - Scale to 2 consumers"
    echo "  scale4    - Scale to 4 consumers"
    echo "  scale6    - Scale to 6 consumers"
    echo ""
    echo "Utilities:"
    echo "  status    - Show consumer group partition assignments"
    echo "  clean     - Remove all containers and data"
    echo ""
    echo "Access: http://localhost:3000 (admin/admin)"
    exit 1
    ;;
esac

