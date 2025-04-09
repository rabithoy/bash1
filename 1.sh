#!/bin/bash

NAME="traffmonetizer"
CHECK_URL="http://172.245.228.66:6000/worker-ping"
CURRENT_TOKEN=""

while true; do
  # Lấy token mới từ server mà không dùng jq
  RESPONSE=$(curl -s -X POST $CHECK_URL)
  TOKEN=$(echo $RESPONSE | grep -oP '"appToken":\s*"\K([^"]+)')

  if [ "$TOKEN" != "" ] && [ "$TOKEN" != "$CURRENT_TOKEN" ]; then
  #  echo "🔁 Token mới: $TOKEN"

    # 🧨 Xóa container cũ nếu có
    echo "🧨 Xoá container cũ (nếu tồn tại)..."
    if docker ps -a --format '{{.Names}}' | grep -q "^$NAME$"; then
      docker stop $NAME >/dev/null 2>&1
      docker rm $NAME >/dev/null 2>&1
    #  echo "✅ Đã xóa container cũ."
    fi

    # 🚀 Chạy container mới
   # echo "🚀 Chạy Docker với token: $TOKEN"
    docker run -d --name $NAME -e TOKEN="$TOKEN" traffmonetizer/cli_v2 start accept --token "$TOKEN"

    # Cập nhật token hiện tại
    CURRENT_TOKEN=$TOKEN
  else
   # echo "✅ Token hiện tại vẫn là $CURRENT_TOKEN. Không đổi hoặc không có token mới."
  fi

  echo "ilovingyou"
  sleep 60
done

