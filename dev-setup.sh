#!/usr/bin/env bash
set -euo pipefail

echo "🚀 ShopSmart Dev Environment Setup"
echo "--------------------------------"

# ---------- Helpers ----------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ---------- OS ----------
OS="$(uname -s)"
echo "Detected OS: $OS"

# ---------- Git ----------
if command_exists git; then
  echo "✅ Git already installed"
else
  echo "❌ Git is required. Install Git first."
  exit 1
fi

# ---------- Node.js ----------
if command_exists node; then
  echo "✅ Node.js already installed ($(node -v))"
else
  echo "⚙️ Installing Node.js (LTS)..."

  if [[ "$OS" == "Linux" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif [[ "$OS" == "Darwin" ]]; then
    if command_exists brew; then
      brew install node
    else
      echo "❌ Homebrew not found. Install it first."
      exit 1
    fi
  else
    echo "❌ Unsupported OS"
    exit 1
  fi
fi

# ---------- .env ----------
if [ -f .env ]; then
  echo "✅ .env already exists"
else
  if [ -f .env.example ]; then
    cp .env.example .env
    echo "✅ .env created from .env.example"
  else
    echo "⚠️ .env.example not found"
  fi
fi

# ---------- Dependencies ----------
if [ -d node_modules ]; then
  echo "✅ node_modules already present"
else
  echo "📦 Installing npm dependencies..."
  npm install
fi

# ---------- Done ----------
echo ""
echo "🎉 Dev setup complete!"
echo "👉 Run: npm run dev"
