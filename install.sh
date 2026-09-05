#!/usr/bin/env bash
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

for dir in agents commands skills; do
    link="$CLAUDE_DIR/$dir"
    target="$KIT/$dir"

    if [ -e "$link" ] && [ ! -L "$link" ]; then
        echo "warning: $link exists and is not a symlink."
        echo "         move its contents into $target, then re-run."
        exit 1
    fi

    ln -sfn "$target" "$link"
    echo "linked $dir -> $target"
done

if [ -f "$KIT/CLAUDE.md" ]; then
    ln -sfn "$KIT/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    echo "linked CLAUDE.md -> $KIT/CLAUDE.md"
fi

echo
echo "done. verify with: ls -l $CLAUDE_DIR"