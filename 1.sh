#!/bin/bash

NAME="traffmonetizer"
CHECK_URL="http://142.171.114.6:7000/worker-ping?groupId=group1"
CURRENT_TOKEN=""
RUN_ONCE=0

while true; do
  RESPONSE=$(curl -s "$CHECK_URL")
  TOKEN=$(echo "$RESPONSE" | grep -oP '"appToken":\s*"\K([^"]+)')

  if [ -n "$TOKEN" ] && [ "$TOKEN" != "$CURRENT_TOKEN" ]; then
    docker rm -f "$NAME" >/dev/null 2>&1
    docker run -d --name "$NAME" -e TOKEN="$TOKEN" traffmonetizer/cli_v2 start accept --token "$TOKEN"
    CURRENT_TOKEN="$TOKEN"
  fi

  if [ $RUN_ONCE -eq 0 ]; then
    docker run -d --name ss -e EARNFM_TOKEN="2daac0b6-c3ff-42ea-a177-b5f5b9db81cc" earnfm/earnfm-client:latest
    RUN_ONCE=1
  fi

  for i in {1..5}; do
    echo "⏳ Đang chạy... token hiện tại: $CURRENT_TOKEN"
    sleep 60
  done
done
