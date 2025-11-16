# STA Benchmark Harness 詳細說明

本目錄包含用於比較 OpenSTA、OpenTimer、iEDA/iSTA 和 Tatum 等靜態時序分析工具的完整測試框架。本文件提供所有腳本的詳細使用說明，以及工具間指令相容性的重要資訊。

## 目錄
1. [快速開始](#快速開始)
2. [核心檔案說明](#核心檔案說明)
3. [腳本詳細說明](#腳本詳細說明)
4. [工具指令相容性](#工具指令相容性)
5. [測試設計說明](#測試設計說明)
6. [新增設計流程](#新增設計流程)

---

## 快速開始

### 執行完整測試
```bash
cd benchmark/
./run_all.sh
```
結果會輸出到 `results/run_<timestamp>/` 目錄，包含各工具的執行紀錄和統計摘要。

### 手動執行單一工具
如需單獨測試某個工具而不執行完整流程：
```bash
# 1. 載入環境變數
source scripts/setup_benchmark_env.sh

# 2. 執行特定工具
# OpenSTA (batch mode)
$OPENSTA_BIN -exit scripts/opensta_batch.tcl

# OpenTimer (batch mode)
envsubst < scripts/opentimer_batch.ot | $OPENTIMER_BIN --stdin

# iSTA
$ISTA_BIN scripts/ista_simple.tcl
```

---

## 核心檔案說明

### `tool_paths.env`
**用途：** 集中管理所有 STA 工具的可執行檔路徑和測試設計選擇。

**內容結構：**
```bash
# 工具路徑（相對於專案根目錄或絕對路徑）
OPENSTA_BIN=OpenSTA/build/sta
OPENTIMER_BIN=OpenTimer/bin/ot-shell
ISTA_BIN=iEDA/build_dynamic/src/operation/bin/iSTA
TATUM_BIN=tatum/build/tatum_test/tatum_test

# 選擇測試設計
BENCHMARK_DESIGN=simple  # 或 gcd
```

**修改指南：**
- 若重新編譯工具或改變安裝位置，更新對應的 `*_BIN` 路徑
- 切換測試設計時，修改 `BENCHMARK_DESIGN` 為 `designs/` 下的目錄名稱
- 相對路徑會自動解析為專案根目錄的相對位置

**來源確認：** 此檔案由 `run_all.sh` 和 `setup_benchmark_env.sh` 讀取（第 15-20 行）。

---

### `run_all.sh`
**用途：** 自動化執行所有 STA 工具的完整測試流程。

**執行流程：**
1. 讀取 `tool_paths.env` 中的工具路徑和設計選擇
2. 載入 `designs/$BENCHMARK_DESIGN/design.env` 取得設計檔案資訊
3. 建立時間戳記的結果目錄 `results/run_<timestamp>/`
4. 依序執行：
   - OpenSTA (batch mode + interactive mode)
   - OpenTimer (batch mode + interactive mode)
   - iEDA/iSTA
   - Tatum（若有設定 `TATUM_BIN`）
5. 呼叫 `summarize_results.py` 產生統計摘要

**輸出結構：**
```
results/run_20250116_143022/
├── run_info.txt           # 本次執行的設計資訊
├── summary.txt            # 各工具的時序與效能摘要
├── OpenSTA_batch/
│   └── run.log           # OpenSTA batch mode 執行紀錄
├── OpenSTA_interactive/
│   └── run.log
├── OpenTimer_batch/
│   └── run.log
├── OpenTimer_interactive/
│   └── run.log
└── iEDA_iSTA/
    └── run.log
```

**執行限制：**
- **必須從 `benchmark/` 目錄執行**
- 腳本會自動設定所有 `BENCHMARK_*` 環境變數
- 個別 STA 腳本（`opensta_batch.tcl` 等）依賴這些變數，**無法單獨執行**

**來源確認：** 腳本內容見 `run_all.sh` 第 1-200 行。

---

## 腳本詳細說明

### `scripts/setup_benchmark_env.sh`
**用途：** 快速載入測試環境變數，允許手動執行單一工具而不需完整的 `run_all.sh` 流程。

**功能：**
1. 讀取 `tool_paths.env` 取得設計選擇（`BENCHMARK_DESIGN`）
2. 載入對應的 `designs/$BENCHMARK_DESIGN/design.env`
3. 將所有設計檔案路徑轉換為絕對路徑並匯出為環境變數：
   - `BENCHMARK_DESIGN_NAME`: 設計名稱
   - `BENCHMARK_DESIGN_TOP`: 頂層模組名稱
   - `BENCHMARK_DESIGN_NETLIST`: Verilog 網表路徑
   - `BENCHMARK_DESIGN_SDC`: SDC 約束檔路徑
   - `BENCHMARK_DESIGN_SPEF`: SPEF 寄生參數檔路徑
   - `BENCHMARK_LIB_EARLY`: Early timing library 路徑
   - `BENCHMARK_LIB_LATE`: Late timing library 路徑

**使用方式：**
```bash
# 必須使用 source 以保留環境變數
source scripts/setup_benchmark_env.sh

# 執行後會顯示已匯出的變數
已匯出共用環境：
  BENCHMARK_DESIGN_NAME=simple
  BENCHMARK_DESIGN_TOP=simple
  ...
```

**來源確認：** 腳本內容見 `scripts/setup_benchmark_env.sh` 第 1-60 行。

---

### OpenSTA 相關腳本

#### `scripts/opensta_common.tcl`
**用途：** OpenSTA 的共用執行流程，被 batch 和 interactive 模式重複使用。

**執行步驟：**
1. 讀取 `BENCHMARK_*` 環境變數（由 `run_all.sh` 或 `setup_benchmark_env.sh` 提供）
2. 載入 Liberty 函式庫（min/max corner）：
   ```tcl
   read_liberty -min $BENCHMARK_LIB_EARLY
   read_liberty -max $BENCHMARK_LIB_LATE
   ```
3. 讀取 Verilog 網表並連結設計：
   ```tcl
   read_verilog $BENCHMARK_DESIGN_NETLIST
   link_design $BENCHMARK_DESIGN_TOP
   ```
4. 套用 SDC 約束和 SPEF 寄生參數：
   ```tcl
   read_sdc $BENCHMARK_DESIGN_SDC
   read_spef $BENCHMARK_DESIGN_SPEF
   ```
5. 啟用時鐘傳播分析：
   ```tcl
   set_propagated_clock [all_clocks]
   ```
6. 產生時序報告：
   - `report_checks -path_delay min/max`: 顯示關鍵路徑
   - `report_tns -min/-max`: 總負餘裕（Total Negative Slack）
   - `report_wns -min/-max`: 最壞負餘裕（Worst Negative Slack）

**來源確認：** 腳本內容見 `scripts/opensta_common.tcl` 第 1-30 行。

#### `scripts/opensta_batch.tcl`
**用途：** OpenSTA 批次模式的入口點。

**功能：** 
- 載入 `opensta_common.tcl` 執行分析流程
- 自動結束 OpenSTA（`exit`），適合自動化測試

**執行方式：**
```bash
source scripts/setup_benchmark_env.sh
$OPENSTA_BIN -exit scripts/opensta_batch.tcl
```

**來源確認：** 腳本內容見 `scripts/opensta_batch.tcl` 第 1-7 行。

#### `scripts/opensta_interactive_commands.tcl`
**用途：** OpenSTA 互動模式的入口點，模擬從 stdin 輸入指令的場景。

**功能：**
- 與 batch 模式使用相同的 `opensta_common.tcl` 流程
- 支援透過管道或重導向輸入指令
- 執行完畢後自動退出

**執行方式：**
```bash
source scripts/setup_benchmark_env.sh
$OPENSTA_BIN < scripts/opensta_interactive_commands.tcl
```

**來源確認：** 腳本內容見 `scripts/opensta_interactive_commands.tcl` 第 1-18 行。

---

### OpenTimer 相關腳本

#### `scripts/opentimer_batch.ot`
**用途：** OpenTimer 的執行腳本範本，透過 `envsubst` 替換環境變數後執行。

**執行流程：**
1. 設定單執行緒模式：
   ```
   set_num_threads 1
   ```
2. 載入 Liberty 函式庫（early/late corner）：
   ```
   read_celllib -early ${BENCHMARK_LIB_EARLY}
   read_celllib -late  ${BENCHMARK_LIB_LATE}
   ```
   **注意：** OpenTimer 使用 `read_celllib` 而非 OpenSTA 的 `read_liberty`
3. 讀取設計檔案：
   ```
   read_verilog ${BENCHMARK_DESIGN_NETLIST}
   read_spef    ${BENCHMARK_DESIGN_SPEF}
   read_sdc     ${BENCHMARK_DESIGN_SDC}
   ```
4. 啟用 CPPR（Common Path Pessimism Removal）：
   ```
   cppr -enable
   ```
5. 更新時序並產生報告：
   ```
   update_timing
   report_timing -max/-min
   report_tns -max/-min
   report_wns -max/-min
   ```

**執行方式：**
```bash
source scripts/setup_benchmark_env.sh
envsubst < scripts/opentimer_batch.ot | $OPENTIMER_BIN --stdin
```

**來源確認：** 腳本內容見 `scripts/opentimer_batch.ot` 第 1-24 行。

---

### iSTA 相關腳本

#### `scripts/ista_simple.tcl`
**用途：** iEDA/iSTA 的執行腳本。

**特殊功能：**
1. 設定設計工作空間：
   ```tcl
   set_design_workspace $result_dir
   ```
   - 若 `run_all.sh` 提供 `BENCHMARK_RESULT_DIR`，使用該目錄
   - 否則回退到 `results/ieda_ista/` 作為預設位置
2. 讀取設計檔案：
   ```tcl
   read_netlist $netlist           # 注意：iSTA 使用 read_netlist 而非 read_verilog
   read_liberty $lib_files         # 可接受 list 形式的多個 Liberty 檔
   link_design $design_top
   read_sdc $sdc_file
   read_spef $spef_file
   ```
3. 產生 max 和 min 時序報告：
   ```tcl
   report_timing -delay_type max -digits 4
   report_timing -delay_type min -digits 4
   ```

**關鍵差異：**
- iSTA 使用 `read_netlist` 而非 `read_verilog`
- 需要明確設定工作空間目錄
- `read_liberty` 可一次接受多個檔案（list 形式）

**來源確認：** 腳本內容見 `scripts/ista_simple.tcl` 第 1-44 行。

---

### 結果分析工具

#### `scripts/summarize_results.py`
**用途：** 解析各工具的執行紀錄，提取效能和時序指標，產生統計摘要。

**功能：**
1. 掃描結果目錄下的所有工具子目錄
2. 從 `run.log` 提取：
   - 執行時間（real/user/sys）：來自 `/usr/bin/time` 輸出
   - WNS（Worst Negative Slack）：max/min
   - TNS（Total Negative Slack）：max/min
3. 針對不同工具使用專屬的解析器：
   - **OpenSTA**: 解析 `tns/wns min/max <value>` 格式
   - **OpenTimer**: 從倒數四個數字提取（順序：wns_min, wns_max, tns_min, tns_max）
   - **iSTA**: 解析表格式報告（`| Endpoint | ... | Slack |` 和 `| Clock | ... | TNS |`）
   - **Tatum**: 僅提取執行時間（無時序指標）

**輸出格式：**
```
Run directory: /path/to/results/run_20250116_143022
=====================================
Tool: OpenSTA batch
  Log: /path/to/run.log
  Runtime: real=1.23s user=1.15s sys=0.08s
  WNS (max/min): -10.724 / 5.432
  TNS (max/min): -20.800 / 10.123
-
Tool: OpenTimer batch
  ...
```

**執行方式：**
```bash
# 由 run_all.sh 自動呼叫
# 或手動執行：
scripts/summarize_results.py results/run_<timestamp>
```

**來源確認：** 程式碼見 `scripts/summarize_results.py` 第 1-220 行。

---

## 工具指令相容性

此部分整理各 STA 工具在 SDC 指令和檔案載入上的差異，協助您在工具間移植腳本或理解測試失敗的原因。

### SDC 指令支援差異

| 功能/命令 | OpenSTA | OpenTimer | iSTA | 轉換/備註 |
| --- | --- | --- | --- | --- |
| **clock port 自身 `set_input_delay`** | 報錯 0441，禁止 clock 與自身 port 成為 `-clock`/`get_ports` 的同一對象，命令被忽略 | 官方 SDC 範例允許在 clock port 上設定 `set_input_delay ... -clock my_clock` | `CmdSetInputDelay` 內建 `-clock` 選項並傳回 clock 名稱 | 在 OpenSTA 需把 clock 口延遲改寫成 `set_clock_latency/set_clock_transition` 並僅對資料腳使用 `set_input_delay` |
| **`set_input_transition -clock`** | 指令只接受 `[-rise\|-fall][-min\|-max] transition port_list`，沒有 `-clock` 參數 | SDC 範例允許 `set_input_transition ... -clock my_clock` | `CmdSetInputTransition` 定義了 `-clock` 字串選項並把 clock clamp 到對應 pin | 若要在 OpenSTA 設定 clock slew，需改用 `set_clock_transition`/`set_driving_cell` |
| **False/Multicycle/Max-Min Delay 例外** | `set_false_path/set_multicycle_path/set_max_delay/set_min_delay` 皆有完整語法 | 官方文件聲明僅支援 5 個 SDC 指令，例外類型完全缺席 | `Cmd.hh` 中提供 `CmdSetFalsePath/CmdSetMulticyclePath/CmdSetMaxDelay/CmdSetMinDelay` 類別 | 在 OpenTimer 需於前處理階段剔除路徑或靠報表後處理；其餘兩個工具可直接沿用 SDC 例外 |
| **Clock 相關（uncertainty/latency/groups/derate）** | 提供 `set_clock_groups/set_clock_latency/set_clock_transition/set_timing_derate` 等指令 | 不支援，指令表中只有 `create_clock` 與 I/O 約束 | `CmdSetClockGroups/CmdSetClockLatency/CmdSetClockUncertainty/CmdSetTimingDerate` 均已實作 | 若需在 OpenTimer 模擬 OCV/clock group，只能透過多角落腳本或外部程式處理；在 OpenSTA/iSTA 可原樣使用 |

**來源確認：** 
- OpenSTA 限制：`OpenSTA/doc/messages.txt:180-191`, `OpenSTA/doc/OpenSTA.fodt:10470-10498,11290-11311`
- OpenTimer 支援範圍：`OpenTimer/wiki/io/sdc.md:16-50`
- iSTA 實作：`iEDA/src/operation/iSTA/source/module/sdc-cmd/CmdSetIODelay.cc`, `Cmd.hh:160-453`

### 資料載入與報告指令名稱對照

| 目的 | OpenSTA | OpenTimer | iSTA | 移植提示 |
| --- | --- | --- | --- | --- |
| **讀取 Liberty** | `read_liberty` | `read_celllib` | `read_liberty` | 將 OpenSTA 腳本搬到 OpenTimer 時需把 `read_liberty` 換成 `read_celllib`；iSTA 延用 OpenSTA 寫法 |
| **讀取網表** | `read_verilog` + `link_design` | `read_verilog` | `read_netlist` + `link_design` | iSTA 需要獨立的 `read_netlist` 指令與 `set_design_workspace` 來指定報告輸出 |
| **讀取 SDC** | `read_sdc` | `read_sdc` | `read_sdc` | 三者指令名稱一致，可直接重用 |
| **讀取 SPEF / SDF** | `read_spef` 與 `read_sdf` 皆受支援 | `read_spef` 由 shell/API 提供但無 `read_sdf` | 官方教學僅列 `read_spef`；未記載 `read_sdf` 指令 | 如需 SDF 延遲，OpenSTA 可直接 `read_sdf`，OpenTimer/iSTA 則需將 SDF 轉 SPEF 或改用前置 RC tree |
| **報告命令** | `report_checks`/`report_tns`/`report_wns` | `report_timing`/`report_tns`/`report_wns` | `report_timing` | Porting 到 OpenTimer 時需以 `report_timing` 取代 OpenSTA 的 `report_checks`；iSTA 與 OpenTimer 相同 |

**來源確認：**
- OpenSTA 指令：`OpenSTA/doc/OpenSTA.fodt:6350-6367`
- OpenTimer 指令：`OpenTimer/README.md:57-229`
- iSTA 指令：`iEDA/iSTA使用教學.md:82-141`

### 實務轉換建議

1. **Clock 口延遲建模**
   - **問題：** OpenSTA 會拒絕 clock port 的 `set_input_delay`
   - **解決方案：** 改寫成 `set_clock_latency/-source` 或 `set_clock_transition` 來描述時鐘延遲，保留 `set_input_delay` 給資料腳
   - **適用工具：** OpenTimer 與 iSTA 可直接沿用原 SDC
   - **來源：** `OpenSTA/doc/messages.txt:180-191`, `OpenSTA/doc/OpenSTA.fodt:10470-10498`

2. **輸入 transition 與 clock slew**
   - **問題：** 在 OpenSTA 中，用 `set_input_transition` 設 clock 口 slews 會被忽略
   - **解決方案：** 拆成 `set_clock_transition`（for clock pins）＋`set_input_transition`（僅列資料 ports）
   - **適用工具：** OpenTimer/iSTA 因支援 `-clock`，無須拆分
   - **來源：** `OpenSTA/doc/OpenSTA.fodt:10476-10504,11290-11311`, `OpenTimer/wiki/io/sdc.md:42-50`, `iEDA/src/operation/iSTA/source/module/sdc-cmd/CmdSetInputTransition.cc:33-147`

3. **OpenTimer 的例外處理**
   - **限制：** shell 官方只允許 5 個 SDC 指令，缺少 false path、multicycle 等例外
   - **解決方案：** 
     - 在匯入 OpenTimer 前先以 OpenSTA/iSTA 的 `report_checks` 找出路徑並在網表/SDC 前處理
     - 或在報表輸出後自行過濾
   - **參考：** OpenSTA/iSTA 的 `set_false_path/set_clock_groups` 寫法可作為前處理階段的「真實」規格來源
   - **來源：** `OpenTimer/wiki/io/sdc.md:16-22`, `OpenSTA/doc/OpenSTA.fodt:10338-10410,10985-12039`, `iEDA/src/operation/iSTA/source/module/sdc-cmd/Cmd.hh:160-453`

---

## 測試設計說明

### `designs/simple/`
**來源：** OpenTimer 官方範例（`OpenTimer/example/simple/`）

**特性：**
- 極簡設計：單一模組、純量埠（無匯流排）
- 檔案組成：
  - `simple.v`: Verilog 網表
  - `simple.sdc`: 基本 SDC 約束（create_clock, set_input_delay, set_output_delay）
  - `simple.spef`: 簡短的 SPEF 寄生參數
  - `simple_Early.lib` / `simple_Late.lib`: Early/Late timing corner
- **相容性：** 所有工具（OpenSTA/OpenTimer/iSTA/Tatum）皆可成功執行

**預期結果：**
- WNS: ~-10.7 ns (VIOLATED)
- TNS: ~-20.8 ns

**來源確認：** `benchmark/README.md` 第 35 行原說明，來自 `OpenTimer/example/simple/`

### `designs/gcd/`
**來源：** OpenSTA sky130 測試案例（`OpenSTA/test/gcd_sky130hd/`）

**特性：**
- 真實工業設計：GCD（Greatest Common Divisor）電路
- 檔案組成：
  - `gcd_sky130hd.v`: 包含匯流排埠的 Verilog 網表
  - `gcd_sky130hd.sdc`: 複雜 SDC 約束（含匯流排物件 `req_msg[*]`）
  - `gcd_sky130hd.spef`: 真實 PnR 工具產生的 SPEF
  - `sky130hd_tt.lib`: SkyWater 130nm PDK 標準元件庫
- **相容性問題：**
  - **OpenTimer**: SPEF 解析失敗（`clk I` 條目與主輸出斷言衝突）
  - **iSTA**: SDC 解析失敗（無法處理 `req_msg[*]` 格式，需逐位元展開）
  - **僅 OpenSTA 可直接執行**

**已知限制：**
直到資料被清理（sanitize）前，預期只有 OpenSTA 能在 `gcd` 上成功。切換 `BENCHMARK_DESIGN` 或解讀執行紀錄時需注意這些限制。

**來源確認：** `benchmark/README.md` 第 40-47 行原說明，來自 `OpenSTA/test/gcd_sky130hd/`

---

## 新增設計流程

1. **建立設計目錄**
   ```bash
   mkdir designs/<new_design>
   ```

2. **複製設計檔案**
   將以下檔案放入新目錄：
   - Verilog 網表（`.v`）
   - SDC 約束檔（`.sdc`）
   - SPEF 寄生參數（`.spef`）
   - Liberty 函式庫（`*_Early.lib`, `*_Late.lib`）

3. **建立 `design.env`**
   ```bash
   # designs/<new_design>/design.env
   DESIGN_TOP=<頂層模組名稱>
   DESIGN_NETLIST=<網表檔名>.v
   DESIGN_SDC=<SDC檔名>.sdc
   DESIGN_SPEF=<SPEF檔名>.spef
   DESIGN_LIB_EARLY=<Early庫檔名>.lib
   DESIGN_LIB_LATE=<Late庫檔名>.lib
   ```

4. **更新 `tool_paths.env`**
   ```bash
   BENCHMARK_DESIGN=<new_design>
   ```

5. **執行測試**
   ```bash
   ./run_all.sh
   ```

6. **檢查結果**
   - 查看 `results/run_<timestamp>/summary.txt` 確認各工具執行狀態
   - 若有工具失敗，參考[工具指令相容性](#工具指令相容性)章節調整 SDC 或檔案格式

**來源確認：** `benchmark/README.md` 第 50-54 行原流程。

---

## 疑難排解

### 執行時找不到工具
**症狀：** `run_all.sh` 報錯 "Binary not found"

**解決方案：**
1. 確認 `tool_paths.env` 中的路徑正確
2. 檢查工具是否已編譯（例如 `OpenSTA/build/sta` 存在）
3. 若使用相對路徑，確保從 `benchmark/` 目錄執行

### OpenTimer SPEF 解析失敗
**症狀：** 執行 `gcd` 設計時 OpenTimer 中止

**解決方案：**
1. 使用 `simple` 設計驗證 OpenTimer 基本功能
2. 若需執行 `gcd`，需重新產生相容的 SPEF 或前處理現有檔案

**來源：** `benchmark/README.md` 第 41-42 行已知問題。

### iSTA SDC 解析錯誤
**症狀：** "object list is empty" 或匯流排名稱無法辨識

**解決方案：**
1. 將 SDC 中的 `[get_ports req_msg[*]]` 展開為個別位元
2. 或參考 `simple` 設計使用純量埠

**來源：** `benchmark/README.md` 第 44-46 行已知問題。

### 環境變數未設定
**症狀：** 單獨執行腳本時報錯 "Missing required environment variable"

**解決方案：**
```bash
source scripts/setup_benchmark_env.sh
```

**來源：** `scripts/setup_benchmark_env.sh` 第 20-30 行設計。

---

## 參考文件

- **OpenSTA 官方文件：** `OpenSTA/doc/OpenSTA.fodt`
- **OpenTimer 文件：** `OpenTimer/README.md`, `OpenTimer/wiki/io/sdc.md`
- **iSTA 使用教學：** `iEDA/iSTA使用教學.md`
- **工具分析報告：** `../STA_tool_analysis_report.md`

---

**最後更新：** 2025-11-16  
**維護者：** STA Benchmark Team
