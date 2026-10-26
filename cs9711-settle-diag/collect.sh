#!/usr/bin/env bash
# Measure how a CS9711 unit's frames differ while a finger is down.
#
# Builds the driver with the settle threshold switched off, so every frame of
# a press is logged, then runs two tests:
#   1. still: hold one finger flat and still until 40 frames are logged (~15 s)
#   2. presses: 15 ordinary presses, lifting fully each time
# and writes still.csv and presses.csv next to the logs. The examples may save
# an image or a print; each test runs in a temporary folder that is deleted
# when it ends, so neither is kept.
#
# Usage, from the repository root:
#   cs9711-settle-diag/collect.sh [out_dir]
# The examples need access to the USB device; run as root or with a udev rule.
set -euo pipefail

src=$(cd "$(dirname "$0")/.." && pwd)
out=${1:-$src/cs9711-settle-diag/out}
build=$src/builddir-settle-diag
mkdir -p "$out"

if [ ! -f "$build/build.ninja" ]; then
  CFLAGS="-DCS9711_SETTLE_MAD=-1 -DCS9711_SETTLE_MAX_FRAMES=40" \
    meson setup "$build" "$src" -Ddrivers=cs9711 -Ddoc=false \
    -Dgtk-examples=false -Dintrospection=false -Dinstalled-tests=false
fi
ninja -C "$build"

run() {
  # run <seconds> <log> <command...>; stdin is passed through
  local secs=$1 log=$2
  shift 2
  local tmp
  tmp=$(mktemp -d)
  ( cd "$tmp" && G_MESSAGES_DEBUG=all timeout --signal=INT "$secs" "$@" ) >"$log" 2>&1 || true
  rm -rf "$tmp"
}

echo
echo "Test 1: put one finger flat on the sensor and hold it still. Press Enter to start."
read -r
run 60 "$out/still.log" "$build/examples/img-capture" still.pgm </dev/null
echo "Done ($(grep -c 'differs from the last' "$out/still.log") frames). You can lift."

echo
echo "Test 2: make 15 ordinary presses, lifting fully each time. Press Enter to start."
read -r
printf '6\n' | run 90 "$out/presses.log" "$build/examples/enroll"
echo "Done ($(grep -c 'Frame 2 of this press' "$out/presses.log") presses)."

python3 "$src/cs9711-settle-diag/table.py" "$out/still.log" >"$out/still.csv"
python3 "$src/cs9711-settle-diag/table.py" "$out/presses.log" >"$out/presses.csv"
echo
echo "Wrote $out/still.csv and $out/presses.csv"
