# -*- coding: utf-8 -*-
"""
Used to extract subjects' ID after headmotion control as well as age and sex matching
1:HC;2:MDD;3:SZ;4:BD
"""
import os
import sys
sys.path.append(r'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_python\Statistics')
import pandas as pd
import numpy as np
import scipy.stats as stats

from eslearn.statistical_analysis.lc_chisqure import lc_chisqure

# input
all_subjects = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\headmotion\all_ID_851.xlsx'
included_subjects = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\headmotion\included_subjects_from851database_ID.xlsx' # survived from headmotion control
all_demographicdata = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\10-24大表.xlsx'

# load
all_subjects = pd.read_excel(all_subjects, header=None)
included_subjects = pd.read_excel(included_subjects, header=None)
all_demographicdata = pd.read_excel(all_demographicdata)

# extract demographic data for HC, SZ, BD and MDD

# all
#all_demographicdata = pd.merge(all_demographicdata, all_subjects, left_on='folder', right_on=0, how='inner')
#all_demographicdata_HC = all_demographicdata[all_demographicdata['诊断'] ==1]
#all_demographicdata_MDD = all_demographicdata[all_demographicdata['诊断'] ==2]
#all_demographicdata_SZ = all_demographicdata[all_demographicdata['诊断'] ==3]
#all_demographicdata_BD = all_demographicdata[all_demographicdata['诊断'] ==4]

# included subjects according headmotion control
included_demographicdata = pd.merge(all_demographicdata, included_subjects, left_on='folder', right_on=0, how='inner')
included_demographicdata_HC = included_demographicdata[included_demographicdata['诊断'] ==1]
included_demographicdata_MDD = included_demographicdata[included_demographicdata['诊断'] ==2]
included_demographicdata_SZ = included_demographicdata[included_demographicdata['诊断'] ==3]
included_demographicdata_BD = included_demographicdata[included_demographicdata['诊断'] ==4]

# age and sex
age_HC = included_demographicdata_HC['年龄'].dropna()
age_SZ = included_demographicdata_SZ['年龄'].dropna()
age_BD = included_demographicdata_BD['年龄'].dropna()
age_MDD = included_demographicdata_MDD['年龄'].dropna()

sex_HC = included_demographicdata_HC['性别'].dropna()
sex_SZ = included_demographicdata_SZ['性别'].dropna()
sex_BD = included_demographicdata_BD['性别'].dropna()
sex_MDD = included_demographicdata_MDD['性别'].dropna()

# The first comparsion
f, p = stats.f_oneway(age_HC, age_SZ, age_BD, age_MDD)

obs = [np.sum(sex_HC == 1), np.sum(sex_SZ == 1), np.sum(sex_BD == 1), np.sum(sex_MDD == 1)]
tt = [sex_HC.shape[0], sex_SZ.shape[0], sex_BD.shape[0], sex_MDD.shape[0]]
chivalue, chip = lc_chisqure(obs, tt)

# Age among groups are not matched, so I cheack mean age of each group
print(age_HC.mean(), age_SZ.mean(), age_BD.mean(), age_MDD.mean())


# age and sex matching
# age
sortind_sz = list(age_SZ.sort_values().index)
sortind_mdd = list(age_MDD.sort_values().index)
sortind_bd = list(age_BD.sort_values().index)
sortind_hc = list(age_HC.sort_values().index)

# sz = age_SZ[sortind_sz[3:]]
# bd = age_BD[sortind_bd[0:100]]
# mdd = age_MDD[sortind_mdd[0:150]]
# hc = age_HC[sortind_hc[0:210]]

hc = age_HC[sortind_hc[0:210]]
sz = age_SZ[sortind_sz[:]]
bd = age_BD[sortind_bd[0:]]
mdd = age_MDD[sortind_mdd[0:]]


print(f'{np.mean(hc)}, {np.mean(sz)},{np.mean(bd)},{np.mean(mdd)}')
f, p = stats.f_oneway(hc, sz, bd, mdd)
print(f'p={p}')

# sex
obs = [np.sum(sex_HC[hc.index]==1), np.sum(sex_SZ[sz.index]==1), np.sum(sex_BD[bd.index]==1), np.sum(sex_MDD[mdd.index]==1)]
tt = [len(hc), len(sz), len(bd), len(mdd)]
chivalue, chip = lc_chisqure(obs, tt)

# extract ID
id_hc = included_demographicdata_HC.loc[hc.index]['folder'].sort_values()
id_sz = included_demographicdata_SZ.loc[sz.index]['folder'].sort_values()
id_bd = included_demographicdata_BD.loc[bd.index]['folder'].sort_values()
id_mdd = included_demographicdata_MDD.loc[mdd.index]['folder'].sort_values()
id_hc.to_excel('id_hc.xlsx',index=False,header=None)
id_sz.to_excel('id_sz.xlsx',index=False,header=None)
id_bd.to_excel('id_bd.xlsx',index=False,header=None)
id_mdd.to_excel('id_mdd.xlsx',index=False,header=None)

