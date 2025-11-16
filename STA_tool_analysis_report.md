# STA 工具分析報告

## 1. 簡介

本報告針對四個開源靜態時序分析（Static Timing Analysis, STA）工具進行詳細分析：OpenSTA、OpenTimer、tatum，以及整合在 iEDA 專案中的 iSTA 工具。目標是評估這些工具的功能性、架構和可擴展性，以找出最適合進行二次開發和客製化的候選工具。本分析基於專案文件和原始碼的檢視。

## 2. 工具分析

### 2.1. OpenSTA

OpenSTA 是一個成熟且功能豐富的閘級靜態時序驗證工具。

#### 功能性
- **輸入格式：** 支援廣泛的標準格式，包括 Verilog、Liberty、SDC、SPEF 和 SDF。
- **功能特色：** 提供全面的時序檢查，包括對複雜時鐘（生成時鐘、延遲、不確定性）的支援、路徑例外（假路徑/多週期路徑）以及各種延遲計算模型。
- **介面：** 使用 Tcl 命令列解譯器，這在 EDA 工具中是標準配置。

#### 架構
OpenSTA 採用經典的模組化、物件導向 C++ 架構。核心的 `Sta` 類別扮演外觀模式（Facade）和工廠模式（Factory）的角色，管理所有子元件（例如：圖形、SDC 解析器、延遲計算器）。

最重要的架構特徵是其**抽象的 `Network` API**。這使得時序引擎可以「接合」到外部應用程式的網表資料結構上，而無需複製資料。

*程式碼片段：`StaApi.txt` 描述模組化結構和 `Sta` 類別。*
```
The sub-directories of the STA code are:

doc
  Documentation files.
util
  Basic utilities.
liberty
  Liberty timing library classes and file reader.
network
  Network and library API used by all STA code.
...
search
  Search engine used to annotate the graph with arrival, required times
  and find timing check slacks.
...

Major components of the STA such as the network, timing graph, sdc,
and search are implemented as separate classes. The Sta class
contains an instance of each of these components.
```

#### 可擴展性
可擴展性是 OpenSTA 的主要設計考量。
- **元件替換：** 核心元件可以透過繼承 `Sta` 類別並覆寫其虛擬的 `make<Component>` 工廠方法來替換。
- **網路適配器：** 抽象的 `Network` API 是最強大的擴充點，允許與其他工具無縫整合。
- **自訂延遲計算器：** 新的延遲模型可以透過實作 `ArcDelayCalc` 介面來整合。

*程式碼片段：`Sta.hh` 顯示用於建立元件的虛擬工廠方法。*
```cpp
// From: OpenSTA/include/sta/Sta.hh

class Sta : public StaState
{
public:
  // ...
  virtual void makeComponents();
  // ...
protected:
  // Default constructors that are called by makeComponents in the Sta
  // constructor.  These can be redefined by a derived class to
  // specialize the sta components.
  virtual void makeVariables();
  virtual void makeReport();
  virtual void makeDebug();
  virtual void makeNetwork();
  virtual void makeSdc();
  virtual void makeGraph();
  // ...
};
```

### 2.2. OpenTimer

OpenTimer 是一個使用 C++17 從頭建構的現代化 STA 工具，強烈聚焦於透過平行處理和增量分析來提升效能。

#### 功能性
- **輸入格式：** 支援標準格式（`.lib`、`.v`、`.spef`、`.sdc`）。
- **功能特色：** 提供核心的圖形和路徑基礎 STA。其主要特點是高效能、平行化和增量式的引擎。
- **介面：** 提供互動式 shell 和 C++ API 兩種介面。

#### 架構
OpenTimer 的架構是其關鍵差異化特點。它使用基於「建構器（Builders）」、「動作（Actions）」和「存取器（Accessors）」的**延遲評估（lazy evaluation）**模型。
- **建構器（Builders）** 是延遲命令，會建立任務圖（使用 `Taskflow` 函式庫）而非立即執行。
- **動作（Actions）** 觸發任務圖的平行執行，以進行實際的時序更新。
- **存取器（Accessors）** 是 `const` 方法，用於安全地查詢計時器的狀態。

此設計針對增量更新和平行執行進行高度最佳化。

*程式碼片段：`ot/timer/timer.hpp` 展示建構器/動作/存取器 API 設計。*
```cpp
// From: OpenTimer/ot/timer/timer.hpp

class Timer {
  public:
    // Builder
    Timer& set_num_threads(unsigned);
    Timer& read_celllib(std::filesystem::path, std::optional<Split> = {});
    Timer& read_verilog(std::filesystem::path);
    // ...

    // Action.
    void update_timing();
    std::optional<float> report_tns(std::optional<Split> = {}, std::optional<Tran> = {});
    std::optional<float> report_wns(std::optional<Split> = {}, std::optional<Tran> = {});
    // ...

    // Accessor
    void dump_graph(std::ostream&) const;
    void dump_power(stdostream&) const;
    // ...
};
```

#### 可擴展性
OpenTimer 設計為高效能函式庫使用。
- **C++ API：** 提供乾淨、執行緒安全的 C++ API（`ot::Timer`），用於整合到其他應用程式中。
- **內部修改：** 並非設計用於輕鬆修改其內部演算法。與 OpenSTA 不同，沒有明確的機制可透過外掛或繼承來替換核心元件（如延遲計算器）。可擴展性著重於*使用*引擎，而非*改變*它。

### 2.3. tatum

Tatum 是一個靈活、高效能、基於區塊的 STA 引擎，明確設計用於輕鬆整合到其他 CAD 工具中。

