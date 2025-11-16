#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/tool_paths.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Tool path config not found at $CONFIG_FILE" >&2
  exit 1
fi

source "$CONFIG_FILE"

REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
resolve_path() {
  local raw="$1"
  if [[ "$raw" = /* ]]; then
    printf "%s" "$raw"
  else
    printf "%s/%s" "$REPO_ROOT" "$raw"
  fi
}

OPENSTA_BIN="$(resolve_path "${OPENSTA_BIN:?Set OPENSTA_BIN in tool_paths.env}")"
OPENTIMER_BIN="$(resolve_path "${OPENTIMER_BIN:?Set OPENTIMER_BIN in tool_paths.env}")"
ISTA_BIN="$(resolve_path "${ISTA_BIN:?Set ISTA_BIN in tool_paths.env}")"
TATUM_BIN="$(resolve_path "${TATUM_BIN:?Set TATUM_BIN in tool_paths.env}")"

for bin in "$OPENSTA_BIN" "$OPENTIMER_BIN" "$ISTA_BIN" "$TATUM_BIN"; do
  if [[ ! -x "$bin" ]]; then
    echo "Executable not found or not executable: $bin" >&2
    exit 1
  fi
done

RESULT_ROOT="$SCRIPT_DIR/results"
mkdir -p "$RESULT_ROOT"

TIME_CMD=(/usr/bin/time -f "TIME real=%E user=%U sys=%S")

run_logged() {
  local name="$1"
  local log_path="$2"
  shift 2
  mkdir -p "$(dirname "$log_path")"
  echo "==> Running $name"
  "${TIME_CMD[@]}" "$@" >"$log_path" 2>&1
}

pushd "$REPO_ROOT" >/dev/null

run_logged "OpenSTA batch" \
  "$RESULT_ROOT/opensta_batch/run.log" \
  "$OPENSTA_BIN" -exit "$SCRIPT_DIR/scripts/opensta_batch.tcl"

run_logged "OpenSTA interactive" \
  "$RESULT_ROOT/opensta_interactive/run.log" \
  "$OPENSTA_BIN" <"$SCRIPT_DIR/scripts/opensta_interactive_commands.tcl"

run_logged "OpenTimer batch (--stdin)" \
  "$RESULT_ROOT/opentimer_batch/run.log" \
  "$OPENTIMER_BIN" --stdin "$SCRIPT_DIR/scripts/opentimer_batch.ot"

run_logged "OpenTimer interactive (stdin)" \
  "$RESULT_ROOT/opentimer_interactive/run.log" \
  "$OPENTIMER_BIN" <"$SCRIPT_DIR/scripts/opentimer_batch.ot"

run_logged "iEDA iSTA script" \
  "$RESULT_ROOT/ieda_ista/run.log" \
  "$ISTA_BIN" "$SCRIPT_DIR/scripts/ista_simple.tcl"

run_logged "Tatum simple_comb serial" \
  "$RESULT_ROOT/tatum/simple_comb_serial.log" \
  "$TATUM_BIN" --num_serial 1 --num_serial_incr 0 --num_parallel 0 "$SCRIPT_DIR/tatum/simple_comb.tatum"

run_logged "Tatum simple_multiclock incr" \
  "$RESULT_ROOT/tatum/simple_multiclock_incr.log" \
  "$TATUM_BIN" --num_serial 1 --num_serial_incr 5 --num_parallel 0 --edge_change_prob 0.2 "$SCRIPT_DIR/tatum/simple_multiclock.tatum"

popd >/dev/null
