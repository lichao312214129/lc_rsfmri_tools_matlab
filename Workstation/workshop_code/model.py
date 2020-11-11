# -*- coding: utf-8 -*-
"""
Created on Tue Oct 27 19:58:29 2020

@author: Li Chao, Dong Mengshi
"""

import pandas  as pd
import numpy as np
from sklearn import preprocessing
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.model_selection import StratifiedKFold
from sklearn.decomposition import PCA
from sklearn.model_selection import GridSearchCV
from sklearn.pipeline import Pipeline
from sklearn.feature_selection import RFECV
from sklearn.linear_model import RidgeClassifier
from sklearn.linear_model import LogisticRegression, LogisticRegressionCV
from sklearn.svm import LinearSVC, SVC
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from sklearn.ensemble import VotingClassifier
from sklearn import metrics



self.file = r'F:\AD分类比赛\MCAD_AFQ_competition.mat'
self.seed = 666
self.pca_n_component = np.linspace(0.7, 0.99, 2)
# self.pca_n_component = [0.95]
self.regularization_strength = np.logspace(-3, 3, 3)
# self.regularization_strength = [0.0001]

if not isinstance(data, pd.core.frame.DataFrame):
        data = pd.DataFrame(data)

value = data.mean()
if fill:
    data_ = data.fillna(value=value)
    # data_ = data_.fillna(values=)
    label_ = label
else:       
    idx_nan = np.sum(np.isnan(data),axis=1) > 0  # Drop the case if have any nan
    data_ = data.dropna().values
    label_ = label[idx_nan == False]
    
return data_, label_, value


scaler = StandardScaler()
data_ = scaler.fit_transform(data)