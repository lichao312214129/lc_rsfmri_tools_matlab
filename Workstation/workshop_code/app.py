# -*- coding: utf-8 -*-
"""
Created on Wed Oct 28 21:55:50 2020

@author: Li Chao, Dong Mengshi
"""

import numpy as np
import pandas as pd
import pickle

from preprocess import preprocess
from preprocess import METRICS
from ensemble_model import Model


def app(data_file=None, 
        metric="all",
        include_diagnoses=(1,3), 
        num_sub=None, 
        feature_name=None, 
        label_name=None, 
        model_file=None):

    """ Application of our model

    Parameters:
    ----------
    data_file: file path
        Where is the .mat data file
    
    metric: string
        metric name, such as "FA" or "MD" or "all" [all modalities]

    include_diagnoses: tuple or list
        which groups/diagnoses included in training and validation, such as (1,3)

    num_sub: int
        How many subjects

    feature_name: string
        Name of the feature, such as "test_set"
    
    label_name: string
        Name of the label, such as "test_diagose"

    model_file: file path
        Where is the model file
    
    Returns:
    -------
    predict_proba: ndarray with shape of [n_samples, [*n_classes]]
        predict probability

    predict_label: ndarray with shape of [n_samples, ]
        predict label
    """
    
    # Instantiate model
    model = Model()
     
    # Load model
    all_models = pickle.load(open(model_file, "rb"))
    
    # Get data and preprocessing
    data_for_all, real_label = preprocess(data_file, 
                                                        feature_name=feature_name, 
                                                        label_name=label_name, 
                                                        num_sub=num_sub
    )
    
    # ========TEST==========
    data_for_all = data_test
    real_label = label_test
    # ========TEST==========
    
    if metric == "all":
        # Concatenate all modalities
        for i, metrics_ in enumerate(METRICS):
            if i == 0:
                data = data_for_all[metrics_]
            else:
                data = np.hstack([data, data_for_all[metrics_]])
    else:
        data = data_for_all[metric]
    
    # Get include diagnoses
    idx = np.in1d(real_label, include_diagnoses)
    real_label =  real_label[idx].reshape(-1,)
    data = data[idx]
    
    # Denan
    data = pd.DataFrame(data).fillna(value=all_models["fill_value"])
    
    # Feature Preprocessing
    data = all_models["scaler"].transform(data)
    
    # Predict
    predict_proba, predict_label = model.predict(all_models["merged_model"], data)

    # Evaluation
    acc, auc, f1, confmat, report = model.evaluate(real_label, predict_proba, predict_label)
    print(f"Test dataset:\nacc = {acc}\nf1score = {f1}\nauc = {auc}\n")

    return predict_proba, predict_label


if __name__ == "__main__":
    from split import split
    (data_train, data_validation, data_test, 
    label_train, label_validation, label_test) = split(seed=66)

    # Parameters
    data_file = r'F:\AD分类比赛\MCAD_AFQ_competition.mat'
    include_diagnoses = (1,3)
    feature_name = "train_set" 
    label_name = "train_diagnose" 
    demographics_name = "train_population"
    num_sub = 700
    model_file = r"D:\My_Codes\lc_private_codes\AD分类比赛\ensemble_model_biclass_1.dat"
    
    # Predict
    predict_proba, predict_label = app(data_file=data_file, metric="all", include_diagnoses=include_diagnoses, 
        num_sub=num_sub, feature_name=feature_name, label_name=label_name, model_file=model_file
    )