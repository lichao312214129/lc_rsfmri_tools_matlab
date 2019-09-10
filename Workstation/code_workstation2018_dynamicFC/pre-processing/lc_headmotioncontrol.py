# -*- coding: utf-8 -*-
"""
This code is used to exclude subjects with great head movement
Already have ID that should excluded
"""
import os
import pandas as pd


def identify_subjects_survived_from_headmotion_control(excluded_subjects_name = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\headmotion\excluded_subjects_concat.xlsx',
 														all_subjects_data = r'F:\Data\Doctor\Results\ROISignals_FumImgARWSFC_all'):
    """
    Used to identify subjects that survived from headmotion control
    parameters: 
    	excluded_subjects_name: Subjects' ID that needed to exclude (list or filename)
    	all_subjects_name: All subjects; (list or filename)
    Returns:
    	included_subjects: included subjects that survived from headmotion control
    """
    # excluded_subjects' ID
    excluded_subjects_name = pd.read_excel(excluded_subjects_name, header=None)
    excluded_subjects_name = excluded_subjects_name.drop_duplicates()
    excluded_subjects_name = excluded_subjects_name[0]
    excluded_subjects_id = excluded_subjects_name.str.findall('[0-9]{1,5}')
    excluded_subjects_id = [id[0] for id in excluded_subjects_id]
    
    # all subjects' name
    all_subjects_name = os.listdir(all_subjects_data)
    all_subjects_name = [name.split('.')[0] for name in all_subjects_name]
    all_subjects_id = pd.Series(all_subjects_name).str.findall(('[1-9][0-9]{1,4}'))
    all_subjects_id = [id[0] for id in all_subjects_id]
    
    
    
    # included subjects without greater motion
    included_subjects = pd.Series(list(set(all_subjects_id) - set(excluded_subjects_id))).sort_values()  
    
    # save
    included_subjects.to_excel(r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\headmotion\included_subjects_851.xlsx',header=False,index=False)

#if __name__ == '__main__':
#    pass
	# identify_subjects_survived_from_headmotion_control(excluded_subjects_name = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\headmotion\excluded_subjects_concat.xlsx',
 														# all_subjects_data = r'F:\Data\Doctor\Results\ROISignals_FumImgARWSFC_diagnosis_screened')