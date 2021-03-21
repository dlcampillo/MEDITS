import xlsxwriter as xlsw
import pandas as pd
import numpy as np
from geopy.distance import geodesic

travel_time = 25

workbook = xlsw.Workbook('distances.xlsx')
dist = workbook.add_worksheet('distances')

dataframe = pd.read_excel('kcluster.xlsx')

X = np.array(dataframe[['LONG', 'LAT']])

dist.write(0,0,'C1')

for i in range(0, 303):
    dist.write(0, i+1, i+1)
    dist.write(i+1, 0, i+1)

for i in range(0, 303):
    for j in range(0, 303):
        orig = (X[i, 0], X[i, 1])
        dest = (X[j, 0], X[j, 1])
        t = geodesic(orig, dest).kilometers / travel_time

        dist.write(i+1, j+1, t)

workbook.close()