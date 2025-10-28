#!/usr/bin/env bash
# Complete test execution for all 3 scenarios

echo "=========================================="
echo "KAFKA CONSUMER UTILIZATION TEST - ALL SCENARIOS"
echo "=========================================="
echo ""

# SCENARIO 1: UNDER-PROVISIONED
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SCENARIO 1: UNDER-PROVISIONED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1 consumer for 20 partitions"
echo ""
./scripts/imbalance.sh clean
sleep 2
./scripts/imbalance.sh under
echo ""
echo "Waiting 30 seconds for metrics..."
sleep 30
./scripts/test-guide.sh verify1
echo ""
echo "✅ Open Grafana: http://localhost:3000"
echo "Expected: 1 bar showing 20 partitions on console-consumer-1"
echo ""
read -p "Press Enter to continue to Scenario 2..."
echo ""

# SCENARIO 2: BALANCED
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SCENARIO 2: BALANCED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4 consumers for 20 partitions (5 each)"
echo ""
# ./scripts/imbalance.sh clean
# sleep 2
./scripts/imbalance.sh balanced
echo ""
echo "Waiting 30 seconds for rebalancing..."
sleep 30
./scripts/test-guide.sh verify2
echo ""
echo "✅ Open Grafana: http://localhost:3000"
echo "Expected: 4 bars showing 5 partitions each"
echo ""
read -p "Press Enter to continue to Scenario 3..."
echo ""

# SCENARIO 3: OVER-PROVISIONED
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SCENARIO 3: OVER-PROVISIONED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6 consumers for 20 partitions (uneven)"
echo ""
# ./scripts/imbalance.sh clean
# sleep 2
./scripts/imbalance.sh over
echo ""
echo "Waiting 30 seconds for rebalancing..."
sleep 30
./scripts/test-guide.sh verify3
echo ""
echo "✅ Open Grafana: http://localhost:3000"
echo "Expected: 6 bars with uneven distribution (4,4,4,4,2,2)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ALL SCENARIOS COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Cleanup: ./scripts/imbalance.sh clean"
echo ""
read -p "Press Enter to continue to cleanup..."
echo ""
./scripts/imbalance.sh clean
sleep 2