#### 功能性
- **核心引擎：** 提供核心 STA 演算法：建立/保持時間分析、時鐘偏斜和多時鐘支援。
- **極簡主義：** 刻意將解析和延遲計算工作交給主應用程式，純粹專注於圖形遍歷和分析演算法。

#### 架構
Tatum 的架構由其乾淨、解耦的介面所定義。
- **抽象時序圖：** 主應用程式負責透過呼叫 `add_node()` 和 `add_edge()` 來建構 `TimingGraph`。Tatum 本身不解析任何網表格式。
- **抽象延遲計算器：** `DelayCalculator` 是一個純虛擬介面，必須由主應用程式實作。這完全將時序引擎與任何特定的延遲模型解耦。
- **效能：** 內部使用結構陣列（Struct-of-Arrays, SoA）資料佈局以提升快取效率。

*程式碼片段：`tatum/delay_calc/DelayCalculator.hpp` 展示純虛擬介面。*
```cpp
// From: tatum/libtatum/tatum/delay_calc/DelayCalculator.hpp

class DelayCalculator {
    public:
        virtual ~DelayCalculator() {}

        virtual Time min_edge_delay(const TimingGraph& tg, EdgeId edge_id) const = 0;
        virtual Time max_edge_delay(const TimingGraph& tg, EdgeId edge_id) const = 0;

        virtual Time setup_time(const TimingGraph& tg, EdgeId edge_id) const = 0;
        virtual Time hold_time(const TimingGraph& tg, EdgeId edge_id) const = 0;
};
```

#### 可擴展性
**優秀。** Tatum 可以說是這些工具中最具擴展性和靈活性的。它是一個「自帶資料模型」的引擎。開發者可以透過編寫必要的適配器程式碼來填充 `TimingGraph` 並實作 `DelayCalculator`，從而將它與任何網表或函式庫資料模型整合。這使其成為研究和整合到現有客製化工具鏈的理想選擇。

### 2.4. iSTA（來自 iEDA）

iSTA 是一個功能豐富、高效能的 STA 工具，在這群工具中看起來最「商業化」。

#### 功能性
- **輸入格式：** 支援所有標準格式。
- **進階功能：** 其功能相當廣泛，包括支援 **CCS 和 Arnoldi 延遲模型**、**AOCV** 分析，以及初步的串擾分析。
- **效能：** 具備使用 CUDA 的 **GPU 加速**時序傳播功能，並利用 **Rust** 進行高效能解析。

#### 架構
iSTA 採用較為單體但內部模組化的架構。它是一個完整、自給自足的系統。
- **具體資料模型：** 與 OpenSTA 和 tatum 不同，它對網表和時序圖使用自己的具體資料結構。它並非圍繞這些元件的抽象介面建構。
- **單例外觀模式：** 使用單例模式的 `ista::Sta` 類別作為主要入口點，管理所有內部元件。
- **異質性：** 架構混合了 C++、Rust 和 CUDA，專注於最大化效能。

*程式碼片段：`iSTA/source/module/sta/Sta.hh` 展示 CUDA 特定的資料結構。*
```cpp
// From: iEDA/src/operation/iSTA/source/module/sta/Sta.hh

#if CUDA_PROPAGATION
  std::vector<GPU_Vertex> _gpu_vertices;  //!< gpu flatten vertex, arc data.
  std::vector<GPU_Arc> _gpu_arcs;
  GPU_Flatten_Data _flatten_data;
  GPU_Graph _gpu_graph;  //!< The gpu graph mapped to sta graph.
  // ...
#endif
```

#### 可擴展性
**較差。** 從二次開發的角度來看，這是 iSTA 的主要弱點。
- **黑箱引擎：** 它設計為完整的時序引擎使用，但不易於內部修改。
- **無外掛模型-：** 沒有明確的外掛模型可用於替換核心元件（如延遲計算器）。擴展它需要直接修改原始碼，這既複雜又難以維護。

## 3. 比較摘要

| 標準 | OpenSTA | OpenTimer | tatum | iSTA (iEDA) |
| :--- | :--- | :--- | :--- | :--- |
| **功能性** | 非常好 | 良好 | 僅核心引擎 | 優秀 |
| **關鍵特色** | 成熟且可擴展 | 平行化與增量式 | 靈活且解耦 | 進階功能（AOCV、GPU） |
| **架構** | 模組化、物件導向、抽象網路 | 延遲評估、任務圖 | 純引擎、抽象介面 | 單體式、高效能 |
| **可擴展性** | **優秀** | 良好（作為函式庫） | **優秀** | 較差 |
| **最適用於** | 客製化全功能工具 | 高效能函式庫整合 | 與自訂資料整合的引擎 | 功能完整的「開箱即用」工具 |

## 4. 建議

針對**進行二次開發以滿足客製化需求**的既定目標，最佳選擇是 **OpenSTA**。

**理由：**

雖然所有工具都有其優勢，但 OpenSTA 在功能完整、穩健的工具與提供出色、文件完善的擴展機制之間取得了完美的平衡。

- **tatum** 在可擴展性方面也是絕佳選擇，但它*過於精簡*。開發者需要在其周圍建構大量基礎設施（解析器、SDC 處理、延遲計算邏輯）。OpenSTA 則開箱即提供所有這些功能。
- **iSTA** 是功能強大的工具，但在架構上是一個「黑箱」，難以在不進行大量且侵入性原始碼修改的情況下進行客製化或擴展。
- **OpenTimer** 擁有令人著迷的高效能架構，但更多是設計為函式庫使用，而非可修改的框架。

**OpenSTA** 提供了堅實、成熟的基礎和豐富的現有功能集，同時其抽象的 `Network` API 和虛擬工廠方法為深度客製化和整合提供了清晰、受支援的途徑。這使它成為建構客製化 STA 解決方案的理想起點。
