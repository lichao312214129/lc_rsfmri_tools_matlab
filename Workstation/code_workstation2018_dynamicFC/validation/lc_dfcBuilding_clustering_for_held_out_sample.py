"""
This script is used to perform dfc analysis and clustering for held out samples.
"""
import pandas as pd

# Step 1: Getting held out samples' information.
scale_file = r'D:\WorkStation_2018\WorkStation_CNN_Schizo\Scale\10-24大表.xlsx'
roi_single_dir = r'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\ROISignals_testing'; 

scale = pd.read_excel(scale_file)
print(scale)