#!/bin/bash

# ====== CONFIG ======
SERVER="147.93.159.122"
KEY="$HOME/1.pem"
GOST_BIN="$HOME/gost"

# ====== CREATE SSH KEY IF NOT EXISTS ======
if [ ! -f "$KEY" ]; then
cat > $KEY << 'EOF'
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAvnA3yKKdTZNQmaoOuWjBQplX4nPhRk+/Al79f5AUK/wizBax
/akZ/en18y/MDubxM/eEovqJF2N5odVYO4S6hKVNDxPhjuk/Pek1+FZExWIvB2G5
t1ZHP1bhrQCy/DW/CPvXhLV6uDX+MKjCNPV5qoYdF7SiHU/CRUL2T7SRYxkCpz5i
Ss7iRXXg1Op5Z9QTkKEnFOll1dz5lHDMibiT9yVnNZJBjKWUsENwXK1fJ60HEa42
ypbNQon/KKusKQbzwztelY5pqOi6RE29ZjHB9OjZOJiibSabNg/yDXSFDaOnW/rt
7Ig2pF5aSMIXLJRFCL6m2DFnm/THhFQJPxMBPwIDAQABAoIBADluNiR3heDDMGdm
9ZHMmZuwCuTr9V/y5LOeWeyCUtMA8q2BmqPYv1HnoJh6LZvA4bS+TG2qCHXZNfEs
GbO5T1Z5U0fcwwUKKlxNXE1MFuk/ttcPDabQiiP724sEzvVob/gRmukWoa+z+LhL
7GV0MgDO+S8Q9mLIjtm8W/OljMLJXkHzs398od/tD9+E3/pRbhwmibfKJwT0LvQQ
kRXsUfs2NC/f2vBhn0sz43QFfCXoFEZ0OkkKdza0QcnK8i5LKB9xsJBiFouogsLI
9n/5dPZennraZddvpFiHh5lCAF53freSoyAQxrqzyC8B4uUjjvaqpafWjlXy7nlw
Kq2vM8ECgYEA8+Oh4WSJ/NspM4jnzvG6mHxBjUFFxCZSkXIJ+o2BCVXpGI0waK3Q
KAIVpeekYXg7MsCSIhIJWSS1/1UBO1ZR3ISS0cSPauIfYoZkVFL5w43S1UkJnLAf
fR1u/rdhr7OLy+/fW5+wI56C+T1dJbNASqG6/6TmRCwNIfF1RJK1wscCgYEAx+Ub
oT2EjgCQ94j7kwBQZTHYgSJk50erTuYmtvWRH+eKjNs1aIpScxgkywc8EySjl4Jg
NAzkSUDcBhHHMkVL/Gyx+sj7luyEdD9J0JUBvDCjPf9MR8Yt4BNlun0roUaCoAG4
rjEFyZzoCRWgS2EZsGMORTFfrewh01GAeFTHVckCgYEA1nEYLS5RhdrN51pBOFyj
TOA0Yxc5WLa5ctlqnLs+8g5v3f6GygPKOuNaVX3Ps0QcCQv5cauaPJ9ixxbe9mV3
pQWMcpT55WjdX6v7G4m5wpA5CQAnS3Ywubnflmd3pR2hlbdcFRvbq/X8A1pJRJTP
us9ptM4xCVASW/4KtjipSJECgYALx46HQ+7Jx3LDg4j/sqcKL5PImFRF5M1NivaB
FZuFu8lIX6qYDH6rVaLla/m4TxJs3Tv6FUBmqLHOkcGhTsAZkfYzByD8VdfAWfJp
nj5J7rvP7Xl7SUxuxfXatYGasWMFNtTBPxZOOTbbQjD+ACzZXhz7Ktuujhm4MDdX
3/cXMQKBgBN2NwP/zXTeNFVVHldDvDKrXNB+9rq3RtfrrYyoIDTxs8qNvn/Bfl1T
LPtICDKQNJy5a+gqanJ0rIKEPtFvY1wP4WXHKdgvEWjaU48tlQA53oo4Wn3mbCso
+jfo8iSmsRFA6qSUu0nvoQ/3gKI2GCNVFLM6eoIK1cCdV6NZbBuC
-----END RSA PRIVATE KEY-----
EOF

chmod 600 $KEY
echo "🔑 Key created"
fi

# ====== INSTALL GOST ======
if [ ! -f "$GOST_BIN" ]; then
    echo "📦 Installing gost..."
    cd ~
    wget -q https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz
    gunzip -f gost-linux-amd64-2.11.1.gz
    mv gost-linux-amd64-2.11.1 $GOST_BIN
    chmod +x $GOST_BIN
fi

# ====== CHECK CURL ======
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    sudo yum install -y curl || sudo apt install -y curl
fi

# ====== MAIN LOOP ======
while true; do

    # kill old process
    pkill gost 2>/dev/null

    # ====== GET PORT ======
    PORT=$(curl -s http://$SERVER:3000/get-port | grep -o '[0-9]\+')
    echo "🚀 PORT=$PORT"

    # ====== START SOCKS5 ======
    $GOST_BIN -L=socks5://127.0.0.1:1080?resolver=8.8.8.8 > /dev/null 2>&1 &
    GOST_PID=$!

    sleep 2

    # ====== KEEPALIVE PING LOOP ======
    (
        while true; do
            curl -s -X POST http://$SERVER:3000/ping \
                -H "Content-Type: application/json" \
                -d "{\"port\":$PORT}" > /dev/null 2>&1
            sleep 20
        done
    ) &
    PING_PID=$!

    # ====== SSH REVERSE ======
    ssh -i $KEY \
        -o "StrictHostKeyChecking=no" \
        -o "ServerAliveInterval=30" \
        -o "ServerAliveCountMax=3" \
        -o "ExitOnForwardFailure=yes" \
        -N -R 0.0.0.0:$PORT:localhost:1080 root@$SERVER

    echo "❌ SSH disconnected → restart..."

    # ====== CLEAN ======
    kill $GOST_PID 2>/dev/null
    kill $PING_PID 2>/dev/null

    sleep 5
done
