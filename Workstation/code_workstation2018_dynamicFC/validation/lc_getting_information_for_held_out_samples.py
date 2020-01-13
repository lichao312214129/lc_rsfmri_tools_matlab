"""
This script is used to get information for held out samples.
"""
import pandas as pd
import os
import numpy as np
# Step 1: Getting held out samples' information.
scale_file = r'D:\WorkStation_2018\WorkStation_CNN_Schizo\Scale\10-24大表.xlsx'
included_subjects = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\headmotion\included_subjects_from851database_ID.xlsx'
roi_signals_dir = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\dfc_whole'; 
roi_all_signals_dir = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\ROISignals_FumImgARWSFC_screened'

scale = pd.read_excel(scale_file)
included_subjects = pd.read_excel(included_subjects, header=None)

subjname = os.listdir(roi_signals_dir)
subjname = pd.Series(subjname)
subjname = subjname.str.findall('[1-9]\d*')
subjname = [np.int(sn[0]) for sn in subjname]
subjname = pd.DataFrame(subjname)

subjname_all = os.listdir(roi_all_signals_dir)
subjname_all = pd.Series(subjname_all)
subjname_all = subjname_all.str.findall('[1-9]\d*')
subjname_all = [np.int(sn[0]) for sn in subjname_all]
subjname_all = pd.DataFrame(subjname_all)

exclueded_subj = pd.DataFrame((set(included_subjects[0]) - set(subjname[0])))
exclueded_subj = scale[scale['folder'].isin(exclueded_subj[0])]['folder']
describe = exclueded_subj.value_counts()

exclueded_subj_available = pd.merge(subjname_all, exclueded_subj, left_on=0, right_on='folder', how='inner')
exclueded_subj_available[0].to_csv(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\held_out_samples.txt',index=None, header=None)
