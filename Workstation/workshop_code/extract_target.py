# -*- coding: utf-8 -*-
"""
Created on Wed Nov  4 21:16:11 2020
Used to extract targets and subject unique identifier
@author: lenovo
"""

import os
import pandas as pd
import numpy as np

# Inputs
fc_file = r"F:\workshop\demo_data\SelectedFC_COBRE"
demographics_file = r"F:\workshop\demo_data\\COBRE_phenotypic_data.csv"

# Load fc name
fc = os.listdir(fc_file)
subname = pd.DataFrame(fc)
subname_id = subname[0].str.findall("[1-9]\d*")
subname_id = pd.DataFrame([int(si[0]) for si in subname_id])

# Load demog
demo = pd.read_csv(demographics_file)

# Extract diagnosis
diag = pd.merge(demo, subname_id, left_on="ID", right_on=0)[["ID", "Subject Type"]]
diag.rename(columns={"ID": "__ID__", "Subject Type": "__Targets__"}, inplace=True)
diag["__ID__"] = ["sub-" + str(id) for id in diag["__ID__"]]
diag.drop(diag["__Targets__"][diag["__Targets__"] == "Disenrolled"].index, inplace=True)
diag["__Targets__"] = np.int32(diag["__Targets__"] == "Patient")

# Save to excel
diag.to_excel(r"F:\workshop\demo_data\targets.xlsx", index=False)

# Change fc file names into sub-***
fc_path_name = [os.path.join(fc_file, fc_) for fc_ in fc]
fc_new_path_name = [os.path.join(fc_file, "sub-"+ str(id_) + ".mat") for id_ in subname_id[0]]

for (on, nn) in zip(fc_path_name, fc_new_path_name):
    os.rename(on,nn)
