#!/bin/bash

URL="https://tes-one-bay.vercel.app/"

echo "====================================================="
echo "Membuka $URL dengan Firefox Headless (Colab Compatible)"
echo "====================================================="

apt-get update -qq
apt-get install -y -qq firefox-esr

echo "Firefox version:"
firefox --version

export NO_AT_BRIDGE=1
export DBUS_SESSION_BUS_ADDRESS=/dev/null

firefox \
  --headless \
  --private-window \
  "$URL" &

FIREFOX_PID=$!
echo "Firefox PID: $FIREFOX_PID"
echo "Website dibuka (headless). Tunggu 1–2 menit."

while true; do
    sleep 60
    if ! kill -0 $FIREFOX_PID 2>/dev/null; then
        echo "Firefox mati."
        exit 1
    fi
    echo "[$(date)] Firefox masih jalan (PID: $FIREFOX_PID)"
done
