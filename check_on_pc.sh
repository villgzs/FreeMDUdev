#!/usr/bin/env bash
set -euo pipefail

usage () {
  echo 'chmod +x check.sh'
  echo './check.sh . x86_64-unknown-linux-gnu "default" true'
}

if [[ -n "$1" ]]; then
  usage()
fi

DIR="${1:-.}"
TARGET="${2:-}"
FEATURES="${3:-}"
RUN_TESTS="${4:-true}"

cd "$DIR"

BUILD_ARGS=()
CLIPPY_ARGS=()
TEST_ARGS=()

if [[ -n "$TARGET" ]]; then
  BUILD_ARGS+=(--target "$TARGET")
  CLIPPY_ARGS+=(--target "$TARGET")
  TEST_ARGS+=(--target "$TARGET")
fi

if [[ -n "$FEATURES" ]]; then
  BUILD_ARGS+=(--features "$FEATURES")
  CLIPPY_ARGS+=(--features "$FEATURES")
  TEST_ARGS+=(--features "$FEATURES")
fi

echo "==> Building..."
cargo build "${BUILD_ARGS[@]}" --release

echo "==> Checking format..."
cargo fmt --check

echo "==> Running clippy..."
cargo clippy "${CLIPPY_ARGS[@]}" -- -D warnings

if [[ "$RUN_TESTS" == "true" ]]; then
  echo "==> Running tests..."
  RUST_MIN_STACK=4000000 cargo test "${TEST_ARGS[@]}"
fi

echo "All checks passed!"
