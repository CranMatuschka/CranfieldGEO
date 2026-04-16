import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as ticker

footprint_range = np.array([4, 20, 40, 80])
time_range = np.array([4, 8, 16, 32, 64])

R_mesh, T_mesh = np.meshgrid(footprint_range / 2, time_range)
area_data = ((24 * 3600) / (T_mesh )) * (np.power(R_mesh, 2) * np.pi)

df = pd.DataFrame({
    'Radius (km)': R_mesh.flatten(),
    'Service Time (sec)': T_mesh.flatten(),
    'Service Area (km^2)': area_data.flatten()
})

max_area = df['Service Area (km^2)'].max()
ticks_area = (np.linspace(0, 1, 6)**2) * max_area
sns.set_theme(style="whitegrid")
factors = ['Radius (km)', 'Service Time (sec)']
units = ['km', 'sec']
palettes = ['flare', 'crest'] 

fig, axes = plt.subplots(2, 2, figsize=(10, 8))
plt.subplots_adjust(wspace=0.15, hspace=0.15)

legend_store = {}

for row in range(2):
    for col in range(2):
        ax = axes[row, col]
        if row != col:
            x_var, hue_var = factors[col], factors[row]
            sns.lineplot(data=df, x=x_var, y='Service Area (km^2)', hue=hue_var, 
                         ax=ax, marker='o', palette=palettes[row], linewidth=2.5, errorbar=None)
            
            handles, labels = ax.get_legend_handles_labels()
            labels = [f"{float(label):.1f} {units[row]}" for label in labels]
            legend_store[row] = (handles, labels)
            ax.get_legend().remove()
            ax.set_yticks(ticks_area)
            ax.get_yaxis().set_major_formatter(ticker.FuncFormatter(lambda x, p: format(int(x), ',')))
            
            ax.set_xlabel(''); ax.set_ylabel('')
            if row == 0: ax.xaxis.tick_top()
            if col == 1: ax.yaxis.tick_right()
        else:
            ax.grid(False)
            ax.text(0.5, 0.82, factors[row], fontsize=14, fontweight='bold', 
                    ha='center', va='center', transform=ax.transAxes)
            ax.set_xticks([]); ax.set_yticks([])

for i in range(2):
    if i in legend_store:
        handles, labels = legend_store[i]
        leg = axes[i, i].legend(handles, labels, loc='center', bbox_to_anchor=(0.5, 0.4),
                                fontsize=9, frameon=True, facecolor='white', edgecolor='black')
        for line in leg.get_lines():
            line.set_linewidth(2.5)

fig.text(0.02, 0.5, 'Service Area ($km^2$)', va='center', rotation='vertical', 
         fontsize=14, fontweight='bold')
print(df)
plt.tight_layout(rect=[0.05, 0.03, 0.95, 0.95])
plt.show()