# STA 工具測試報告（OpenSTA / OpenTimer / iEDA iSTA / Tatum）

## 1. 測試環境與資料
- 測試資料：`benchmark/simple`（從 OpenTimer 範例拷貝，包含 `simple.v/.sdc/.spef` 與早/晚 Liberty）。
- 指令腳本：
  - OpenSTA：`benchmark/scripts/opensta_batch.tcl` 透過 `sta -exit`，與 `benchmark/scripts/opensta_interactive_commands.tcl` 透過 STDIN 模擬互動模式。
  - OpenTimer：`benchmark/scripts/opentimer_batch.ot` 同時用於 `ot-shell --stdin`（批次）與 `ot-shell`（互動）。
  - iEDA/iSTA：`benchmark/scripts/ista_simple.tcl` 由 `iEDA/build_dynamic/src/operation/bin/iSTA` 執行，建立 workspace 並讀入同一組測資。
  - Tatum：`tatum/build/tatum_test/tatum_test` 分別以 `tatum/test/basic/simple_comb.tatum`（純序）與 `simple_multiclock.tatum`（額外 incremental run）測試，其 `.tatum` 為 Tatum 內建時序圖格式。
- 所有輸出與報告存於 `benchmark/results/<tool>`，包含 `/usr/bin/time` 的 `real/user/sys` 與工具 stdout。

## 2. 執行結果總覽
| Tool | 輸入模式 | 指令 | Real time | TNS (max) | WNS (max) | TNS (min) | WNS (min) | 日誌 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| OpenSTA | Tcl 批次 | `./OpenSTA/build/sta -exit benchmark/scripts/opensta_batch.tcl` | 0.13 s | -316.84 ps | -198.55 ps | 0 ps | 0 ps | `benchmark/results/opensta_batch/run.log`
| OpenSTA | Tcl 互動 | `./OpenSTA/build/sta < benchmark/scripts/opensta_interactive_commands.tcl` | 0.10 s | -316.84 ps | -198.55 ps | 0 ps | 0 ps | `benchmark/results/opensta_interactive/run.log`
| OpenTimer | Shell 批次 | `./OpenTimer/bin/ot-shell --stdin benchmark/scripts/opentimer_batch.ot` | 0.10 s | -591 ps | -204 ps | 0 ps | 107 ps | `benchmark/results/opentimer_batch/run.log`
| OpenTimer | Shell 互動 | `./OpenTimer/bin/ot-shell < benchmark/scripts/opentimer_batch.ot` | 0.04 s | -591 ps | -204 ps | 0 ps | 107 ps | `benchmark/results/opentimer_interactive/run.log`
| iEDA/iSTA | Tcl 批次 | `iEDA/build_dynamic/src/operation/bin/iSTA benchmark/scripts/ista_simple.tcl` | 0.18 s | N/A (未輸出) | N/A (未輸出) | -19.893 ns | -9.946 ns | `benchmark/results/ieda_ista/run.log`
| Tatum | `simple_comb` / 序列 | `tatum/build/tatum_test/tatum_test --num_serial 1 --num_parallel 0 tatum/test/basic/simple_comb.tatum` | <0.01 s | N/A | N/A | N/A | N/A | `benchmark/results/tatum/simple_comb_serial.log`
| Tatum | `simple_multiclock` / 序列 + incremental | `tatum/build/tatum_test/tatum_test --num_serial 1 --num_serial_incr 5 --num_parallel 0 tatum/test/basic/simple_multiclock.tatum` | <0.01 s | N/A | N/A | N/A | N/A | `benchmark/results/tatum/simple_multiclock_incr.log`

> 單位：OpenSTA/OpenTimer 以 ps 報告，iSTA 以 ns 報告。Tatum 的 `tatum_test` 只顯示路徑延遲與分析時間，不輸出 TNS/WNS。

## 3. 詳細觀察
### 3.1 OpenSTA
**功能性**
- 支援 Liberty/Verilog/SDC/SPEF 等標準格式（`benchmark/results/opensta_batch/run.log:1-60`）。
- SDC 解析對 `set_input_delay -clock` 與 `set_input_transition -clock` 發出警告，顯示 Tcl 介面尚未支援所有旗標（`benchmark/results/opensta_batch/run.log:7-20`）。
- `report_checks` 同時輸出 min/max 路徑，`report_tns/report_wns` 取得 0/-316.84ps 與 0/-198.55ps（`benchmark/results/opensta_batch/run.log:25-70`）。

