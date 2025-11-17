# STA Benchmark 測試框架

本目錄包含用於測試和比較 OpenSTA、OpenTimer 和 iEDA/iSTA 三個靜態時序分析工具的 TCL 腳本集。所有工具皆使用 TCL 腳本進行批次執行，方便進行客製化修改和工具間比較。

### 近期更新（2025-11-17）
- 各工具腳本新增 `design.env` 自動解析機制，只需設定 `design_name`/`design_dir` 即可導入專案專屬檔名。
- OpenTimer 腳本改為 Tcl 包裝器，會生成指令暫存檔並直接呼叫 `ot-shell --stdin`，減少手動輸入。
- 追加 simple/gcd 兩組測試說明與日誌路徑，方便快速驗證。

## 目錄
1. [目錄結構](#目錄結構)
2. [快速開始](#快速開始)
3. [TCL 腳本說明](#tcl-腳本說明)
4. [工具指令相容性](#工具指令相容性)
5. [測試設計說明](#測試設計說明)
6. [新增設計流程](#新增設計流程)

---

## 目錄結構

```
benchmark/
├── README.md                          # 本文件
├── tool_paths.env                     # 舊版流程遺留，可忽略
├── designs/                           # 測試設計目錄
│   ├── simple/                       # 簡單測試案例（所有工具相容）
│   │   ├── simple.v                  # Verilog 網表
│   │   ├── simple.sdc                # SDC 約束檔
│   │   ├── simple.spef               # SPEF 寄生參數
│   │   ├── simple_Early.lib          # Early corner Liberty
│   │   ├── simple_Late.lib           # Late corner Liberty
│   │   └── design.env                # （可選）設計專屬檔案對應
│   └── gcd/                          # GCD 測試案例（僅 OpenSTA 完全相容）
│       ├── gcd_sky130hd.v
│       ├── gcd_sky130hd.sdc
│       ├── gcd_sky130hd.spef
│       └── sky130hd_tt.lib
└── scripts/                           # TCL 執行腳本
    ├── opensta_common.tcl            # OpenSTA 執行腳本
    ├── opentimer_batch.ot            # OpenTimer 執行腳本
    └── ista_simple.tcl               # iSTA 執行腳本
```

---

## 快速開始

### 執行 OpenSTA
1. 編輯 `scripts/opensta_common.tcl` 開頭的 `design_name`（必要時可調整 `design_dir`）。若目錄內含 `design.env`，腳本會自動讀取檔名與 top 模組設定。
2. 執行下列指令：
   ```bash
   cd benchmark/
   /path/to/OpenSTA/build/sta -exit scripts/opensta_common.tcl
   ```

### 執行 OpenTimer
1. 編輯 `scripts/opentimer_batch.ot` 開頭的 `opentimer_bin`、`design_name`（與 `design_dir`）。若該設計資料夾含 `design.env`，腳本會自動載入檔名。
2. 直接以 `tclsh` 執行腳本，腳本會自動呼叫 OpenTimer：
   ```bash
   cd benchmark/
   tclsh scripts/opentimer_batch.ot
   ```

### 執行 iSTA
1. 編輯 `scripts/ista_simple.tcl` 開頭的 `design_name`（必要時調整 `design_dir`/`result_dir`）。若資料夾含 `design.env`，腳本會自動帶入檔名與 top。
2. 直接執行腳本：
   ```bash
   cd benchmark/
   /path/to/iEDA/build/bin/iSTA scripts/ista_simple.tcl
   ```

### 切換設計與範例紀錄
- 若僅需臨時切換設計，可在啟動腳本前以 `set design_name <name>` 或 `set design_dir <path>` 覆寫，接著 `source` 共同腳本。例如：
  ```tcl
  # OpenSTA (gcd)
  set design_name "gcd"
  set design_dir [file normalize "benchmark/designs/gcd"]
  source benchmark/scripts/opensta_common.tcl
  ```
- 亦可直接修改 `design.env` 以指定 `DESIGN_*` 欄位（netlist、liberty、sdc、spef、top 名稱等），腳本會自動解析。
- 近期測試：
  - **simple**：三種工具皆通過；log 見 `results/` 目錄（例如 `results/ieda_ista/run.log`）。
  - **gcd**：
    - OpenSTA 可正常執行，log：`benchmark/results/opensta_gcd.log`。
    - OpenTimer 因 `gcd_sky130hd.spef` 的 `clk I` 條目導致 parser assertion；log：`benchmark/results/opentimer_gcd.log`。
    - iSTA 在處理 `set_input_delay` 的 wildcard 物件（`req_msg[*]` 等）時找不到對應 pin，因此中止；log：`benchmark/results/ieda_ista_gcd/run.log`。


---

## TCL 腳本說明

### `scripts/opensta_common.tcl`
**工具：** OpenSTA  
**用途：** OpenSTA 的標準執行流程腳本。

**執行步驟：**
1. 在檔案開頭的 `User configuration` 區塊設定 `design_name`、`design_top` 以及 `design_dir`（若設計目錄含 `design.env`，會自動帶入 `DESIGN_*` 變數指定的檔名與 top）。
2. 載入 Liberty 函式庫（min/max corner）：
   ```tcl
   read_liberty -min $lib_early
   read_liberty -max $lib_late
   ```
3. 讀取 Verilog 網表並連結設計：
   ```tcl
   read_verilog $netlist
   link_design $design_top
   ```
4. 套用 SDC 約束和 SPEF 寄生參數：
   ```tcl
   read_sdc $sdc_file
   read_spef $spef_file
   ```
5. 啟用時鐘傳播分析：
   ```tcl
   set_propagated_clock [all_clocks]
   ```
6. 產生時序報告：
   - `report_checks -path_delay min/max`: 顯示關鍵路徑
   - `report_tns -min/-max`: 總負餘裕（Total Negative Slack）
   - `report_wns -min/-max`: 最壞負餘裕（Worst Negative Slack）

**修改指南：**
- 只需調整檔案最上方的 `design_name`、`design_top`、`design_dir`，或直接指定 `lib_early` 等檔案變數。
- 如需不同的報告精度，可調整 `report_checks` 與 `report_timing` 的 `-digits` 參數。
- 設計資料夾若提供 `design.env`（`DESIGN_*` 參數），會自動覆寫腳本中的檔名設定。

**來源確認：** 腳本內容見 `scripts/opensta_common.tcl`

---

### `scripts/opentimer_batch.ot`
**工具：** OpenTimer  
**用途：** Tcl 包裝腳本，會依照設定生成 OpenTimer 指令並呼叫 `ot-shell`。

**執行流程：**
1. 在檔案開頭設定 `opentimer_bin`、`design_name` 與 `design_dir`（若資料夾含 `design.env`，會依 `DESIGN_*` 參數覆寫路徑），腳本會自動推導 `${design_name}_{Early,Late}.lib` 與同名的 `v/sdc/spef` 檔案；若命名不同，可直接修改 `lib_early` 等變數。
2. 腳本會建立暫存 OT 指令檔，內容為：
   ```
   set_num_threads 1
   read_celllib -early $lib_early
   read_celllib -late  $lib_late
   read_verilog        $netlist
   read_spef           $spef_file
   read_sdc            $sdc_file
   cppr -enable
   update_timing
   report_timing -max
   report_timing -min
   report_tns -max
   report_tns -min
   report_wns -max
   report_wns -min
   exit
   ```
   **注意：** OpenTimer 使用 `read_celllib`。
3. 透過 `exec $opentimer_bin --stdin <tmp>` 執行 ot-shell 並回傳完整 log。

**修改指南：**
- 調整 `opentimer_bin`、`design_name`、`design_dir`，或直接覆寫 `lib_early` 等變數以符合自訂命名。
- 若設計資料夾提供 `design.env`（`DESIGN_NETLIST`、`DESIGN_LIB_*` 等欄位），腳本會自動讀取並覆寫對應變數。
- OpenTimer 對 SDC 指令支援有限，若遇錯誤可精簡約束。

**來源確認：** 腳本內容見 `scripts/opentimer_batch.ot`

---

### `scripts/ista_simple.tcl`
**工具：** iEDA/iSTA  
**用途：** iSTA 的執行腳本。

**執行流程：**
1. 在檔案開頭設定 `design_name`、`design_dir` 與 `result_dir`（若資料夾含 `design.env`，會依 `DESIGN_*` 欄位覆寫檔名與 top），同時可依需要修改 `design_top` 或自訂各檔案變數。
2. 建立並指向工作空間：
   ```tcl
   file mkdir $result_dir
   set_design_workspace $result_dir
   ```
3. 讀取設計檔案：
   ```tcl
   read_netlist $netlist           ;# iSTA 使用 read_netlist
   read_liberty $lib_files         ;# 可一次指定多個 Liberty
   link_design $design_top
   read_sdc  $sdc_file
   read_spef $spef_file
   ```
4. 產生 max 和 min 時序報告：
   ```tcl
   report_timing -delay_type max -digits 4
   report_timing -delay_type min -digits 4
   ```

**關鍵差異：**
- iSTA 仍需工作空間（`set_design_workspace`）。
- `read_liberty` 接受 list 參數，可同時指定 early/late。

**修改指南：**
- 調整 `design_name`、`design_dir`、`result_dir`，必要時可直接編輯 `lib_files`、`netlist` 等變數。
- 若資料夾提供 `design.env`，可在其中維護 `DESIGN_NETLIST/DESIGN_LIB_*` 等欄位，由腳本自動讀取。
- 可根據需求調整 `report_timing` 的 `-digits` 參數。

**來源確認：** 腳本內容見 `scripts/ista_simple.tcl`

---

## 工具指令相容性

此部分整理各 STA 工具在 SDC 指令和檔案載入上的差異，協助您在工具間移植 TCL 腳本或理解執行失敗的原因。

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

### TCL 腳本移植範例

#### 從 OpenSTA 移植到 OpenTimer

**OpenSTA 腳本：**
```tcl
read_liberty -min design_Early.lib
read_liberty -max design_Late.lib
read_verilog design.v
link_design top_module
read_sdc design.sdc
read_spef design.spef
set_propagated_clock [all_clocks]
report_checks -path_delay max
report_wns -max
```

**OpenTimer 腳本：**
```tcl
# 1. 將 read_liberty 改為 read_celllib
read_celllib -early design_Early.lib
read_celllib -late design_Late.lib

# 2. read_verilog 和 read_sdc 相同
read_verilog design.v
read_sdc design.sdc
read_spef design.spef

# 3. OpenTimer 使用 cppr -enable 而非 set_propagated_clock
cppr -enable

# 4. 需要先 update_timing，report_checks 改為 report_timing
update_timing
report_timing -max
report_wns -max
```

#### 從 OpenSTA 移植到 iSTA

**OpenSTA 腳本：**
```tcl
read_liberty -min design_Early.lib
read_liberty -max design_Late.lib
read_verilog design.v
link_design top_module
read_sdc design.sdc
read_spef design.spef
report_checks -path_delay max
```

**iSTA 腳本：**
```tcl
# 1. 需要先設定工作空間
set_design_workspace ./ista_workspace

# 2. read_verilog 改為 read_netlist
read_netlist design.v

# 3. read_liberty 可接受 list，不分 -min/-max
read_liberty [list design_Early.lib design_Late.lib]

# 4. link_design 相同
link_design top_module

# 5. read_sdc 和 read_spef 相同
read_sdc design.sdc
read_spef design.spef

# 6. report_checks 改為 report_timing，需指定 delay_type
report_timing -delay_type max
```

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

## 測試設計

### Simple 電路

**設計檔案位置：** `designs/simple/`

**來源：** OpenTimer 官方範例（`OpenTimer/example/simple/`）

**電路架構：**
```
┌───────────┐
│   clk_in  ├──┐
└───────────┘  │
               │ (clock)
┌───────────┐  │   ┌──────────┐   ┌──────────┐   ┌──────────┐
│   inp1    ├──┴──►│   DFF    ├──►│  NAND2   ├──►│   DFF    ├──► out
└───────────┘      └──────────┘   └─────┬────┘   └──────────┘
┌───────────┐                            │
│   inp2    ├────────────────────────────┘
└───────────┘
```

**輸入/輸出：**
- `clk_in`：時鐘訊號
- `inp1`：資料輸入 1（有 setup/hold delay，synchronous to clk_in）
- `inp2`：資料輸入 2（asynchronous）
- `out`：資料輸出

**檔案清單：**
```
designs/simple/
├── simple.v          # Gate-level Verilog netlist
├── simple.sdc        # SDC constraints (原始版本)
├── simple.spef       # Parasitic extraction
├── simple_fixed.sdc  # OpenSTA 相容版本（移除 clock port 的 set_input_delay）
└── fake.lib          # Liberty timing library (minimal model)
```

**時序特性：**
- **Clock Period:** 10.0 ns (100 MHz)
- **Input Delay (inp1):** 2.0 ns (相對於 clk_in)
- **Input Transition:** 0.2 ns
- **Output Load:** 0.005 pF
- **預期 WNS:** ~-10.7 ns (VIOLATED)
- **預期 TNS:** ~-20.8 ns

**SDC 版本差異：**
- `simple.sdc`：原始版本，在 clock port (`clk_in`) 使用 `set_input_delay`，OpenTimer 和 iSTA 可執行
- `simple_fixed.sdc`：OpenSTA 相容版本，使用 `set_clock_latency -source` 替代 clock port 的 `set_input_delay`

**工具相容性：** 所有工具（OpenSTA/OpenTimer/iSTA）皆可執行（需選擇正確的 SDC 版本）

**使用方式：**
```bash
# OpenSTA（需使用 _fixed 版本，修改 opensta_common.tcl）
cd /home/a1023/STA
sta -no_splash -no_init -exit OpenSTA/build/benchmark/scripts/opensta_common.tcl

# OpenTimer（可使用原版或 _fixed，修改 opentimer_batch.ot）
cd /home/a1023/STA/benchmark
tclsh scripts/opentimer_batch.ot

# iSTA（可使用原版或 _fixed，修改 ista_simple.tcl）
cd /home/a1023/STA
/home/a1023/STA/iEDA/build/bin/iSTA ./benchmark/scripts/ista_simple.tcl
```

---

### GCD 電路

**設計檔案位置：** `designs/gcd/`

**來源：** OpenSTA sky130 測試案例（`OpenSTA/test/gcd_sky130hd/`）

**電路功能：** Greatest Common Divisor (最大公因數) 計算器

**輸入/輸出：**
- `clk`：時鐘訊號
- `reset`：重置訊號
- `req_val`：請求有效訊號
- `req_msg[31:0]`：輸入資料（32-bit bus）
- `resp_val`：回應有效訊號
- `resp_msg[15:0]`：輸出結果（16-bit bus）

**檔案清單：**
```
designs/gcd/
├── gcd.v          # Gate-level Verilog netlist
├── gcd_Early.lib  # Early corner Liberty library (fast process)
├── gcd_Late.lib   # Late corner Liberty library (slow process)
├── gcd.sdc        # SDC constraints (原始版本)
├── gcd.spef       # Parasitic extraction (from real PnR tool)
├── gcd_fixed.sdc  # OpenSTA 相容版本
└── wrapper.v      # RTL wrapper (未使用)
```

**時序特性：**
- **Clock Period:** 5.0 ns (200 MHz)
- **Clock Uncertainty:** 0.3 ns
- **Input Delay (all data ports):** 0.5 ns (相對於 clk)
- **Output Delay (all output ports):** 0.5 ns
- **Multi-Corner:** Early/Late corner libraries for setup/hold analysis

**SDC 版本差異：**
- `gcd.sdc`：原始版本，包含 bus notation (`req_msg[*]`)，包含 clock port 的 `set_input_delay` 和 `set_input_transition -clock`
- `gcd_fixed.sdc`：OpenSTA 相容版本，使用 `set_clock_latency -source` 和 `set_clock_transition` 替代 clock port 約束

**工具相容性限制：**
- **OpenSTA：** 可直接執行（需使用 `_fixed` 版本）
- **OpenTimer：** SPEF 解析失敗（`clk I` 條目與主輸出斷言衝突）
- **iSTA：** SDC 解析失敗（無法處理 `req_msg[*]` 格式，需逐位元展開成 `req_msg[0]`, `req_msg[1]`, ...）

**使用方式：**
```bash
# OpenSTA（需使用 _fixed 版本，修改 opensta_common.tcl 中的設計路徑）
cd /home/a1023/STA
sta -no_splash -no_init -exit OpenSTA/build/benchmark/scripts/opensta_common.tcl

# OpenTimer（SPEF 解析問題，需修正 SPEF 檔或設計）
# OpenTimer 目前無法執行 GCD 設計

# iSTA（SDC bus notation 問題，需展開匯流排）
# iSTA 目前無法執行 GCD 設計
```

**注意事項：**
- GCD 電路為真實工業設計，包含複雜的控制邏輯和資料路徑
- 支援 Multi-Corner Analysis（Early/Late corner）
- 目前只有 OpenSTA 可成功執行完整分析
- OpenTimer 和 iSTA 需要對設計檔案進行清理（sanitize）才能執行

---

## 新增設計流程

若要在 benchmark 中新增測試設計：

1. **建立設計目錄：**
   ```bash
   mkdir designs/<new_design>
   ```

2. **準備設計檔案：**
   將以下檔案放入新目錄：
   - Verilog 網表（`.v`）
   - SDC 約束檔（`.sdc`）
   - SPEF 寄生參數（`.spef`）
   - Liberty 函式庫（`*_Early.lib`, `*_Late.lib` 或單一 `.lib`）

3. **修改 TCL 腳本：**
   編輯對應工具的 TCL 腳本（`opensta_common.tcl`, `opentimer_batch.ot`, `ista_simple.tcl`）：
   - 更新檔案路徑變數指向新設計
   - 調整 top module 名稱
   - 確認 Liberty library 路徑正確

4. **驗證相容性：**
   - 檢查 SDC 語法是否符合目標工具支援範圍
   - 確認 SPEF 格式正確（特別是 OpenTimer）
   - 測試匯流排 notation 是否被工具支援（特別是 iSTA）

5. **執行測試：**
   ```bash
   # 依照前述「使用方式」執行各工具的 TCL 腳本
   # 比對輸出報告確認時序分析結果
   ```

---

## 問題排除

### OpenSTA 報錯 0441：Clock port input delay
**症狀：** 執行時出現 "Warning 0441" 訊息，指出 clock port 無法使用 `set_input_delay`

**解決方案：**
1. 使用 `_fixed.sdc` 版本的約束檔（已將 clock port 約束改為 `set_clock_latency`）
2. 或手動修改 SDC：將 `set_input_delay -clock clk_in [get_ports clk_in]` 改為 `set_clock_latency -source 2.0 [get_clocks clk_in]`

**來源：** OpenSTA 文件 `OpenSTA/doc/messages.txt:180-191`, `OpenSTA/doc/OpenSTA.fodt:10470-10498`

### OpenTimer SPEF 解析失敗
**症狀：** 執行 `gcd` 設計時 OpenTimer 中止，報告 SPEF parsing error

**解決方案：**
1. 使用 `simple` 設計驗證 OpenTimer 基本功能
2. `gcd` 設計的 SPEF 檔案（來自 OpenSTA 測試案例）與 OpenTimer 解析器不相容，需重新產生或手動修正

**來源：** 已知問題，見「測試設計 > GCD 電路 > 工具相容性限制」

### iSTA SDC 匯流排語法錯誤
**症狀：** 執行時報告 "object list is empty" 或匯流排名稱無法辨識

**解決方案：**
1. iSTA 不支援 SDC 中的 bus notation (`req_msg[*]`)
2. 需要將匯流排約束展開為個別位元：
   ```tcl
   # 原始寫法（iSTA 不支援）
   set_input_delay -clock clk 0.5 [get_ports req_msg[*]]
   
   # 展開寫法（iSTA 可接受）
   set_input_delay -clock clk 0.5 [get_ports {req_msg[0] req_msg[1] ... req_msg[31]}]
   ```
3. 或參考 `simple` 設計使用純量埠（scalar ports）

**來源：** 已知問題，見「測試設計 > GCD 電路 > 工具相容性限制」

### TCL 腳本路徑錯誤
**症狀：** 執行腳本時報告 "file not found" 或 "cannot read file"

**解決方案：**
1. 確認工作目錄位置與腳本中的相對路徑匹配
2. 檢查腳本內的檔案路徑變數設定：
   ```tcl
   # 範例：opensta_common.tcl 中的路徑設定
   set design_dir "/home/a1023/STA/benchmark/designs/simple"
   set netlist "$design_dir/simple.v"
   ```
3. 若切換設計，需同步修改所有相關路徑變數

### 工具可執行檔找不到
**症狀：** "command not found" 或 "No such file or directory"

**解決方案：**
1. 確認工具已正確編譯：
   ```bash
   # OpenSTA
   ls /home/a1023/STA/OpenSTA/build/app/sta
   
   # OpenTimer
   ls /home/a1023/STA/OpenTimer/bin/ot-shell
   
   # iSTA
   ls /home/a1023/STA/iEDA/build/bin/iSTA
   ```
2. 使用絕對路徑執行或確認相對路徑正確
3. 參考「快速開始」章節的執行命令

---

## 參考文件

- **OpenSTA 官方文件：** `/home/a1023/STA/OpenSTA/doc/OpenSTA.fodt`
- **OpenTimer 文件：** 
  - `/home/a1023/STA/OpenTimer/README.md`
  - `/home/a1023/STA/OpenTimer/wiki/io/sdc.md`
- **iSTA 使用教學：** `/home/a1023/STA/iEDA/iSTA使用教學.md`
- **工具分析報告：** `/home/a1023/STA/STA_tool_analysis_report.md`
- **本目錄執行分析：** `/home/a1023/STA/benchmark/STA_excute_analysis_report.md`

---

**最後更新：** 2025-01-16  
**文件說明：** 本文件記錄 TCL-based STA benchmark 架構，支援 OpenSTA、OpenTimer、iSTA 三種工具的時序分析流程
