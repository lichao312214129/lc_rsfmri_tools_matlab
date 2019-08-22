# -*- coding: utf-8 -*-
"""
Created on Wed Aug 21 09:05:21 2019
According to subjects' ID, extracting clinical data, such as age, sex, medication information, HAMA and so on.
@author: lenovo
"""
import sys
sys.path.append(r'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_python\Statistics')
import pandas as pd
import numpy as np
import scipy.stats as stats

from lc_chisqure import lc_chisqure

# input
demographicdata_all = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Scales\大表_add_drugInfo.xlsx'
id_hc = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_hc_final.xlsx'
id_sz = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_sz_final.xlsx'
id_bd = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_bd_final.xlsx'
id_mdd = r'D:\WorkStation_2018\Workstation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_mdd_final.xlsx'

# load_demographic data and ID of each group
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
header_need_extracting = ['年龄','性别','病程月','首发','用药_x','用药_y',
                         'HAMD-17_Total','HAMA_Total','YMRS_Total','BPRS_Total',
                         'Wisconsin_Card_Sorting_Test_CR,Correct_Responses','CC,Categories_Completed',
                         'TE,Total_Errors','PE,Perseverative_Errors','NPE,Nonperseverative_Errors',
                         'anti-depressant','anti-psycho','moodstablizer','anti-anxiety']

demographicdata_hc = demographicdata_hc[header_need_extracting]
demographicdata_sz = demographicdata_sz[header_need_extracting]
demographicdata_bd = demographicdata_bd[header_need_extracting]
demographicdata_mdd = demographicdata_mdd[header_need_extracting]

####################################### stat ##################################################
# describe continuous data, such as age, HAMA etc.
describe_hc = demographicdata_hc.describe()
describe_sz = demographicdata_sz.describe()
describe_bd = demographicdata_bd.describe()
describe_mdd = demographicdata_mdd.describe()

# describe categorie data such as sex, first epidode, medication etc. 
male_num_hc = list(demographicdata_hc['性别']).count(1)
male_num_sz = list(demographicdata_sz['性别']).count(1)
male_num_bd = list(demographicdata_bd['性别']).count(1)
male_num_mdd = list(demographicdata_mdd['性别']).count(1)

# first epidode
firstepisode_num_sz = list(demographicdata_sz['首发']).count(1)
firstepisode_num_bd = list(demographicdata_bd['首发']).count(1)
firstepisode_num_mdd = list(demographicdata_mdd['首发']).count(1)

# medication
medication_num_sz = list(demographicdata_sz['用药_x']).count(1)
medication_num_bd = list(demographicdata_bd['用药_x']).count(1)
medication_num_mdd = list(demographicdata_mdd['用药_x']).count(1)

# anti-depressant
antidepressant_num_sz = list(demographicdata_sz['anti-depressant']).count(1)
antidepressant_num_bd = list(demographicdata_bd['anti-depressant']).count(1)
antidepressant_num_mdd = list(demographicdata_mdd['anti-depressant']).count(1)

# anti-psycho
antipsycho_num_sz = list(demographicdata_sz['anti-psycho']).count(1)
antipsycho_num_bd = list(demographicdata_bd['anti-psycho']).count(1)
antipsycho_num_mdd = list(demographicdata_mdd['anti-psycho']).count(1)

# moodstablizer
moodstablizer_num_sz = list(demographicdata_sz['moodstablizer']).count(1)
moodstablizer_num_bd = list(demographicdata_bd['moodstablizer']).count(1)
moodstablizer_num_mdd = list(demographicdata_mdd['moodstablizer']).count(1)

# anti-anxiety
antianxiety_num_sz = list(demographicdata_sz['anti-anxiety']).count(1)
antianxiety_num_bd = list(demographicdata_bd['anti-anxiety']).count(1)
antianxiety_num_mdd = list(demographicdata_mdd['anti-anxiety']).count(1)

# other drug
otherdrug_sz = medication_num_sz - antidepressant_num_sz - antipsycho_num_sz - moodstablizer_num_sz - antianxiety_num_sz
otherdrug_bd = medication_num_bd - antidepressant_num_bd - antipsycho_num_bd - moodstablizer_num_bd - antianxiety_num_bd
otherdrug_mdd = medication_num_mdd - antidepressant_num_mdd - antipsycho_num_mdd - moodstablizer_num_mdd - antianxiety_num_mdd

####################################### Get statistics and p values ##################################################
# age
age_hc = demographicdata_hc['年龄'].dropna()
age_sz = demographicdata_sz['年龄'].dropna()
age_bd = demographicdata_bd['年龄'].dropna()
age_mdd = demographicdata_mdd['年龄'].dropna()
f, p = stats.f_oneway(age_hc, age_sz, age_bd, age_mdd)
print(f'f={f}\np={p}')

# sex
tt = [150,100,150]
obs = [male_num_hc, male_num_sz, male_num_bd, male_num_mdd]
print(lc_chisqure(obs, tt))

# first epidode, excluded HCs
obs = [firstepisode_num_sz, firstepisode_num_bd, firstepisode_num_mdd]
print(lc_chisqure(obs, tt))

# duration
duration_sz = demographicdata_sz['病程月']
duration_bd = demographicdata_bd['病程月']
duration_mdd = demographicdata_mdd['病程月']
f, p = stats.f_oneway( duration_sz, duration_bd, duration_mdd)
print(f'f={f}\np={p}')

# medication, excluded HCs
obs = [medication_num_sz, medication_num_bd, medication_num_mdd]
print(lc_chisqure(obs, tt))

