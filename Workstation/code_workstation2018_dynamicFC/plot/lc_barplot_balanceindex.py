# -*- coding: utf-8 -*-
"""
Created on Wed Sep 18 22:45:16 2019

@author: lenovo
"""
import pandas as pd
balanceidxpath = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\balance_index\balanceidx.xlsx'
allscale = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\大表_add_drugInfo.xlsx'

balanceidx = pd.read_excel(balanceidxpath,header=None)
allscale = pd.read_excel(allscale)

matchscale = pd.merge(allscale, balanceidx, left_on='folder', right_on=0,how='inner')[['folder',1,'诊断']]

matchscale.to_excel(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\balance_index\bi.xlsx')
