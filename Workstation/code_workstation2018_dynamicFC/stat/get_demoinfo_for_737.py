# -*- coding: utf-8 -*-
"""
Created on Sun Jun 28 11:38:35 2020

@author: lenovo
"""

import pandas as pd

id_737 = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\included_subjects_afterheadmotioncontrol_737.xlsx'
scale = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\大表_add_drugInfo.xlsx'
headmotion = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\headmovement.xlsx'

id_737 = pd.read_excel(id_737, header=None)
scale = pd.read_excel(scale)
headmotion = pd.read_excel(headmotion)

headmotion['subjects'] = headmotion['subjects'].str.findall('[1-9]\d*')
headmotion['subjects'] = [int(hm[0]) for  hm in headmotion['subjects']]

demoinfo_737 = pd.merge(id_737, scale, left_on=0, right_on='folder', how='inner')
demoinfo_737 = pd.merge(demoinfo_737, headmotion, left_on='folder', right_on='subjects', how='inner')
demoinfo_737 = demoinfo_737[['folder', '诊断', '年龄','性别', '用药_x', 'meanFD']]

demoinfo_737.to_excel('D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\covariates_737.xlsx', index=False)
