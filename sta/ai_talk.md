Chat summary:
1. 使用者提供 STA 專案環境設定，要求分析為何 OpenSTA、OpenTimer 與 iEDA/iSTA 在 benchmark 中的結果（WNS/TNS）不一致。
2. 根據 simple.sdc 被各工具解析的差異，整理出造成結果差異的主要原因：三種工具支援的 SDC 子集合不同。
3. 依照各工具的 README/文件/原始碼，彙整了彼此缺少的 SDC 指令、功能重疊但名稱不同的指令，以及必要的轉換方式，並寫入 `STA_tool_analysis_report.md` 第 3 節。
4. 產出分析重點：需要在 OpenSTA 重新敘述 clock port delay/transition，注意 OpenTimer 僅支援有限 SDC 指令集，iEDA/iSTA 需參考其 Cmd*.cc 實作來對照命令。