**架構與可擴展性**
- `Sta` 類別是完整 STA 狀態的 facade 兼 factory，`makeComponents()` 可覆寫以注入客製化網路、延遲計算或報表元件 (`OpenSTA/include/sta/Sta.hh:87-170`)。
- 官方 API 說明兩種整合模式：連結 STA library 直接呼叫 `Sta::readLibertyFile`/`linkDesign`，或覆寫 `makeNetwork()` 改接自家 netlist (`OpenSTA/doc/StaApi.txt:520-584`)。

**測試結果評估**
- 批次與互動模式輸出一致，證實腳本可重複。
- 警告指出若要完整 contest SDC 相容，需要補強 parser。
- 約 0.1s 的執行時間主要花在 Tcl 初始化與讀檔，適合批次使用。

### 3.2 OpenTimer
**功能性**
- Shell 指令一次讀入早/晚 Liberty、Verilog、SPEF 與 SDC（`benchmark/results/opentimer_batch/run.log:1-18`）。
- `cppr -enable` 啟用 CPPR，並在 log 中標註（`benchmark/results/opentimer_batch/run.log:17-33`）。
- `report_timing`/`report_tns`/`report_wns` 分別輸出關鍵路徑與 -591/-204ps 的 setup 統計（`benchmark/results/opentimer_batch/run.log:19-70`）。

**架構與可擴展性**
- `ot::Timer` 將操作分成 builder/action/accessor：builder (`read_*`, `set_*`) 僅記錄操作，action (`update_timing`, `report_timing`) 觸發 Taskflow，accessor (`dump_*`) 僅查詢 (`OpenTimer/ot/timer/timer.hpp:36-104`)。
- Taskflow executor 與 lineage graph（`OpenTimer/ot/timer/timer.hpp:131-160`）可支援平行與增量更新，CLI 與 API 共享同一類別，擴充一次即可雙用。

**測試結果評估**
- STDIN 模式比 `--stdin` 更快（0.04 vs 0.10s），顯示互動 shell 初始化較輕。
- 由於完整接受 SDC clock 旗標，得到比 OpenSTA 更悲觀的 setup 結果，若要相比需調整 SDC 或禁用特定命令。
- 以純數字輸出 TNS/WNS，方便自動化蒐集。

### 3.3 iEDA/iSTA
**功能性**
- `benchmark/scripts/ista_simple.tcl` 採用 `set_design_workspace` 與 `read_netlist/read_liberty/link_design/read_sdc/read_spef` 流程，直接使用 `benchmark/simple` 測資並儲存報告於 `benchmark/results/ieda_ista`。
- CLI 由 `UserShell` 驅動，支援 `report_timing -delay_type max/min` 以產生表格與 JSON (`iEDA/src/operation/iSTA/source/module/shell-cmd/CmdReportTiming.cc:22-140`)。
- 日誌顯示 Liberty 由 Rust parser 讀入，支援同時載入早、晚角落 (`benchmark/results/ieda_ista/run.log:12-35`)；也會自動輸出 wire path JSON（`benchmark/results/ieda_ista/run.log:164-167`）。

**架構與可擴展性**
- `main.cc` 透過 gflags/`cxxopts` 解析 `script` 參數，並將 Tcl 指令註冊到 `UserShell` (`iEDA/src/operation/iSTA/main.cc:24-140`)；script 模式與互動模式共享同一 Shell，方便與 iEDA 其他模組整合。
- `TimingEngine` 提供 C++ API (`readLiberty`, `readVerilogWithRustParser`, `readSdc`, `readSpef`, `getWNS` 等) 供 iEDA 其他流程呼叫 (`iEDA/src/operation/iSTA/api/TimingEngine.hh:90-170`)，同時保留 `TimingDBAdapter` 讓 STA 可以套用 iEDA 的 IDB netlist。

**測試結果評估**
- `report_timing` 最大延遲行輸出 slack 19.946ns，《Clock/TNS》小表提供 `max` TNS=0；`min` 表提供 -19.893ns TNS 與 -9.946ns WNS（`benchmark/results/ieda_ista/run.log:168-182`）。
- 缺省 SDC 缺少 `set_output_delay`，因此 log 報告 end vertex 缺 clock 與 output 未約束（`benchmark/results/ieda_ista/run.log:203`），必須補齊約束才能獲得完整 max/min 結果。
- 報告同時輸出 JSON/wire netlist，利於 GUI 或自動化分析，但也增加 I/O，應視需求刪除。

