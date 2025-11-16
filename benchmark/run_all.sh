#!/usr/bin/env bash
set -euo pipefail

# Resolve repo-relative paths.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/tool_paths.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Tool path config not found at $CONFIG_FILE" >&2
  exit 1
fi

# Load binary locations and default design selection.
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

# Canonicalize tool binary locations so we can invoke them anywhere.
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

# Pick the design folder and manifest (design.env) describing the collateral.
DESIGNS_ROOT="$SCRIPT_DIR/designs"
DESIGN_NAME="${BENCHMARK_DESIGN:-simple}"
DESIGN_DIR="$DESIGNS_ROOT/$DESIGN_NAME"
if [[ ! -d "$DESIGN_DIR" ]]; then
  echo "Design directory not found: $DESIGN_DIR" >&2
  exit 1
fi

DESIGN_ENV="$DESIGN_DIR/design.env"
if [[ ! -f "$DESIGN_ENV" ]]; then
  echo "Design config not found: $DESIGN_ENV" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$DESIGN_ENV"

resolve_design_path() {
  local raw="$1"
  if [[ "$raw" = /* ]]; then
    printf "%s" "$raw"
  else
    printf "%s/%s" "$DESIGN_DIR" "$raw"
  fi
}

DESIGN_TOP="${DESIGN_TOP:?Set DESIGN_TOP in $DESIGN_ENV}"
DESIGN_NETLIST_PATH="$(resolve_design_path "${DESIGN_NETLIST:?Set DESIGN_NETLIST in $DESIGN_ENV}")"
DESIGN_SDC_PATH="$(resolve_design_path "${DESIGN_SDC:?Set DESIGN_SDC in $DESIGN_ENV}")"
DESIGN_SPEF_PATH="$(resolve_design_path "${DESIGN_SPEF:?Set DESIGN_SPEF in $DESIGN_ENV}")"
DESIGN_LIB_EARLY_PATH="$(resolve_design_path "${DESIGN_LIB_EARLY:?Set DESIGN_LIB_EARLY in $DESIGN_ENV}")"
DESIGN_LIB_LATE_PATH="$(resolve_design_path "${DESIGN_LIB_LATE:?Set DESIGN_LIB_LATE in $DESIGN_ENV}")"

export BENCHMARK_DESIGN_NAME="$DESIGN_NAME"
export BENCHMARK_DESIGN_DIR="$DESIGN_DIR"
export BENCHMARK_DESIGN_TOP="$DESIGN_TOP"
export BENCHMARK_DESIGN_NETLIST="$DESIGN_NETLIST_PATH"
export BENCHMARK_DESIGN_SDC="$DESIGN_SDC_PATH"
export BENCHMARK_DESIGN_SPEF="$DESIGN_SPEF_PATH"
export BENCHMARK_LIB_EARLY="$DESIGN_LIB_EARLY_PATH"
export BENCHMARK_LIB_LATE="$DESIGN_LIB_LATE_PATH"

RESULT_ROOT="$SCRIPT_DIR/results"
mkdir -p "$RESULT_ROOT"

RUN_TIMESTAMP="$(date +%Y%m%dT%H%M%S)"

# Helper to create a unique directory by appending a serial suffix when needed.
make_unique_dir() {
  local base="$1"
  local candidate="$base"
  local serial=1
  while [[ -e "$candidate" ]]; do
    printf -v suffix "_%02d" "$serial"
    candidate="${base}${suffix}"
    serial=$((serial + 1))
  done
  mkdir -p "$candidate"
  printf "%s" "$candidate"
}

RUN_DIR="$(make_unique_dir "$RESULT_ROOT/run_${RUN_TIMESTAMP}")"
echo "INFO: Writing all outputs to $RUN_DIR"

# Allocate per-tool folders underneath the timestamped run directory.
make_tool_dir() {
  local name="$1"
  local dir="$RUN_DIR/$name"
  mkdir -p "$dir"
  printf "%s" "$dir"
}

# Provide a consistent /usr/bin/time format for every command we wrap.
TIME_CMD=(/usr/bin/time -f "TIME real=%E user=%U sys=%S")

# Wrapper that logs a heading, captures stdout/stderr, and stores it in run.log.
run_logged() {
  local name="$1"
  local log_path="$2"
  shift 2
  mkdir -p "$(dirname "$log_path")"
  echo "==> Running $name"
  "${TIME_CMD[@]}" "$@" >"$log_path" 2>&1
}

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Materialize the OpenTimer command file with absolute paths.
prepare_opentimer_script() {
  local template="$1"
  local output="$2"
  local vars='${BENCHMARK_LIB_EARLY} ${BENCHMARK_LIB_LATE} ${BENCHMARK_DESIGN_NETLIST} ${BENCHMARK_DESIGN_SPEF} ${BENCHMARK_DESIGN_SDC}'
  envsubst "$vars" <"$template" >"$output"
}

OT_SCRIPT="$TMP_DIR/opentimer_batch.ot"
prepare_opentimer_script "$SCRIPT_DIR/scripts/opentimer_batch.ot" "$OT_SCRIPT"

TATUM_TESTS_FILE="$SCRIPT_DIR/tatum/tests.list"

# Persist a bit of metadata so we can trace which design/collateral were used.
cat >"$RUN_DIR/run_info.txt" <<EOF_INFO
Design: $DESIGN_NAME
Design top: $DESIGN_TOP
Design dir: $DESIGN_DIR
Netlist: $DESIGN_NETLIST_PATH
SDC: $DESIGN_SDC_PATH
SPEF: $DESIGN_SPEF_PATH
Lib early: $DESIGN_LIB_EARLY_PATH
Lib late: $DESIGN_LIB_LATE_PATH
Timestamp: $RUN_TIMESTAMP
EOF_INFO

pushd "$REPO_ROOT" >/dev/null

OPENSTA_BATCH_DIR="$(make_tool_dir "OpenSTA_batch")"
run_logged "OpenSTA batch" \
  "$OPENSTA_BATCH_DIR/run.log" \
  "$OPENSTA_BIN" -exit "$SCRIPT_DIR/scripts/opensta_batch.tcl"

OPENSTA_INTERACTIVE_DIR="$(make_tool_dir "OpenSTA_interactive")"
run_logged "OpenSTA interactive" \
  "$OPENSTA_INTERACTIVE_DIR/run.log" \
  env BENCHMARK_SCRIPT_DIR="$SCRIPT_DIR/scripts" \
  "$OPENSTA_BIN" <"$SCRIPT_DIR/scripts/opensta_interactive_commands.tcl"

OPENTIMER_BATCH_DIR="$(make_tool_dir "OpenTimer_batch")"
run_logged "OpenTimer batch (--stdin)" \
  "$OPENTIMER_BATCH_DIR/run.log" \
  "$OPENTIMER_BIN" --stdin "$OT_SCRIPT"

OPENTIMER_INTERACTIVE_DIR="$(make_tool_dir "OpenTimer_interactive")"
run_logged "OpenTimer interactive (stdin)" \
  "$OPENTIMER_INTERACTIVE_DIR/run.log" \
  "$OPENTIMER_BIN" <"$OT_SCRIPT"

IEDA_RESULT_DIR="$(make_tool_dir "iEDA_iSTA")"
run_logged "iEDA iSTA script" \
  "$IEDA_RESULT_DIR/run.log" \
  env BENCHMARK_RESULT_DIR="$IEDA_RESULT_DIR" \
  "$ISTA_BIN" "$SCRIPT_DIR/scripts/ista_simple.tcl"

if [[ -f "$TATUM_TESTS_FILE" ]]; then
  while IFS=';' read -r name rel_path extra; do
    [[ -z "$name" || "$name" =~ ^# ]] && continue
    tatum_input="$SCRIPT_DIR/tatum/$rel_path"
    if [[ ! -f "$tatum_input" ]]; then
      echo "Warning: Skipping $name, missing input $tatum_input" >&2
      continue
    fi
    extra_args=()
    if [[ -n "$extra" ]]; then
      read -r -a extra_args <<<"$extra" || extra_args=()
    fi
    sanitized_name="${name//[^[:alnum:]_]/_}"
    sanitized_name="${sanitized_name:-default}"
    tatum_result_dir="$(make_tool_dir "Tatum_${sanitized_name}")"
    run_logged "Tatum $name" \
      "$tatum_result_dir/run.log" \
      "$TATUM_BIN" "${extra_args[@]}" "$tatum_input"
  done <"$TATUM_TESTS_FILE"
else
  echo "Warning: No Tatum tests list found at $TATUM_TESTS_FILE" >&2
fi

popd >/dev/null

SUMMARY_SCRIPT="$SCRIPT_DIR/scripts/summarize_results.py"
if [[ -x "$SUMMARY_SCRIPT" ]]; then
  # Capture the pretty-printed summary so the run directory is self-contained.
  if ! "$SUMMARY_SCRIPT" "$RUN_DIR" >"$RUN_DIR/summary.txt"; then
    echo "Warning: Failed to generate summary for $RUN_DIR" >&2
  fi
else
  echo "Warning: Summary script not found or not executable: $SUMMARY_SCRIPT" >&2
fi

echo "INFO: Run artifacts saved under $RUN_DIR"
