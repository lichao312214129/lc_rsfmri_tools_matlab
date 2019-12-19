# -*- coding: utf-8 -*-
"""
This code is used to perform statistic analysis to headmotion
"""
import pandas as pd
import numpy as np
import scipy.stats as stats


headmotion_info = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\headmovement.xlsx'
id_hc = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_hc_final.xlsx'
id_sz = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_sz_final.xlsx'
id_bd = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_bd_final.xlsx'
id_mdd = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\id_mdd_final.xlsx'

# headmotion information
headmotion_info = pd.read_excel(headmotion_info)
headmotion_info = headmotion_info.drop_duplicates()
headmotion_info_id = headmotion_info['subjects']
headmotion_info_id = headmotion_info_id.str.findall('[1-9][0-9]{0,4}')
headmotion_info_id = [id[0] for id in headmotion_info_id]
headmotion_info['subjects'] = headmotion_info_id
headmotion_info['subjects'] = headmotion_info['subjects'].astype(np.int64)

# id
id_hc = pd.read_excel(id_hc, header=None)
id_sz = pd.read_excel(id_sz, header=None)
id_bd = pd.read_excel(id_bd, header=None)
id_mdd = pd.read_excel(id_mdd, header=None)

# extract
headmotion_info_hc = pd.merge(
    headmotion_info, id_hc, left_on='subjects', right_on=0, how='inner')
headmotion_info_sz = pd.merge(
    headmotion_info, id_sz, left_on='subjects', right_on=0, how='inner')
headmotion_info_bd = pd.merge(
    headmotion_info, id_bd, left_on='subjects', right_on=0, how='inner')
headmotion_info_mdd = pd.merge(
    headmotion_info, id_mdd, left_on='subjects', right_on=0, how='inner')

# statistics: FD and proportion
describe_hc = headmotion_info_hc.describe()
describe_sz = headmotion_info_sz.describe()
describe_bd = headmotion_info_bd.describe()
describe_mdd = headmotion_info_mdd.describe()

# statistics: max rigbody motion--translation
rigbody_translation_hc = headmotion_info_hc.iloc[:, [3, 4, 5]]
rigbody_translation_sz = headmotion_info_sz.iloc[:, [3, 4, 5]]
rigbody_translation_bd = headmotion_info_bd.iloc[:, [3, 4, 5]]
rigbody_translation_mdd = headmotion_info_mdd.iloc[:, [3, 4, 5]]

max_rigidbody_translation_hc = np.max(rigbody_translation_hc, axis=1)
max_rigidbody_translation_sz = np.max(rigbody_translation_sz, axis=1)
max_rigidbody_translation_bd = np.max(rigbody_translation_bd, axis=1)
max_rigidbody_translation_mdd = np.max(rigbody_translation_mdd, axis=1)

max_rigidbody_translation_hc.describe()
max_rigidbody_translation_sz.describe()
max_rigidbody_translation_bd.describe()
max_rigidbody_translation_mdd.describe()

# statistics: max rigbody motion--rotation (transform to degree)
rigbody_rotation_hc = headmotion_info_hc.iloc[:, [6, 7, 8]]
rigbody_rotation_sz = headmotion_info_sz.iloc[:, [6, 7, 8]]
rigbody_rotation_bd = headmotion_info_bd.iloc[:, [6, 7, 8]]
rigbody_rotation_mdd = headmotion_info_mdd.iloc[:, [6, 7, 8]]

max_rigidbody_rotation_hc = np.max(rigbody_rotation_hc, axis=1) * (180/np.pi)
max_rigidbody_rotation_sz = np.max(rigbody_rotation_sz, axis=1) * (180/np.pi)
max_rigidbody_rotation_bd = np.max(rigbody_rotation_bd, axis=1) * (180/np.pi)
max_rigidbody_rotation_mdd = np.max(rigbody_rotation_mdd, axis=1) * (180/np.pi)

max_rigidbody_rotation_hc.describe()
max_rigidbody_rotation_sz.describe()
max_rigidbody_rotation_bd.describe()
max_rigidbody_rotation_mdd.describe()

# Get statistics and p values
f, p = stats.f_oneway(headmotion_info_hc['meanFD'], headmotion_info_sz['meanFD'],
                      headmotion_info_bd['meanFD'], headmotion_info_mdd['meanFD'])
print(f'f={f}\np={p}')

f, p = stats.f_oneway(headmotion_info_hc['proportion_of_bad_timepoints'], headmotion_info_sz['proportion_of_bad_timepoints'],
                      headmotion_info_bd['proportion_of_bad_timepoints'], headmotion_info_mdd['proportion_of_bad_timepoints'])
print(f'f={f}\np={p}')

f, p = stats.f_oneway(max_rigidbody_translation_hc, max_rigidbody_translation_sz,
                      max_rigidbody_translation_bd, max_rigidbody_translation_mdd)
print(f'f={f}\np={p}')

f, p = stats.f_oneway(max_rigidbody_rotation_hc, max_rigidbody_rotation_sz,
                      max_rigidbody_rotation_bd, max_rigidbody_rotation_mdd)
print(f'f={f}\np={p}')
