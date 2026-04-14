#!/bin/bash

SERVER="http://172.245.228.66:3000"

while true; do
  echo "===== START WORKER ====="

  # ===== LẤY DEVICE ID =====
  while true; do
    DEVICE_ID=$(curl -s $SERVER/get-offline-key | jq -r '.device_id')

    if [[ -z "$DEVICE_ID" || "$DEVICE_ID" == "null" ]]; then
      echo "Không có device_id → đợi 10s..."
      sleep 10
    else
      break
    fi
  done

  echo "DEVICE_ID: $DEVICE_ID"

  # ===== CLEAR CONTAINER CŨ =====
  docker rm -f proxyrack 2>/dev/null

  # ===== RUN CONTAINER =====
  docker run -d \
    --name proxyrack \
    --restart always \
    -e UUID="$DEVICE_ID" \
    proxyrack/pop

  echo "Container started"

  # ===== LOOP PING =====
  FAIL_COUNT=0

  while true; do
    # ping server
    RES=$(curl -s -X POST $SERVER/ping \
      -H "Content-Type: application/json" \
      -d "{\"device_id\":\"$DEVICE_ID\"}")

    # check container còn sống không
    if ! docker ps --format '{{.Names}}' | grep -q "^proxyrack$"; then
      echo "Container die → restart"
      break
    fi

    # nếu ping fail nhiều lần → reset
    if [[ -z "$RES" ]]; then
      FAIL_COUNT=$((FAIL_COUNT+1))
      echo "Ping lỗi ($FAIL_COUNT)"
    else
      FAIL_COUNT=0
    fi

    if [[ $FAIL_COUNT -ge 5 ]]; then
      echo "Ping fail quá nhiều → restart worker"
      break
    fi

    sleep 60
  done

  echo "Restart worker sau 5s..."
  sleep 5
done
