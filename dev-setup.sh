#!/usr/bin/env bash
set -euo pipefail

echo "🚀 ShopSmart Universal Dev Setup"
echo "--------------------------------"

# -----------------------------
# Detect CI
# -----------------------------
IS_CI=false
if [ -n "${CI:-}" ]; then
  IS_CI=true
  echo "🧪 Environment: CI"
else
  echo "💻 Environment: Local / EC2"
fi

# -----------------------------
# Helpers
# -----------------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

OS="$(uname -s)"

# -----------------------------
# Node.js (runtime invariant)
# -----------------------------
if command_exists node; then
  echo "✅ Node.js present ($(node -v))"
else
  if [ "$IS_CI" = true ]; then
    echo "❌ Node.js must be preinstalled in CI"
    exit 1
  fi

  echo "⚙️ Installing Node.js (LTS)"

  if [[ "$OS" == "Linux" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
  else
    echo "❌ Unsupported OS for auto-install"
    exit 1
  fi
fi

# -----------------------------
# npm
# -----------------------------
if ! command_exists npm; then
  echo "❌ npm missing"
  exit 1
fi

echo "✅ npm present ($(npm -v))"

# -----------------------------
# Environment file
# -----------------------------
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
  echo "✅ .env created from .env.example"
else
  echo "ℹ️ .env already exists or not required"
fi

# -----------------------------
# Dependencies
# -----------------------------
if [ "$IS_CI" = true ]; then
  echo "📦 Installing dependencies (CI mode)"
  npm ci
else
  if [ -d node_modules ]; then
    echo "✅ node_modules already present"
  else
    echo "📦 Installing dependencies"
    npm install
  fi
fi

# -----------------------------
# Verification
# -----------------------------
node -e "console.log('Node runtime OK')"

echo ""
echo "🎉 Setup completed successfully"
