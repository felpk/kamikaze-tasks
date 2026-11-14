#!/usr/bin/env bash
# Links kt into ~/.local/bin (or $KT_BIN). Needs bash, jq and the claude CLI.
set -euo pipefail
src="$(cd "$(dirname "$0")" && pwd)/bin/kt"
bin="${KT_BIN:-$HOME/.local/bin}"
for dep in jq claude; do command -v "$dep" >/dev/null || echo "warning: $dep not found in PATH" >&2; done
mkdir -p "$bin"; ln -sf "$src" "$bin/kt"
echo "kt linked at $bin/kt"
case ":$PATH:" in *":$bin:"*) ;; *) echo "add $bin to your PATH";; esac
echo "optional tmux binding: bind K split-window -c '#{pane_current_path}' kt"
