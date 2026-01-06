#!/bin/bash

URL="https://tes-one-bay.vercel.app/"

echo "====================================================="
echo "Google Colab Playwright Chromium (FIX DEPENDENCIES)"
echo "Target: $URL"
echo "====================================================="

# Pastikan Node.js ada
if ! command -v node >/dev/null 2>&1; then
  echo "[*] Install Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi

node -v
npm -v

# Init project
if [ ! -f package.json ]; then
  npm init -y >/dev/null 2>&1
fi

# Install Playwright
if [ ! -d node_modules/playwright ]; then
  npm install playwright
fi

# 🔥 INI YANG PENTING (browser + dependency Linux)
echo "[*] Install Chromium + system dependencies..."
npx playwright install --with-deps chromium

# Buat runner
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

  console.log('[*] Website opened. Keep alive...');
  while (true) {
    await page.waitForTimeout(60000);
    console.log('[KEEPALIVE]', new Date().toISOString());
  }
})();
EOF

export TARGET_URL="$URL"

echo "[*] Launching browser..."
node run.js
