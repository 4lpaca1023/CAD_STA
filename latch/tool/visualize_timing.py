import matplotlib.pyplot as plt
import numpy as np

# --- 設定數據 (來自 sky.rpt / paths.rpt) ---
period = 50.0
clk_fall_edge = 25.0  # Latch 透明開始 (Opening Edge)
clk_rise_edge = 50.0  # Latch 關閉 (Closing Edge)

# Input Data (D)
d_arrival = 5.0       # Data Arrival at D

# Output Data (Q) - The Problem Area
q_delay = 26.0        # Cell Rise Delay (t_pdq)
q_transition = 36.8   # Rise Transition Time
# Q 50% 翻轉點 = Clock Edge + Delay
q_switch_time = clk_fall_edge + q_delay 

# Setup/Hold Info
t_setup = -0.17
t_hold = -0.13

# --- 繪圖函數 ---
def plot_timing():
    fig, ax = plt.subplots(figsize=(12, 8))  # 增加高度
    
    # 調整邊界，留更多空間給左側 Y 軸標籤
    plt.subplots_adjust(left=0.15, right=0.95, top=0.9, bottom=0.1)
    
    # 時間軸: 0 到 80ns
    t = np.linspace(0, 80, 1000)
    
    # 波形垂直位移量 (Offset)
    y_clk = 6
    y_d = 3.5
    y_q = 0
    
    # 1. 繪製 Clock (tau2015_clk)
    # 0-25 High, 25-50 Low (Negative Latch)
    clk_wave = np.where((t >= 0) & (t < 25), 1.8, 
               np.where((t >= 25) & (t < 50), 0, 
               np.where((t >= 50) & (t < 75), 1.8, 0)))
    
    # 2. 繪製 Data (D)
    # 在 5ns 時從 Low 變 High
    d_wave = np.where(t < d_arrival, 0, 1.8)
    
    # 3. 繪製 Output (Q) - 模擬緩慢的 Transition
    k = 4.0 / (q_transition / 2.0) 
    q_wave = 1.8 / (1 + np.exp(-k * (t - q_switch_time)))
    
    # --- 繪圖 ---
    ax.plot(t, clk_wave + y_clk, 'k', label='Clock (tau2015_clk)', linewidth=2)
    ax.plot(t, d_wave + y_d, 'b', label='Input (l1/D)', linewidth=2)
    ax.plot(t, q_wave + y_q, 'r', label='Output (l1/Q)', linewidth=2)
    
    # --- 加入標註 (Annotations) ---
    
    # 標註 A: Clock Fall Edge (Latch Open)
    ax.axvline(x=clk_fall_edge, color='gray', linestyle='--', alpha=0.5)
    ax.text(clk_fall_edge, y_clk + 2.2, 'Latch Opens\n(Transparent)', ha='center', fontsize=9)

    # 標註 B: t_pdq (Delay)
    # 畫箭頭從 Clock Edge 到 Q 的 50% 點
    ax.annotate('', xy=(q_switch_time, y_q + 0.9), xytext=(clk_fall_edge, y_q + 0.9),
                arrowprops=dict(arrowstyle='<->', color='green', lw=2))
    ax.text((clk_fall_edge + q_switch_time)/2, y_q + 1.2, f't_pdq = {q_delay}ns\n(Huge Delay!)', 
            ha='center', color='green', fontweight='bold')

    # 標註 C: Transition Time
    q_start = q_switch_time - (q_transition/2)
    q_end = q_switch_time + (q_transition/2)
    ax.annotate('', xy=(q_end, y_q + 0.5), xytext=(q_start, y_q + 0.5),
                arrowprops=dict(arrowstyle='|-|', color='purple', lw=2))
    ax.text(q_switch_time, y_q - 0.5, f'Transition = {q_transition}ns\n(Too Slow)', 
            ha='center', color='purple')

    # 標註 D: Q 的 50% 點
    ax.plot(q_switch_time, y_q + 0.9, 'ro')
    ax.text(q_switch_time + 2, y_q + 0.9, f'50% Point\n@ {q_switch_time}ns', fontsize=8)

    # --- 格式設定 ---
    # 設定 Y 軸刻度位置對齊波形的 "Low" 與 "High" 中間
    ax.set_yticks([y_q + 0.9, y_d + 0.9, y_clk + 0.9])
    ax.set_yticklabels(['l1/Q\n(Output)', 'l1/D\n(Input)', 'tau2015_clk\n(Clock)'], fontsize=11)
    
    ax.set_xlabel('Time (ns)', fontsize=12)
    ax.set_title(f'Latch Timing Analysis (Visualizing latch/sky.rpt)\nSetup Violation Visualization', fontsize=14)
    ax.grid(True, alpha=0.3)
    
    # 設定 Y 軸範圍 (增加上下空間)
    ax.set_ylim(-2, 10)
    
    # 存檔
    output_file = 'latch_timing_diagram.png'
    plt.savefig(output_file, dpi=150)
    print(f"Plot saved to {output_file}")

if __name__ == "__main__":
    plot_timing()
