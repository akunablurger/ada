#!/bin/bash
set -e

echo "Updating system..."
sudo apt update

echo "Installing system dependencies for Puppeteer / Chromium..."
sudo apt install -y \
  curl \
  libnss3 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libcups2 \
  libxkbcommon0 \
  libxcomposite1 \
  libxdamage1 \
  libxrandr2 \
  libxshmfence1 \
  libxft2 \
  libx11-xcb1 \
  libgbm1 \
  libasound2t64 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libxfixes3 \
  libnss3-tools \
  fonts-liberation \
  libappindicator3-1 \
  libnspr4 \
  libu2f-udev \
  libgtk-3-0 \
  libxss1

# ------------------------------
# Node.js
# ------------------------------
if ! command -v node >/dev/null 2>&1; then
  echo "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
  sudo apt install -y nodejs
fi

sudo npm install -g npm

# ------------------------------
# Project setup
# ------------------------------
if [ ! -f package.json ]; then
  npm init -y
fi

if ! npm ls puppeteer >/dev/null 2>&1; then
  npm install puppeteer
fi

# ------------------------------
# Workers
# ------------------------------
CORES=$(nproc)
WORKERS=$((CORES * 2))
echo "CPU cores: $CORES | Workers: $WORKERS"

# ------------------------------
# Puppeteer script
# ------------------------------
cat << 'EOF' > script.js
const puppeteer = require('puppeteer');

(async () => {
  try {
    const browser = await puppeteer.launch({
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-gpu',
        '--disable-dev-shm-usage'
      ]
    });

    const page = await browser.newPage();
    await page.goto('https://tes-one-bay.vercel.app/', { waitUntil: 'networkidle2' });

    console.log('Browser running...');
    await new Promise(() => {}); // keep alive
  } catch (err) {
    console.error(err);
  }
})();
EOF

WORKERS=$WORKERS node script.js
