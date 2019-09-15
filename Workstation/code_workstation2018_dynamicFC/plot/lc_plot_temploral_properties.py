# -*- coding: utf-8 -*-
"""
Created on Sat Sep 14 20:30:36 2019
Used to plot temporal properties
@author: lenovo
"""
import sys
sys.path.append(r'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_python\Plot')
import pandas as pd
import numpy as np
import lc_violinplot as violinplot
import matplotlib.pyplot as plt
import seaborn as sns

filepath = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\results_of_individual\temploral_properties.xlsx'

data = pd.read_excel(filepath)

#plt.figure(figsize=(8,10))

# 小提琴框架
ax=sns.violinplot(x='group', y='MDT_state1',
            data=data,
            palette="Set2",
            split=False,
            scale_hue=True,
            orient="v",
            inner="box")