#!/bin/bash

NAME="traffmonetizer"
CHECK_URL="http://172.245.228.66:6000/worker-ping"
CURRENT_TOKEN=""
RUN_ONCE=0  # Biến đánh dấu đã chạy lệnh Docker chỉ một lần

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

  # Chạy lệnh Docker chỉ một lần
  if [ $RUN_ONCE -eq 0 ]; then
    sudo docker run -d --name ss -e EARNFM_TOKEN="2daac0b6-c3ff-42ea-a177-b5f5b9db81cc" earnfm/earnfm-client:latest
    RUN_ONCE=1  # Đánh dấu là đã chạy lệnh Docker
  fi

for i in {1..5}; do
  clear
  echo "ilovingyou"
  sleep 60
  
done
done
