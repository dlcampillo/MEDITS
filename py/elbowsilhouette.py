from sklearn.cluster import KMeans
import pandas as pd
import numpy as np

from yellowbrick.cluster import KElbowVisualizer, SilhouetteVisualizer, InterclusterDistance

dataframe = pd.read_excel('tablafinal.xlsx')
dataframe = dataframe[:-1]

X = np.array(dataframe[['LONG', 'LAT']])

# Instantiate the clustering model and visualizer
model = KMeans()
visualizer = KElbowVisualizer(model, k=(2,50))

visualizer.fit(X)
visualizer.show()

visualizer = SilhouetteVisualizer(model, colors='yellowbrick', k=)

visualizer.fit(X)
visualizer.show()

model = KMeans(10)
visualizer = InterclusterDistance(model)

visualizer.fit(X)
visualizer.show()