# -*- coding: utf-8 -*-
"""
Created on Wed Oct 28 15:45:42 2020

@author: Li Chao, Dong Mengshi
"""

import numpy as np
import pandas as pd
import pickle
import os
from collections import Counter
from imblearn.over_sampling import RandomOverSampler

from split import split
from ensemble_model import Model
from preprocess import METRICS

(data_train, data_validation, data_test, 
label_train, label_validation, label_test) = split(seed=66)


def main(include_diagnoses=(1,3)):
    """Training and validation using all modalities

    Parameters:
    ----------
    include_diagnoses: tuple or list
        Which groups/diagnoses included in training and validation, such as (1,3)
    """

    # Instantiate model
    model = Model()
    
    # Concatenate all modalities, demo and mean_num_na
    for i, metrics_ in enumerate(METRICS):
        if i == 0:
            data_train_all_mod = data_train[metrics_]
            data_validation_all_mod = data_validation[metrics_]
            data_test_all_mod = data_test[metrics_]
        else:
            data_train_all_mod = np.hstack([data_train_all_mod, data_train[metrics_]])
            data_validation_all_mod = np.hstack([data_validation_all_mod, data_validation[metrics_]])
            data_test_all_mod = np.hstack([data_test_all_mod, data_test[metrics_]])
            
    # Get included diagnoses
    idx_train = np.in1d(label_train, include_diagnoses)
    idx_validation = np.in1d(label_validation, include_diagnoses)
    idx_test = np.in1d(label_test, include_diagnoses)

    label_train_ = label_train[idx_train]
    data_train_ = data_train_all_mod[idx_train]

    label_validation_ =  label_validation[idx_validation]
    data_validation_ = data_validation_all_mod[idx_validation]

    label_test_ =  label_test[idx_test]
    data_test_ = data_test_all_mod[idx_test]

    # Concatenate all features
    # data_train_ = np.hstack([data_train_, mean_num_na_train_, demo_train_])
    # data_validation_ = np.hstack([data_validation_, mean_num_na_validation_, demo_validation_])

    # Denan
    data_train_, label_train_, value = model.denan(data_train_, label_train_, fill=True)
    data_validation_ = pd.DataFrame(data_validation_).fillna(value=value)
    data_test_ = pd.DataFrame(data_test_).fillna(value=value)
    
    # Preprocessing
    scaler, data_train_ = model.preprocess_(data_train_)
    data_validation_ = scaler.transform(data_validation_)
    data_test_ = scaler.transform(data_test_)
    
    # Re-sample
    ros = RandomOverSampler(random_state=0)
    print(Counter(label_train_))
    data_train_, label_train_ = ros.fit_sample(data_train_, label_train_)
    print(Counter(label_train_))
        
    # Fit
    clf1 = model.make_linearSVC()
    clf2 = model.make_SVC()
    clf3 = model.make_logistic_regression()
    clf4 = model.make_ridge_regression()
    clf5 = model.make_xgboost()
    clf6 = model.make_gradientboosting()
    clfs = [clf1, clf2, clf3, clf4, clf5, clf6]
    # clfs = [clf1]
    
    # Merge models
    merged_model = model.train_ensemble_classifier(data_train_, label_train_, *clfs)
    
    # Dict models and scaler
    model_and_param = {"merged_model": merged_model, "fill_value": value, "scaler": scaler}
    
    # Save original models, merged model and scaler
    groups = ["nc","mci","ad"]
    save_name = [groups[include_diagnoses_-1] for include_diagnoses_ in include_diagnoses]
    save_name = "ensemble_model_" + "VS".join(save_name) + ".pickle.dat"
    save_file = os.path.join("D:\My_Codes\lc_private_codes\AD分类比赛", save_name)
    pickle.dump(model_and_param, open(save_file, "wb"))
    
    # Predict
    predict_proba_train, prediction_train = model.predict(merged_model, data_train_)
    predict_proba_validation, prediction_validation = model.predict(merged_model, data_validation_)
    predict_proba_test, prediction_test = model.predict(merged_model, data_test_)
    
    # Evaluation
    acc_train, auc_train, f1_train, confmat_train, report_train = model.evaluate(label_train_, predict_proba_train, prediction_train)
    acc_validation, auc_validation, f1_validation, confmat_validation, report_validation = model.evaluate(label_validation_, predict_proba_validation, prediction_validation)
    acc_test, auc_test, f1_test, confmat_test, report_test = model.evaluate(label_test_, predict_proba_test, prediction_test)
    print(f"Traing dataset:\nacc = {acc_train}\nf1score = {f1_train}\nauc = {auc_train}\n")
    print(f"Validation dataset:\nacc = {acc_validation}\nf1score = {f1_validation}\nauc = {auc_validation}\n")
    # print(f"Test dataset:\nacc = {acc_test}\nauc = {auc_test}\nf1score = {f1_test}\n")
    # print(f"Model is {clfs[0].best_estimator_}")
    return (predict_proba_train, prediction_train, report_train, predict_proba_validation, prediction_validation, report_validation)


if __name__ ==  "__main__":
    (predict_proba_train, prediction_train, report_train, predict_proba_validation, prediction_validation, report_validation) = main(include_diagnoses=(1,3))