# antidepressant, excluded HCs
obs = [antidepressant_num_sz, antidepressant_num_bd, antidepressant_num_mdd]
print(lc_chisqure(obs, [150,100,150]))

# antipsycho, excluded HCs
obs = [antipsycho_num_sz, antipsycho_num_bd, antipsycho_num_mdd]
print(lc_chisqure(obs, [150,100,150]))

# moodstablizer
obs = [moodstablizer_num_sz, moodstablizer_num_bd, moodstablizer_num_mdd]
print(lc_chisqure(obs, [150,100,150]))

# antianxiety
obs = [antianxiety_num_sz, antianxiety_num_bd, antianxiety_num_mdd]
print(lc_chisqure(obs, [150,100,150]))

# HAMD
hamd_hc = demographicdata_hc['HAMD-17_Total'].dropna()
hamd_sz = demographicdata_sz['HAMD-17_Total'].dropna()
hamd_bd = demographicdata_bd['HAMD-17_Total'].dropna()
hamd_mdd = demographicdata_mdd['HAMD-17_Total'].dropna()
f, p = stats.f_oneway(hamd_hc, hamd_sz, hamd_bd, hamd_mdd)
print(f'f={f}\np={p}')

# HAMA
hama_hc = demographicdata_hc['HAMA_Total'].dropna()
hama_sz = demographicdata_sz['HAMA_Total'].dropna()
hama_bd = demographicdata_bd['HAMA_Total'].dropna()
hama_mdd = demographicdata_mdd['HAMA_Total'].dropna()
f, p = stats.f_oneway(hama_hc, hama_sz, hama_bd, hama_mdd)
print(f'f={f}\np={p}')

# YMRS
yars_hc = demographicdata_hc['YMRS_Total'].dropna()
yars_sz = demographicdata_sz['YMRS_Total'].dropna()
yars_bd = demographicdata_bd['YMRS_Total'].dropna()
yars_mdd = demographicdata_mdd['YMRS_Total'].dropna()
f, p = stats.f_oneway(yars_hc, yars_sz, yars_bd, yars_mdd)
print(f'f={f}\np={p}')

#BPRS
bprs_hc = demographicdata_hc['BPRS_Total'].dropna()
bprs_sz = demographicdata_sz['BPRS_Total'].dropna()
bprs_bd = demographicdata_bd['BPRS_Total'].dropna()
bprs_mdd = demographicdata_mdd['BPRS_Total'].dropna()
f, p = stats.f_oneway(bprs_hc, bprs_sz, bprs_bd, bprs_mdd)
print(f'f={f}\np={p}')

# WCST: Correct_Responses
cr_hc = demographicdata_hc['Wisconsin_Card_Sorting_Test_CR,Correct_Responses'].dropna()
cr_sz = demographicdata_sz['Wisconsin_Card_Sorting_Test_CR,Correct_Responses'].dropna()
cr_bd = demographicdata_bd['Wisconsin_Card_Sorting_Test_CR,Correct_Responses'].dropna()
cr_mdd = demographicdata_mdd['Wisconsin_Card_Sorting_Test_CR,Correct_Responses'].dropna()
f, p = stats.f_oneway(cr_hc, cr_sz, cr_bd, cr_mdd)
print(f'f={f}\np={p}')

#WCST: CC,Categories_Completed
cc_hc = demographicdata_hc['CC,Categories_Completed'].dropna()
cc_sz = demographicdata_sz['CC,Categories_Completed'].dropna()
cc_bd = demographicdata_bd['CC,Categories_Completed'].dropna()
cc_mdd = demographicdata_mdd['CC,Categories_Completed'].dropna()
f, p = stats.f_oneway(cc_hc, cc_sz, cc_bd, cc_mdd)
print(f'f={f}\np={p}')

#WCST: TE,Total_Errors
te_hc = demographicdata_hc['TE,Total_Errors'].dropna()
te_sz = demographicdata_sz['TE,Total_Errors'].dropna()
te_bd = demographicdata_bd['TE,Total_Errors'].dropna()
te_mdd = demographicdata_mdd['TE,Total_Errors'].dropna()
f, p = stats.f_oneway(te_hc, te_sz, te_bd, te_mdd)
print(f'f={f}\np={p}')

#WCST: PE,Perseverative_Errors
pe_hc = demographicdata_hc['PE,Perseverative_Errors'].dropna()
pe_sz = demographicdata_sz['PE,Perseverative_Errors'].dropna()
pe_bd = demographicdata_bd['PE,Perseverative_Errors'].dropna()
pe_mdd = demographicdata_mdd['PE,Perseverative_Errors'].dropna()
f, p = stats.f_oneway(pe_hc, pe_sz, pe_bd, pe_mdd)
print(f'f={f}\np={p}')

# WCST: NPE,Nonperseverative_Errors
npe_hc = demographicdata_hc['NPE,Nonperseverative_Errors'].dropna()
npe_sz = demographicdata_sz['NPE,Nonperseverative_Errors'].dropna()
npe_bd = demographicdata_bd['NPE,Nonperseverative_Errors'].dropna()
npe_mdd = demographicdata_mdd['NPE,Nonperseverative_Errors'].dropna()
f, p = stats.f_oneway(npe_hc, npe_sz, npe_bd, npe_mdd)
print(f'f={f}\np={p}')


from sklearn import metrics
from sklearn.cluster import KMeans
import numpy as np

datas = np.vstack([np.random.randn(100,50)-1, np.random.randn(100,50)+1])
kmeans_model = KMeans(n_clusters=2, random_state=1).fit(datas)
labels = kmeans_model.labels_
a = metrics.silhouette_score(datas, labels, metric='euclidean')
print(a)
