
# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import pandas as pd
import numpy as np

file = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\covariates_737.xlsx'
scale = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\大表_add_druginfo.xlsx'
dfc_metrics = r''

scale = pd.read_excel(scale)
cov = pd.read_excel(file)
header_cov = list(cov.columns)

cov = pd.merge(cov, scale, left_on='folder', right_on='folder', how='inner')
header_cov.append('HAMD-17_Total')
cov = cov[['folder', '诊断_x', '年龄_x', '性别_x', '用药_y', 'meanFD', 'HAMD-17_Total','HAMA_Total', 'YMRS_Total' ,'BPRS_Total', 
           'Wisconsin_Card_Sorting_Test_CR,Correct_Responses', 'CC,Categories_Completed', 'TE,Total_Errors','PE,Perseverative_Errors', 'NPE,Nonperseverative_Errors']]



cov.to_excel(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\covariates_737.xlsx', index=False)


