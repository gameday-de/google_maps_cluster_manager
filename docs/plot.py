import pandas as pd
from matplotlib import pyplot as plt


fig, axs = plt.subplots(2, 2)
((ax1, ax2), (ax3, ax4)) = axs

for ax, eps in [(ax1, '1m'), (ax2, '1km'), (ax3, '10km'), (ax4, '100km')]:
    file = f"/Users/tmarkmann/matchmap/mono/services/mobile-app/ext/google_maps_cluster_manager/docs/timing_analysis_epsilon={eps}.csv"
    columns = ["NR_MARKER", "GEOHASH"]
    df = pd.read_csv(file,sep=';')
    
    ax.axis(ymin=0,ymax=1)
    ax.set_title(f'fixed clustering using epsilon={eps}')
    ax.set(xlabel='#Marker', ylabel='Time in s')
    ax.plot(df.NR_MARKER, df.GEOHASH, label='GEOHASH')
    ax.plot(df.NR_MARKER, df.DIST_AGGLO_HAVERSINE, label='DIST_AGGLO_HAVERSINE')
    ax.plot(df.NR_MARKER, df.DIST_AGGLO_SIMPLIFIED, label='DIST_AGGLO_SIMPLIFIED')
    ax.plot(df.NR_MARKER, df.DIST_GREEDY_HAVERSINE, label='DIST_GREEDY_HAVERSINE')
    ax.plot(df.NR_MARKER, df.DIST_GREEDY_SIMPLIFIED, label='DIST_GREEDY_SIMPLIFIED')

for ax in axs.flat:
    ax.set(xlabel='#marker', ylabel='time in s')
for ax in axs.flat:
    ax.label_outer()

plt.legend()
plt.show()
