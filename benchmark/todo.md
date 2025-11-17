# TODO / Known Issues

## 2025-11-17 — GCD 設計流程
### 觀察
- OpenSTA 可完成分析，log：`benchmark/results/opensta_gcd.log`，但顯示 `sky130_fd_sc_hd__tapvpwrvgnd_1` 在 Liberty 中缺席（以 black box 處理）。
- OpenTimer 於 `gcd_sky130hd.spef:10908` 解析 `clk I` 條目時噴錯並在 `_insert_primary_output` 觸發 assert，log：`benchmark/results/opentimer_gcd.log`。
- iSTA 在 `set_input_delay` 解析 `req_val reset resp_rdy req_msg[*]` wildcard 時回報 object list 為空並觸發 fatal，log：`benchmark/results/ieda_ista_gcd/run.log`。

### 思考/分析
1. **OpenTimer**：互相比對 SPEF 後，只有 clock net 標記為輸入 pin (`clk I`) 並延續分割線，推測 parser 無法接受該語法（OpenTimer 期待 `*CONN` 條目以 pin 名同步 net type）。這也解釋了 `_insert_primary_output` 失敗，因為 net 定義提前中止。最佳策略是重新匯出 SPEF 或撰寫清理腳本移除/更正這個條目，然後再跑一次 `ot-shell` 以確認是否還有其他語法不相容。 
2. **iSTA**：GCD 的 SDC 假設工具支援 `get_ports req_msg[*]` 這類 wildcard。不過 iSTA 在 gate-level 範圍裡把 `[*]` 視為 literal，導致找不到任何 pin。需要將這些命令轉為明確的 bus bit（例如 `req_msg\[0]`…）或改成 `foreach` 展開，才能讓 `CmdSetIODelay` 接收到有效物件。 
3. **Liberty tap cells**：OpenSTA/iSTA 都警告 `sky130_fd_sc_hd__tapvpwrvgnd_1` 缺席，表示目前的 `sky130hd_tt.lib` 版本並未帶入該 cell。雖然 tap cell只註冊 power pins，不影響邏輯延遲，但仍應確認是否要提供一個空的宏模型或在網表內剔除該 cell 以避免噪訊訊息。這會在修正 SPEF/SDC 後再一併處理。 

### 下一步建議
1. 針對 `gcd_sky130hd.spef`：先以簡單腳本刪除或改寫 `clk I` 相關區段，再嘗試跑 `tclsh scripts/opentimer_batch.ot`。若成功，將修正過的 SPEF 另存版本並在 `design.env` 中指向。 
2. 針對 `gcd_sky130hd.sdc`：列出所有 `req_msg[*]`/`resp_msg[*]` 等 wildcard，改寫為 `req_msg[0] ... req_msg[31]` 的明確語法（或使用 `get_ports -regexp`），並重新驗證 iSTA。完成後，把修訂步驟記錄在 README 的 SDC 指南。 
3. 針對 tap cell 警告：確認是否需要在 Liberty 中補上一個零延遲模型或在 STA 前把 `sky130_fd_sc_hd__tapvpwrvgnd_1` 從網表過濾，避免未來分析時發出大量 warning。 
