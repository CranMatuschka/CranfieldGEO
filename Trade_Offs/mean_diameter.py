import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as ticker

f, c = 2.1e9, 299792458
lambda_val, h_geo = c / f, 35786000
N_list = [5, 25, 45, 65, 85]
D_list = [1, 3, 5, 7, 9]
Gap_list = [50, 150, 250, 350, 450]

results_fp = []
for N in N_list:
    p_x_base = (np.random.rand(N) - 0.5) * (np.sqrt(N) * 1.5)
    p_y_base = (np.random.rand(N) - 0.5) * (np.sqrt(N) * 1.5)
    for D in D_list:
        for Gap in Gap_list:
            min_dist = D + Gap
            mean_D_swarm = ((np.ptp(p_x_base * min_dist)) + (np.ptp(p_y_base * min_dist))) / 2
            hpbw_deg = 70 * (lambda_val / mean_D_swarm)
            f_diam = (2 * h_geo * np.tan(np.deg2rad(hpbw_deg) / 2)) / 1000
            results_fp.append({'Number of Sat': N, 'Diam (m)': D, 'Gap (m)': Gap, 'Footprint': f_diam})

df_fp = pd.DataFrame(results_fp)

sns.set_theme(style="whitegrid")
factors = ['Number of Sat', 'Diam (m)', 'Gap (m)']
units = ['', 'm', 'm']
palettes = ['Greens_d', 'mako', 'flare']

fig, axes = plt.subplots(3, 3, figsize=(13, 11))
plt.subplots_adjust(wspace=0.12, hspace=0.12)
legend_store = {}

for row in range(3):
    for col in range(3):
        ax = axes[row, col]
        if row != col:
            sns.lineplot(data=df_fp, x=factors[col], y='Footprint', hue=factors[row], 
                         ax=ax, marker='o', palette=palettes[row], linewidth=2.5, errorbar=None)
            
            if row not in legend_store:
                h, l = ax.get_legend_handles_labels()
                legend_store[row] = (h, [f"{val} {units[row]}".strip() for val in l])
            ax.get_legend().remove()
            
            # Formatting: Commas for Y-axis (Footprint km)
            ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, p: format(int(x), ',')))
            ax.set_xlabel(''); ax.set_ylabel('')
            if row == 0: ax.xaxis.tick_top()
            elif row == 1: ax.set_xticklabels([])
            if col == 2: ax.yaxis.tick_right()
            elif col == 1: ax.set_yticklabels([])
        else:
            ax.grid(False)
            ax.text(0.5, 0.82, factors[row], fontsize=15, fontweight='bold', ha='center', va='center', transform=ax.transAxes)
            ax.set_xticks([]); ax.set_yticks([])

for i in range(3):
    if i in legend_store:
        h, l = legend_store[i]
        leg = axes[i, i].legend(h, l, loc='center', bbox_to_anchor=(0.5, 0.4), fontsize=9, frameon=True, facecolor='white', edgecolor='black')

fig.text(0.01, 0.5, 'Mean Footprint Diameter (km)', va='center', rotation='vertical', fontsize=14, fontweight='bold')
plt.show()
