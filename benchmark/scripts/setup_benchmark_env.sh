#!/usr/bin/env bash
# Prepare BENCHMARK_* environment variables so individual STA scripts can be
# invoked directly (without run_all.sh).
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BENCHMARK_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$BENCHMARK_ROOT/tool_paths.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing tool_paths.env at $CONFIG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"
DESIGN_NAME="${BENCHMARK_DESIGN:-simple}"
DESIGN_DIR="$BENCHMARK_ROOT/designs/$DESIGN_NAME"
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
resolve() {
  local raw="$1"
  if [[ "$raw" = /* ]]; then
    printf "%s" "$raw"
  else
    printf "%s/%s" "$DESIGN_DIR" "$raw"
  fi
}

export BENCHMARK_DESIGN_NAME="${DESIGN_NAME}"
export BENCHMARK_DESIGN_TOP="${DESIGN_TOP:?Missing DESIGN_TOP in design.env}"
export BENCHMARK_DESIGN_NETLIST="$(resolve "${DESIGN_NETLIST:?Missing DESIGN_NETLIST}" )"
export BENCHMARK_DESIGN_SDC="$(resolve "${DESIGN_SDC:?Missing DESIGN_SDC}" )"
export BENCHMARK_DESIGN_SPEF="$(resolve "${DESIGN_SPEF:?Missing DESIGN_SPEF}" )"
export BENCHMARK_LIB_EARLY="$(resolve "${DESIGN_LIB_EARLY:?Missing DESIGN_LIB_EARLY}" )"
export BENCHMARK_LIB_LATE="$(resolve "${DESIGN_LIB_LATE:?Missing DESIGN_LIB_LATE}" )"

cat <<EOF_INFO
已匯出共用環境：
  BENCHMARK_DESIGN_NAME=$BENCHMARK_DESIGN_NAME
  BENCHMARK_DESIGN_TOP=$BENCHMARK_DESIGN_TOP
  BENCHMARK_DESIGN_NETLIST=$BENCHMARK_DESIGN_NETLIST
  BENCHMARK_DESIGN_SDC=$BENCHMARK_DESIGN_SDC
  BENCHMARK_DESIGN_SPEF=$BENCHMARK_DESIGN_SPEF
  BENCHMARK_LIB_EARLY=$BENCHMARK_LIB_EARLY
  BENCHMARK_LIB_LATE=$BENCHMARK_LIB_LATE

接下來可以手動執行：
  OpenSTA/build/sta -exit benchmark/scripts/opensta_batch.tcl
  OpenTimer/bin/ot-shell --stdin <(envsubst ... < benchmark/scripts/opentimer_batch.ot)
  iEDA/build_dynamic/src/operation/bin/iSTA benchmark/scripts/ista_simple.tcl
EOF_INFO
