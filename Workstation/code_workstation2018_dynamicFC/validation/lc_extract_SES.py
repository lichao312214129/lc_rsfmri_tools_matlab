"""
This script is used to extract other variances, such as height, weight, education, etc.
"""
import pandas as pd

scale_whole_file = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\10-24大表.xlsx'
covariance_file = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\all_covariates.xlsx'

scale_whole = pd.read_excel(scale_whole_file)
covariance = pd.read_excel(covariance_file)

covariance_add_SES = pd.merge(covariance, scale_whole, left_on='folder', right_on='folder', how='inner', suffixes=('', '_y'))
colname_convariance = list(covariance.columns)
# covariance_add_SES = covariance_add_SES[colname_convariance + ['身高', '体重', '学历（年）', '目前吸烟情况']].drop('用药_x', axis=1).dropna()
covariance_add_SES = covariance_add_SES[colname_convariance + ['身高', '体重', '学历（年）']].drop('用药_x', axis=1).dropna()

covariance_add_SES.to_csv(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\all_covariates_add_SES.txt')
