import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as ticker

# --- 1. Simulation & Data Generation (Combined Logic) ---
f, c = 2.1e9, 299792458
lambda_val, h_geo = c / f, 35786000
k_val = 2 * np.pi / lambda_val
N_list = [5, 25, 45, 65, 85]
D_list = [1, 3, 5, 7, 9]
Gap_list = [50, 150, 250, 350, 450]
u_side = np.sin(np.deg2rad(np.linspace(0, 90, 2000)))

results = []
for N in N_list:
    p_x_base = (np.random.rand(N) - 0.5) * (np.sqrt(N) * 1.5)
    for D in D_list:
        for Gap in Gap_list:
            p_x = p_x_base * (D + Gap)
            phases = k_val * p_x[:, np.newaxis] * u_side[np.newaxis, :]
            AF_side = np.sum(np.exp(1j * phases), axis=0)
            P_side = (np.abs(AF_side) / N)**2
            indices = np.where(P_side < 0.5)[0]
            avg_side_power = np.mean(P_side[indices[0]:]) if indices.size > 0 else 0
            
            results.append({
                'Number of Sat': N, 
                'Diam (D)': D, 
                'Gap (m)': Gap, 
                'SideLobe': avg_side_power
            })

df = pd.DataFrame(results)

# --- 2. Interaction Matrix Plotting ---
sns.set_theme(style="whitegrid")
factors = ['Number of Sat', 'Diam (D)', 'Gap (m)']
# Units for the legends
units = ['', 'm', 'm'] 
# Unique palettes for each row
row_palettes = ['magma', 'mako', 'crest'] 

fig, axes = plt.subplots(3, 3, figsize=(13, 11))
plt.subplots_adjust(wspace=0.12, hspace=0.12)

legend_store = {}

# First Pass: Plotting and Formatting
for row in range(3):
    for col in range(3):
        ax = axes[row, col]
        if row != col:
            x_var, hue_var = factors[col], factors[row]
            sns.lineplot(data=df, x=x_var, y='SideLobe', hue=hue_var, 
                         ax=ax, marker='o', palette=row_palettes[row], 
                         linewidth=2.5, errorbar=None)
            
            # Store legend with units
            if row not in legend_store:
                handles, labels = ax.get_legend_handles_labels()
                # Adding units to labels (if applicable)
                labels = [f"{label} {units[row]}".strip() for label in labels]
                legend_store[row] = (handles, labels)
            
            ax.get_legend().remove()
            
            # Tick Formatting: Adding commas to large numbers
            ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, p: format(int(x), ',')))
            ax.yaxis.set_major_formatter(ticker.FormatStrFormatter('%.2f')) # SideLobe is small, use decimals
            
            ax.set_xlabel(''); ax.set_ylabel('')
            
            if row == 0: ax.xaxis.tick_top()
            elif row == 1: ax.set_xticklabels([])
            if col == 2: ax.yaxis.tick_right()
            elif col == 1: ax.set_yticklabels([])
        else:
            # Diagonal formatting
            ax.grid(False)
            ax.text(0.5, 0.82, factors[row], fontsize=15, fontweight='bold', 
                    ha='center', va='center', color='#333333', transform=ax.transAxes)
            ax.set_xticks([]); ax.set_yticks([])

# Second Pass: Insert Legends into Diagonals
for i in range(3):
    if i in legend_store:
        handles, labels = legend_store[i]
        leg = axes[i, i].legend(handles, labels, loc='center', bbox_to_anchor=(0.5, 0.4),
                                fontsize=9, frameon=True, facecolor='white', edgecolor='black')
        for line in leg.get_lines():
            line.set_linewidth(2.5)

fig.text(0.01, 0.5, 'Avg Side Lobe Power', va='center', rotation='vertical', 
         fontsize=14, fontweight='bold')

plt.tight_layout(rect=[0.03, 0.03, 0.97, 0.97])
plt.show()
