#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

# 使用 sed -E (Extended Regex) 刪除:
# 1. 包含 "warning" 的行 (I = case insensitive)
# 2. 包含特定垃圾訊息 ID (LBDB-366, LBDB-272, LBDB-396)
sed -E -i '/warning|LBDB-366|LBDB-272|LBDB-396/Id' "$1"

echo "Removed lines containing 'warning' and specific noise codes from $1" 