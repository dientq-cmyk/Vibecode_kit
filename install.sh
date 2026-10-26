#!/usr/bin/env bash
# Finance AI Kit — cài / cập nhật kit vào repo dự án.
#
# Chạy ở ROOT repo dự án:
#   curl -fsSL https://raw.githubusercontent.com/dientq-cmyk/Vibecode_kit/main/install.sh | bash
#
# Script làm:
#   1. Chép kit vào docs/ai-kit/ (chép đè nếu đã có — đây cũng là cách cập nhật kit).
#   2. CLAUDE.md ở root, apps/api, apps/web: chưa có thì tạo từ template;
#      có rồi mà thiếu dòng @import kit thì chèn dòng đó lên đầu. Không sửa gì khác.
#   3. Không commit — bạn tự xem diff rồi commit.
#
# Biến tuỳ chọn: KIT_REF=<nhánh hoặc tag> (mặc định main).

set -euo pipefail

KIT_REPO="https://github.com/dientq-cmyk/Vibecode_kit.git"
KIT_REF="${KIT_REF:-main}"
KIT_DIR="docs/ai-kit"

say() { printf '  %s\n' "$1"; }

if ! command -v git >/dev/null 2>&1; then
  echo "Lỗi: cần cài git trước." >&2
  exit 1
fi

if [ "$(git rev-parse --show-toplevel 2>/dev/null || true)" != "$(pwd -P)" ]; then
  echo "Lỗi: hãy chạy script ở thư mục root của repo dự án (thư mục có .git)." >&2
  exit 1
fi

# Nguồn kit: chạy từ bản clone của kit thì dùng luôn bản đó, chạy qua curl thì tải về.
SRC=""
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
  if [ -f "$SCRIPT_DIR/KIT_VERSION.md" ] && [ -d "$SCRIPT_DIR/rules" ]; then
    SRC="$SCRIPT_DIR"
  fi
fi

TMP=""
cleanup() { if [ -n "$TMP" ]; then rm -rf "$TMP"; fi; }
trap cleanup EXIT

if [ -z "$SRC" ]; then
  TMP="$(mktemp -d)"
  echo "Tải kit ($KIT_REF)..."
  git clone --quiet --depth 1 --branch "$KIT_REF" "$KIT_REPO" "$TMP/kit"
  SRC="$TMP/kit"
fi

if [ "$SRC" = "$(pwd -P)/$KIT_DIR" ]; then
  echo "Lỗi: không chạy script từ chính $KIT_DIR — chạy bản clone kit ở chỗ khác hoặc dùng curl." >&2
  exit 1
fi

echo "Chép kit vào $KIT_DIR/"
mkdir -p "$KIT_DIR"
for item in CLAUDE.md KIT_VERSION.md README.md install.sh rules smartosc templates; do
  rm -rf "${KIT_DIR:?}/$item"
  cp -R "$SRC/$item" "$KIT_DIR/$item"
done
say "phiên bản: $(grep -m1 'Hiện tại' "$KIT_DIR/KIT_VERSION.md" | sed 's/[*]//g')"

# ensure_claude <file đích> <template> <dòng import>
ensure_claude() {
  local target="$1" template="$2" import_line="$3"
  if [ ! -f "$target" ]; then
    cp "$KIT_DIR/templates/$template" "$target"
    say "tạo $target từ template — nhớ điền các mục TBD"
  elif grep -qxF "$import_line" "$target"; then
    say "$target đã nạp kit — giữ nguyên"
  else
    { printf '%s\n\n' "$import_line"; cat "$target"; } > "$target.tmp"
    mv "$target.tmp" "$target"
    say "chèn dòng '$import_line' vào đầu $target"
  fi
}

echo "Gắn kit vào CLAUDE.md"
ensure_claude "CLAUDE.md" "project-CLAUDE.md" "@docs/ai-kit/CLAUDE.md"
if [ -d apps/api ]; then
  ensure_claude "apps/api/CLAUDE.md" "api-CLAUDE.md" "@../../docs/ai-kit/rules/backend-rules.md"
fi
if [ -d apps/web ]; then
  ensure_claude "apps/web/CLAUDE.md" "web-CLAUDE.md" "@../../docs/ai-kit/rules/ui-data-rules.md"
fi

cat <<'EOF'

Xong. Chưa commit gì. Bước tiếp:
  1. Xem thay đổi:   git status && git diff
  2. Commit:         git add docs/ai-kit CLAUDE.md (+ apps/api, apps/web CLAUDE.md nếu có)
                     git commit -m "docs(ai-kit): add finance ai kit"
  3. Mở Claude Code ở root dự án, cho phép nạp file import, gõ /memory để kiểm có các file docs/ai-kit/.
EOF
