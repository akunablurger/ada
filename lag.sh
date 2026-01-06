#!/bin/bash

URL="https://tes-one-bay.vercel.app/"   # ganti kalau perlu

echo "====================================================="
echo "Membuka $URL dengan Chromium (Google Colab mode)"
echo "====================================================="

# Colab sudah root → sudo tidak wajib, tapi aman
apt-get update -qq
apt-get install -y -qq chromium-browser curl

echo "Chromium version:"
chromium-browser --version

# Hindari warning DBUS
export NO_AT_BRIDGE=1
export DBUS_SESSION_BUS_ADDRESS=/dev/null

chromium-browser \
  --headless=new \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --disable-software-rasterizer \
  --disable-background-timer-throttling \
  --disable-backgrounding-occluded-windows \
  --disable-renderer-backgrounding \
  --disable-infobars \
  --disable-extensions \
  --disable-blink-features=AutomationControlled \
  --window-size=1920,1080 \
  --lang=en-US,en \
  --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "$URL" &

CHROME_PID=$!
echo "Chromium PID: $CHROME_PID"
echo "Website dibuka (headless). Tunggu 1–2 menit."

# Keep-alive loop
while true; do
    sleep 60
    if ! kill -0 $CHROME_PID 2>/dev/null; then
        echo "Chromium mati."
        exit 1
    fi
    echo "[$(date)] Chromium masih jalan (PID: $CHROME_PID)"
done
