# -*- coding: utf-8 -*-
"""
Created on Mon Nov 19 14:42:56 2018
确认聚类结果中，分到label a的被试，有多少是MDD
1:HC;2:MDD;3:SZ;4:BD;5:HR
@author: lenovo
"""
import pandas as pd

def check_label(label='b'):
    # input
    dianosis={1:'HC',2:'MDD',3:'SZ',4:'BD',5:'HR'}
#    label='b'
    diagnosis_index=2
    scale_data_path=r"D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Scales\8.30大表.xlsx"
    training_data_path=r'D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\trainingData.xlsx'
    
    # read to DataFrame
    scale_data=pd.read_excel(scale_data_path)
    training_data=pd.read_excel(training_data_path)
    
    # screen mdd's folder and all label a's folder
    diagnosis_folder_in_scale=pd.DataFrame(scale_data.loc[scale_data['诊断'] == diagnosis_index]['folder'])
    label_folder_in_training_data=pd.DataFrame(training_data.loc[training_data['k=5_label'] == label]['folder'])
    
    # 交集
    selected_folder=diagnosis_folder_in_scale.set_index('folder').\
        join(label_folder_in_training_data.set_index('folder'),how='inner')
        
    # 求training data中mdd的占比
    per='{:f}'.format(len(selected_folder)/len(label_folder_in_training_data))
    diagnosis_name=dianosis[diagnosis_index]
    
    print('{}在label {} 中的占比是{}\n绝对数值是{}'.format(diagnosis_name,label,per,len(selected_folder)))

if __name__=='__main__':
    check_label(label='a')
    check_label(label='b')
    check_label(label='c')
    check_label(label='d')
    check_label(label='e')