### 3.4 Tatum
**功能性**
- `tatum_test` 以 `.tatum` 檔描述時序圖與延遲（`tatum/test/basic/simple_comb.tatum`），CLI 參數可設定分析類型、序列/增量/平行 run 次數等 (`tatum/tatum_test/main.cpp:33-137`)。
- 本次執行一次序列分析（`--num_serial 1 --num_parallel 0`）與一次序列＋5 次 incremental run（`--num_serial_incr 5`），`tatum_test` 會輸出圖形統計、run breakdown 與 critical path（`benchmark/results/tatum/simple_comb_serial.log:1-70`, `benchmark/results/tatum/simple_multiclock_incr.log:1-160`）。
- 目前未安裝 TBB，log 提示「built with only serial execution support」並忽略 `--num_workers`，因此僅能評估序列/增量模式。

**架構與可擴展性**
- Tatum 核心以抽象 timing graph/constraints/delay calculator 建模 (`tatum/libtatum/tatum/timing_analyzers.hpp:1-200`)，並透過 graph walkers 進行單次 traversal 同時計算 setup/hold。
- `tatum_test` 展示如何以 `AnalyzerFactory` 與 `FixedDelayCalculator` 建構分析器 (`tatum/tatum_test/main.cpp:140-360`)，使用者可在自家 CAD flow 建立 graph adapter，再重複利用 Tatum 的 block-based STA 與 incremental walker。

**測試結果評估**
- `simple_comb` 僅 6 nodes，序列 run 約 11.9µs；`simple_multiclock` 51 nodes，序列 run 37.5µs，5 次 incremental run 平均 23µs，log 會比較 incremental/全量速度 (`benchmark/results/tatum/simple_multiclock_incr.log:100-180`)。
- CLI 主要用於效能 profile 與驗證，沒有標準 Liberty/SDC parser，因此短期無法直接重用 `benchmark/simple`；若要統一測資需先實作 Verilog/SPEF→tatum graph 轉換。

## 4. 差異分析與建議
- **介面模式**：OpenSTA/iSTA 皆透過 Tcl shell，OpenTimer 則有 shell + header-only API；Tatum 提供 CLI 範例但核心以 C++ library 形式存在。
- **功能覆蓋**：OpenTimer 與 iSTA 對 SDC 支援較完整（沒有 `-clock` 警告），OpenSTA 需補 parser；Tatum 僅接受 `.tatum` graph，需要額外轉接層。
- **效能**：在此小測資上 OpenTimer (0.04s) < OpenSTA (0.10s) < iSTA (0.18s) << Tatum (µs 級)；但 Tatum 的圖由 `.tatum` 提供，與實際 netlist 解析無關，無法直接比較。
- **擴充性**：
  - OpenSTA 與 iSTA 都支援替換內部 component／adapter；OpenSTA 偏向作為可嵌入 timing engine，iSTA 則與 iEDA 平台深度整合（`TimingEngine` API）。
  - OpenTimer 與 Tatum 皆採函式庫導向；OpenTimer 著重 builder/action 分離與 Taskflow，Tatum 則採 block-based graph walker + incremental support，適合整合到自家工具。
- **輸出/警告**：iSTA 目前對輸出 port 未約束會直接報錯並僅輸出 `min` 結果；Tatum 不輸出 TNS/WNS，需要自行解析 critical path。OpenTimer/STA 皆提供 `report_tns/report_wns` 易於自動化。

## 5. 後續工作建議
1. **OpenSTA**：建立 regression 測試並補齊 `set_input_delay/-clock` 與 `set_input_transition/-clock` 支援，避免 warning 影響時序比對。
2. **OpenTimer**：撰寫 `ot::Timer` 小範例納入 CI，驗證 shell/API 行為一致並探索 Taskflow 插入自訂 pass。
3. **iEDA/iSTA**：補上輸出 `set_output_delay` 或 clock 定義以解除 `out is not constrained`（`benchmark/results/ieda_ista/run.log:203`），並評估從 JSON 報表擷取 WNS/TNS 以串接自動比較。
4. **Tatum**：設計 Verilog/SPEF→`.tatum` 轉換或直接包裝 `libtatum` 連接 Liberty 模型，讓它能與其他工具共用測資；同時在環境中加入 TBB 以啟用多執行緒模式。
5. **共通**：把 `benchmark/scripts`、結果整理腳本與 `/usr/bin/time` 指標納入 CI，確保四個工具的輸入模式皆受監控。
