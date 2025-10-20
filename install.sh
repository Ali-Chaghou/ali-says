#!/usr/bin/env bash
set -euo pipefail

# repo source
REPO="Ali-Chaghou/ali-says"
RAW="https://raw.githubusercontent.com/${REPO}/main"

# helpers
have() { command -v "$1" >/dev/null 2>&1; }
die()  { echo "ERROR: $*" >&2; exit 1; }

# target dir (user scope)
BIN_DIR="${HOME}/.local/bin"
mkdir -p "$BIN_DIR"

# fetch file from GitHub (raw)
fetch() {
  # $1: repo path (e.g. ali-says), $2: local dest
  curl -fsSL "${RAW}/$1" -o "$2"
}

# read yes/no (default no)
ask_yes() {
  # $1: prompt
  printf "%s" "$1"
  read -r ans || true
  case "${ans:-}" in
    y|Y|yes|YES) return 0 ;;
    *)           return 1 ;;
  esac
}

# 1) obtain scripts (use local if present, else fetch)
TMP="$(mktemp -d 2>/dev/null || mktemp -d -t ali-says)"
trap 'rm -rf "$TMP"' EXIT

if [[ -f "./ali-says" && -f "./ali-says-manual" ]]; then
  cp ./ali-says ./ali-says-manual "$TMP/"
else
  fetch ali-says "$TMP/ali-says"
  fetch ali-says-manual "$TMP/ali-says-manual"
fi

chmod +x "$TMP/ali-says" "$TMP/ali-says-manual"
cp "$TMP/ali-says" "$TMP/ali-says-manual" "$BIN_DIR/"

echo "[ok] installed: $BIN_DIR/ali-says, $BIN_DIR/ali-says-manual"

# 2) deps (best effort, user scope)
# cowsay (python) for ascii cow
if have python3; then
  if ! python3 -c 'import cowsay' 2>/dev/null; then
    echo "[info] installing python cowsay (user)"
    python3 -m pip install --user --quiet cowsay || true
  fi
else
  echo "[warn] python3 not found; output will be plain text"
fi

# lolcat (colors) via user gem if ruby available
if have gem && ! have lolcat; then
  echo "[info] installing lolcat (user gem)"
  gem install --user-install --no-document lolcat || true
  # ensure user gem bin is on PATH for future shells
  if have ruby; then
    GEM_BIN="$(ruby -e 'puts Gem.user_dir')/bin"
    # bash/zsh
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
      [[ -f "$rc" ]] || continue
      grep -Fqx "export PATH=\"${GEM_BIN}:\$PATH\"" "$rc" || echo "export PATH=\"${GEM_BIN}:\$PATH\"" >> "$rc"
    done
    # fish
    if [[ -d "$HOME/.config/fish" ]]; then
      FISH="$HOME/.config/fish/config.fish"
      mkdir -p "$(dirname "$FISH")"; touch "$FISH"
      grep -Fqx "set -Ua PATH ${GEM_BIN}" "$FISH" || echo "set -Ua PATH ${GEM_BIN}" >> "$FISH"
    fi
  fi
fi

# 3) ensure ~/.local/bin is in PATH for future shells
# bash/zsh
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [[ -f "$rc" ]] || continue
  grep -Fqx 'export PATH="$HOME/.local/bin:$PATH"' "$rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done
# fish
if [[ -d "$HOME/.config/fish" ]]; then
  FISH="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH")"; touch "$FISH"
  grep -Fqx "set -Ua PATH ${HOME}/.local/bin" "$FISH" || echo "set -Ua PATH ${HOME}/.local/bin" >> "$FISH"
fi

# 4) wrapper script (uses cowsay/lolcat if available, falls back to plain)
WRAP="${BIN_DIR}/ali-says-banner"
cat > "$WRAP" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

quote="$(ali-says)"
render="$quote"

# cowsay if available
if command -v python3 >/dev/null 2>&1 && python3 -c 'import cowsay' >/dev/null 2>&1; then
  render="$(python3 - <<'PY'
import sys, cowsay
print(cowsay.cow(sys.stdin.read().strip()))
PY
<<< "$quote")"
fi

# lolcat if available
if command -v lolcat >/dev/null 2>&1; then
  printf "%s\n" "$render" | lolcat
else
  printf "%s\n" "$render"
fi
SH
chmod +x "$WRAP"
echo "[ok] installed wrapper: $WRAP"

# 5) optional autorun
if ask_yes "[?] enable autorun on shell startup (bash/zsh/fish)? [y/N] "; then
  LINE='ali-says-banner'
  # bash/zsh
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f "$rc" ]] || continue
    grep -Fqx "$LINE" "$rc" || echo "$LINE" >> "$rc"
  done
  # fish
  if [[ -d "$HOME/.config/fish" ]]; then
    FISH="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH")"; touch "$FISH"
    grep -Fqx "$LINE" "$FISH" || echo "$LINE" >> "$FISH"
  fi
  echo "[ok] autorun enabled"
else
  echo "[skip] autorun not enabled"
fi

echo
echo "[done] ali-says installed (user). try:"
echo "  ali-says"
echo "  ali-says-manual"
echo "  ali-says-banner"
echo
echo "Tip: open a new terminal to load PATH changes."
