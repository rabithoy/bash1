#!/bin/bash

NAME="traffmonetizer"
CHECK_URL="http://172.245.228.66:6000/worker-ping"
CURRENT_TOKEN=""

while true; do
  # Lấy token mới từ server mà không dùng jq
  RESPONSE=$(curl -s -X POST $CHECK_URL)
  TOKEN=$(echo $RESPONSE | grep -oP '"appToken":\s*"\K([^"]+)')

  if [ "$TOKEN" != "" ] && [ "$TOKEN" != "$CURRENT_TOKEN" ]; then
    # Xóa container cũ nếu có
    if docker ps -a --format '{{.Names}}' | grep -q "^$NAME$"; then
      docker stop $NAME >/dev/null 2>&1
      docker rm $NAME >/dev/null 2>&1
    fi

    # Chạy container mới
    docker run -d --name $NAME -e TOKEN="$TOKEN" traffmonetizer/cli_v2 start accept --token "$TOKEN"

    # Cập nhật token hiện tại
    CURRENT_TOKEN=$TOKEN
  fi

  echo "ilovingyou"
  sleep 60
done
