import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
import xlsxwriter as xlsw
from geopy.distance import geodesic

n = 301
processing_time = 1.5
travel_time = 25

dataframe = pd.read_excel('tablafinal.xlsx')
dataframe = dataframe[:-1]

X = np.array(dataframe[['LONG', 'LAT']])

kmeans = KMeans(n_clusters=n)
kmeans.fit(X)
y_means = kmeans.predict(X)

centers = kmeans.cluster_centers_

# Body, weight and depth count

bodycount = np.zeros(n, dtype=int)
weight = dataframe['KG']
depth = dataframe['PROFUNDIDAD']
weightcount = np.zeros(n)
depthcount = np.zeros(n)
stratum = np.zeros(n, dtype=int)
time = np.zeros(n)

index = 0

for i in y_means:
    bodycount[i] += 1
    weightcount[i] += weight[index]
    depthcount[i] += depth[index]
    index += 1

# Average

for i in range(0, n - 1):
    weightcount[i] = weightcount[i] / bodycount[i]
    depthcount[i] = depthcount[i] / bodycount[i]

    if 10 <= depth[i] < 51:
        stratum[i] = 1
    elif 51 <= depth[i] < 101:
        stratum[i] = 2
    elif 101 <= depth[i] < 201:
        stratum[i] = 3
    elif 201 <= depth[i] < 501:
        stratum[i] = 4
    elif 501 <= depth[i] < 801:
        stratum[i] = 5

    if 1 <= stratum[i] <= 2:
        time[i] = 0.5
    else:
        time[i] = 1

z = 13

kzones = KMeans(n_clusters=z)
kzones.fit(centers)
y_zones = kzones.predict(centers)

plt.scatter(centers[:, 0], centers[:, 1], c=y_zones, s=5, cmap='tab20')
plt.title('Zones')
plt.colorbar()
plt.show()
plt.savefig('zones.png')

# Write in excel

workbook = xlsw.Workbook('kcluster.xlsx')
data = workbook.add_worksheet('data')

data.write(0, 0, 'ID')
data.write(0, 1, 'LONG')
data.write(0, 2, 'LAT')
data.write(0, 3, 'KG_TIME')
data.write(0, 4, 'DEPTH')
data.write(0, 5, 'STRATUM')
data.write(0, 6, 'ZONE')
data.write(0, 7, 'HAUL_TIME')

for i in range(1, n):
    data.write(i, 0, i)
    data.write(i, 1, centers[i, 0])
    data.write(i, 2, centers[i, 1])
    data.write(i, 3, weightcount[i] * processing_time / 100)
    data.write(i, 4, depthcount[i])
    data.write(i, 5, stratum[i])
    data.write(i, 6, y_zones[i])
    data.write(i, 7, time[i])

workbook.close()
