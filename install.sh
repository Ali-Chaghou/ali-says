#!/usr/bin/env bash
set -euo pipefail

# 1) make scripts executable and copy to PATH
chmod +x ali-says ali-says-manual
sudo cp ali-says ali-says-manual /usr/local/bin/

# 2) cowsay install (python best-effort)
if ! python3 -c "import cowsay" 2>/dev/null; then
  echo "[info] Installing Python cowsay (user)..."
  python3 -m pip install --user --quiet cowsay || true
fi

# 3) lolcat install (best-effort via gem if possible)
if ! command -v lolcat >/dev/null 2>&1; then
  if command -v gem >/dev/null 2>&1; then
    echo "[info] Installing lolcat via RubyGem..."
    sudo gem install lolcat --no-document || true
  else
    echo "[warn] lolcat not found and ruby not installed — skipping colors."
  fi
fi

# 4) autorun setup
LINE='ali-says | python3 -c "import sys,cowsay; cowsay.cow(sys.stdin.read().strip())" | lolcat'

# fish shell
if [ -d "${HOME}/.config/fish" ]; then
  FISH="${HOME}/.config/fish/config.fish"
  grep -Fqx "$LINE" "$FISH" || echo "$LINE" >> "$FISH"
fi

echo "[done] Installed ali-says + ali-says-manual"
echo "→ Open a new terminal to see the startup quote."
