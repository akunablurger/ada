#!/bin/bash

URL="https://tes-one-bay.vercel.app/"

echo "====================================================="
echo "Google Colab Headless Browser via Playwright"
echo "Target: $URL"
echo "====================================================="

# Pastikan node ada (Colab biasanya sudah ada)
if ! command -v node >/dev/null 2>&1; then
  echo "[*] Node.js belum ada, install..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi

echo "[*] Node version:"
node -v
npm -v

# Init project kalau belum ada
if [ ! -f package.json ]; then
  npm init -y >/dev/null 2>&1
fi

# Install playwright kalau belum
if [ ! -d node_modules/playwright ]; then
  echo "[*] Install Playwright..."
  npm install playwright
fi

# Download browser Playwright (INI KUNCI DI COLAB)
echo "[*] Download Chromium Playwright..."
npx playwright install chromium

# Buat runner JS
cat > run.js << 'EOF'
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-dev-shm-usage',
      '--disable-blink-features=AutomationControlled'
    ]
  });

  const page = await browser.newPage({
    userAgent:
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36'
  });

  console.log('[*] Opening website...');
  await page.goto(process.env.TARGET_URL, { waitUntil: 'networkidle' });

  console.log('[*] Website opened. Waiting 2 minutes...');
  await page.waitForTimeout(120000);

  console.log('[*] Keep alive loop started');
  while (true) {
    await page.waitForTimeout(60000);
    console.log('[KEEPALIVE]', new Date().toISOString());
  }
})();
EOF

export TARGET_URL="$URL"

echo "[*] Menjalankan browser..."
node run.js
