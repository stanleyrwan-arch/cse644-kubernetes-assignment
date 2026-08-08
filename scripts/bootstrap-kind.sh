#!/usr/bin/env sh
set -eu

ASSIGNMENT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mkdir -p "$ASSIGNMENT_ROOT/tools"
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
case "$arch" in
  arm64|aarch64) kind_arch=arm64 ;;
  x86_64) kind_arch=amd64 ;;
  *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
esac

curl -fL --retry 2 -o "$ASSIGNMENT_ROOT/tools/kind" "https://kind.sigs.k8s.io/dl/latest/kind-${os}-${kind_arch}"
chmod +x "$ASSIGNMENT_ROOT/tools/kind"
"$ASSIGNMENT_ROOT/tools/kind" version
