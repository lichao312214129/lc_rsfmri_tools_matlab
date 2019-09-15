# -*- coding: utf-8 -*-
"""
Created on Mon Sep  2 16:35:30 2019
This script is used to concat clinical data and head motion information
Then, saving to excel file for statistics analysis
@author: lenovo
"""

import sys
sys.path.append(r'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_python\Statistics')
import pandas as pd
import numpy as np
import os
import scipy.stats as stats

from lc_chisqure import lc_chisqure

# input
out_dir = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion'
headmotion_info = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\headmovement.xlsx'
demographicdata_all = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Scales\大表_add_drugInfo.xlsx'
id_hc = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_hc_final.xlsx'
id_sz = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_sz_final.xlsx'
id_bd = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_bd_final.xlsx'
id_mdd = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_mdd_final.xlsx'

# load_demographic data and ID of each group
headmotion_info = pd.read_excel(headmotion_info)
demographicdata_all = pd.read_excel(demographicdata_all)
colname = list(demographicdata_all.columns)
id_hc = pd.read_excel(id_hc,header=None)
id_sz = pd.read_excel(id_sz, header=None)
id_bd = pd.read_excel(id_bd, header=None)
id_mdd = pd.read_excel(id_mdd, header=None)

# extracting demographic data according to ID
demographicdata_hc = pd.merge(demographicdata_all, id_hc, left_on='folder', right_on=0, how='inner')
demographicdata_sz = pd.merge(demographicdata_all, id_sz, left_on='folder', right_on=0, how='inner')
demographicdata_bd = pd.merge(demographicdata_all, id_bd, left_on='folder', right_on=0, how='inner')
demographicdata_mdd = pd.merge(demographicdata_all, id_mdd, left_on='folder', right_on=0, how='inner')
demographicdata_all_screened = pd.concat([demographicdata_hc,demographicdata_sz,demographicdata_bd, demographicdata_mdd], axis=0)
demographicdata_all_screened = demographicdata_all_screened[['folder','诊断','年龄','性别','用药_x']]
demographicdata_all_screened['用药_x'] = demographicdata_all_screened['用药_x'].fillna(0)

# Merge headmotion_info and demographicdata_all_screened
regfolder = headmotion_info['subjects'].str.findall('[1-9]\d*')
regfolder = [np.int64(regfolder_[0]) for regfolder_ in regfolder if len(regfolder_)]
headmotion_info['subjects'] = regfolder
all_cov = pd.merge(demographicdata_all_screened, headmotion_info, left_on='folder', right_on='subjects', how='inner')

all_cov = all_cov.iloc[:,[0,1,2,3,4,6]]
all_cov.to_excel(os.path.join(out_dir,'all_covariates1.xlsx'), index=False)
