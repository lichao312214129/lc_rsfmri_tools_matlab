# -*- coding: utf-8 -*-
"""
This script is used to get information for held out samples.
"""
import pandas as pd
import os
import numpy as np

# ID of held out samples and all scales' file
scale_file = r'D:\WorkStation_2018\WorkStation_CNN_Schizo\Scale\10-24大表.xlsx'
held_out_samples_id = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\held_out_samples.txt'
headmotion_file = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\headmovement.xlsx'

# Load
scale = pd.read_excel(scale_file)
held_out_samples = pd.read_csv(held_out_samples_id, header=None)
headmotion = pd.read_excel(headmotion_file)

# Extract ID from head motion excel file
subjname = headmotion['subjects']
subjname = subjname.str.findall('[1-9]\d*')
subjname = [np.int(sn[0]) for sn in subjname]
subjname = pd.Series(subjname)

# Replace subject ID with suhjname
headmotion['subjects'] = subjname

# Merge
covarites_of_held_out_samples = pd.merge(scale, held_out_samples, left_on='folder', right_on=0, how='inner')
covarites_of_held_out_samples = pd.merge(covarites_of_held_out_samples, headmotion, left_on='folder', right_on='subjects', how='inner')[['folder','诊断', '年龄', '性别', 'meanFD']]

print(covarites_of_held_out_samples)
covarites_of_held_out_samples.to_csv(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\covariates_of_held_out_samples.txt', index=None)
