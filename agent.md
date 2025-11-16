## 任務概要
現有STA商業或開源工具無法滿足需求，因此要分析開源工具，找出有淺力的工具進行二次開發，滿客製化需求

## 任務細節
我要測試openSTA、openTimer、iEDA/iSTA、tatum
1. 執行相同的測資，觀察輸出結果以及執行時間 
2. 如果有多種輸入模式，例如互動介面、指令、header等，請全部測試，這兩者可以用不同方式執行，只要測試所有輸入方式以及使用相同輸入就好 
3. 如果有多種計算模式請全部使用並比較 
4. 將測資以及其他一切都放到./STA/benchmark資料夾
5. 撰寫分析報告，內容包含分析過程、結果及建議，並附上相關程式碼片段及位置，存放在./STA/benchmark/STA_analysis_report.md


~~分析四個STA tool，分別是OpenSTA、OpenTimer、tatum以及iEDA內建的STA工具，評估其功能、架構及可擴展性，找出最適合進行二次開發的工具~~

## 檔案內容
- cudd-3.0.0: OpenSTA使用的套件
    https://sourceforge.net/projects/cudd/files/cudd-3.0.0.tar.gz/download

- iEDA: 開源EDA工具
    https://github.com/eda-asic/ieda

    使用g++ -10

- OpenSTA:
    主力研究項目之一
    https://github.com/OpenSTA/OpenSTA

    shell: 超大文件 doc/OpenSTA.pdf
    api: doc/STA_analysis_report.pdf

- OpenTimer:
    主力研究項目之二
    https://github.com/OpenTimer/OpenTimer

    shell & api: README.md

- tatum:
    https://github.com/The-OpenROAD-Project/tatum

note: 所有'*使用教學.md'內容都不可信，請以其他文件以及實際程式碼為主

## 限制
- 分析內容需包含功能、架構、可擴展性
- 避免修改或新增sta tool內容，除了腳本工具
- 需撰寫分析報告，內容包含分析過程、結果及建議，並附上相關程式碼片段及位置，存放在./STA資料夾

## 下一步研究
- iEDA/iSTA：補齊輸出/端點約束以清除 `StaAnalyze` 未約束警告，並評估如何從 JSON 報表擷取 WNS/TNS 以融入自動比較流程
- OpenTimer vs iSTA：建立一致的 SDC 轉換層，驗證早/晚角落對照與 CPPR 行為差異
- Tatum：研究自動把 Liberty/Verilog 轉成 `.tatum` 圖描述的方法，或包裝 `libtatum` 直接讀 Netlist，以便和其餘工具使用相同測資
