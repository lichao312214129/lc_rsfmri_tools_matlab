# -*- coding: utf-8 -*-
"""
Created on Fri Nov  6 20:26:50 2020

@author: lenovo
"""

import os
import scipy.io as sio
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from collections import Counter
from sklearn.model_selection  import StratifiedShuffleSplit
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.decomposition import PCA
from sklearn.feature_selection import RFECV
from sklearn.svm import LinearSVC, SVC
from sklearn.linear_model import LogisticRegression, RidgeClassifier
from sklearn.ensemble import StackingClassifier
from sklearn import metrics
from nilearn import plotting
from pyecharts.charts import Graph, Page
from pyecharts import options as opts
import time


#%% =============================加载数据================================
# 输入
data_file = r"F:\workshop\demo_data\data"
label_file = r"F:\workshop\demo_data\targets.xlsx"

# 读取保存数据的文件名
files_name = os.listdir(data_file)
files = [os.path.join(data_file, fn) for fn in files_name]  # 获取所有功能连接的文件地址
label = pd.read_excel(label_file)

# 加载第一个功能连接， 查看数据形式
onefc = sio.loadmat(files[0])
print(f"数据类型为：{type(onefc)}")
# 查看字典的keys
print(f"功能连接的keys为: {onefc.keys()}")
# 第4个item是数据，我们查看数据的情况
dd = onefc[list(onefc.keys())[3]]

# 逐个读取每个被试的功能连接， 并将所有数据放入data
# 因为功能连接是一个对称矩阵，即上三角和下三角是对称的，所以后续加载数据的时候，我们只保留上三角即可
mask = np.ones(np.shape(dd))
mask = np.triu(mask, 1)
mask  = mask == 1

# 加载每个功能连接数据的上三角部分
data = []
for file in files:
    dd = sio.loadmat(file)
    dd = dd[list(dd.keys())[3]]
    dd = dd[mask]  # 用mask筛选上三角矩阵
    data.append(dd)
data = np.array(data)  # 将data转换为numpy.array

# 将特征与标签对齐***
# 1.第一步提取文件名中的被试名
files_name = pd.Series(files_name)
files_id = files_name.str.findall(".*sub.?\d*")
files_id = pd.DataFrame([fi[0] for fi in files_id])
# 2.将label按照文件名顺序重新排序
label_sorted = pd.merge(files_id, label, left_on=0, right_on="__ID__")
label_sorted = label_sorted["__Targets__"].values

# 为了后续演示，我故意在特征中随机设置1000个缺失值
n_sub = len(data)
id_nan = np.random.permutation(data.size)[:5000]
data = data.reshape([-1,1])
data[id_nan,] = np.nan
data = data.reshape(n_sub,-1)

#%% =============================划分数据集================================
np.random.seed(0)
skf = StratifiedShuffleSplit(n_splits=1, test_size=0.4, random_state=666)
skf_index = list(skf.split(data, label_sorted))
feature_train = data[skf_index[0][0],:]
label_train = label_sorted[skf_index[0][0]]
feature_other = data[skf_index[0][1],:]
label_other = label_sorted[skf_index[0][1]]

skf = StratifiedShuffleSplit(n_splits=1, test_size=0.5, random_state=666)
skf_index = list(skf.split(feature_other, label_other))
feature_validation = feature_other[skf_index[0][0],:]
label_validation = label_other[skf_index[0][0]]
feature_test = feature_other[skf_index[0][1],:]
label_test = label_other[skf_index[0][1]]

# 检查各个数据中各类的数目, 即各类别是否平衡
print(f"训练集中各个类别的数目为：{sorted(Counter(label_train).items())}")
print(f"验证集中各个类别的数目为：{sorted(Counter(label_validation).items())}")
print(f"测试集中各个类别的数目为：{sorted(Counter(label_test).items())}")

#%% =============================检查数据并做数据处理================================
# 检查训练集中缺失值
plt.figure()
nan_value = np.sum(np.isnan(feature_train), axis=0)
np.max(nan_value)  # 最大的缺失值
plt.hist(nan_value)  # 缺失值分布
plt.show()

# 缺失值不多，选择用均值填充缺失值
# 如果某些列的缺失值较多，可以删除
feature_train = pd.DataFrame(feature_train)
feature_validation = pd.DataFrame(feature_validation)
feature_test = pd.DataFrame(feature_test)

fill_value = feature_train.mean()  # 只能用训练集的参数，因为实际应用中我们往往不能获取测试集的数据
feature_train = pd.DataFrame(feature_train)
feature_train.fillna(value=fill_value, inplace=True)
feature_validation.fillna(value=fill_value, inplace=True)
feature_test.fillna(value=fill_value, inplace=True)

# 检查训练集特征数值为0的样本比例
plt.figure()
zero_value = np.sum(feature_train==0, axis=0)
zero_value_prop = zero_value / len(feature_train)
np.max(zero_value_prop)  # 最大的缺失值
plt.hist(zero_value_prop)  # 缺失值分布
plt.show()

# 检查三个数据集的特征均值的分布
feature_train_mean = np.mean(feature_train, axis=0)
feature_validation_mean = np.mean(feature_validation, axis=0)
feature_test_mean = np.mean(feature_test, axis=0)
plt.figure()
sns.distplot(feature_train_mean, hist = False, kde_kws = {'color':'red', 'linestyle':'-'},
             norm_hist = True, label = 'Training dataset')
sns.distplot(feature_validation_mean, hist = False, kde_kws = {'color':'green', 'linestyle':'-'},
             norm_hist = True, label = 'Validation dataset')
sns.distplot(feature_test_mean, hist = False, kde_kws = {'color':'blue', 'linestyle':'-'},
             norm_hist = True, label = 'Test dataset')
plt.legend(["Training dataset", "Validation dataset", "Test dataset"])
plt.show()

# 检查三个数据集特征均值的相关性
coef = np.corrcoef([feature_train_mean.T, feature_validation_mean.T, feature_test_mean.T])
plt.figure(figsize=(6,5))
sns.heatmap(coef, annot=True, cbar=False)
plt.xticks([0.5,1.5,2.5],["Training dataset", "Validation dataset", "Test dataset"], rotation=45)
plt.yticks([0.5,1.5,2.5],["Training dataset", "Validation dataset", "Test dataset"], rotation=0)
plt.tight_layout()

# 规范化数据
scaler = StandardScaler()
feature_train_ = scaler.fit_transform(feature_train)
feature_validation_ = scaler.transform(feature_validation)
feature_test_ = scaler.transform(feature_test)

#%% =============================特征工程================================
# 降维
st = time.time()
pca = PCA(n_components=0.95, random_state=666)
feature_train_ = pca.fit_transform(feature_train_)
feature_validation_ = pca.transform(feature_validation_)
feature_test_ = pca.transform(feature_test_)
et = time.time()
print(f"Running time of pca is {et-st:.3f}")

# 递归特征消除筛选特征
st = time.time()
selector = RFECV(LinearSVC(random_state=666), step=0.2, cv=5, n_jobs=3)
selector = selector.fit(feature_train_, label_train)
feature_train_ = selector.transform(feature_train_)
feature_validation_ = selector.transform(feature_validation_)
feature_test_ = selector.transform(feature_test_)
et = time.time()
print(f"Running time of RFECV is {et-st:.3f}")

#%% =============================训练模型================================
# 训练单一模型
model = LinearSVC(C=1, random_state=666)
model.fit(feature_train_, label_train)

# # 模型融合
# clf1 = LogisticRegression(random_state=666)
# clf2 = RidgeClassifier(random_state=666)
# clf3 = LinearSVC(C=1, random_state=666)
# clf4 = SVC(C=1, kernel="sigmoid")
# clfs = [("lr", clf1), ("rr", clf2), ("svc", clf3), ("rsvc", clf4)]  
# model = StackingClassifier(estimators=clfs, final_estimator=LogisticRegression(), n_jobs=2)
# model.fit(feature_train_, label_train)

#%% =============================训练验证================================
pred_train_label = model.predict(feature_train_)
pred_val_label = model.predict(feature_validation_)
pred_val_prob = model.decision_function(feature_validation_)

#%% =============================模型评估================================
acc_train = metrics.accuracy_score(label_train, pred_train_label)
acc_validation = metrics.accuracy_score(label_validation, pred_val_label)
print(f"acc_train = {acc_train:.3f}\nacc_validation = {acc_validation:.3f}")

#%% =============================最终的测试================================
pred_test_label = model.predict(feature_test_)
pred_test_prob = model.decision_function(feature_test_)
acc_test = metrics.accuracy_score(label_test, pred_test_label)
print(f"acc_test = {acc_test:.3f}\n")

#%% =============================查看权重==================================

# 获取权重
wei = model.coef_
wei = (wei - wei.mean()) / wei.std()
wei = pca.inverse_transform(wei)
weight = np.zeros(mask.shape)
weight[mask] = wei[0]
weight = weight + weight.T

# 只显示前5%的权重
topperc = np.percentile(np.abs(weight), 99.5)
weight[np.abs(weight) < topperc] = 0

# 获取MNI坐标
coords_file = r"G:\BranAtalas\BrainnetomeAtlasViewer\BNA_subregions.xlsx"
coords_info = pd.read_excel(coords_file)
coords = np.hstack([coords_info["lh.MNI(X,Y,Z)"].values, coords_info["rh.MNI(X,Y,Z)"].values])
label_idx = np.hstack([coords_info["Label ID.L"].values, coords_info["Label ID.R"].values])
sort_idx = np.argsort(label_idx)
node_coords = coords[sort_idx]
node_coords = pd.DataFrame([eval(nc) for nc in node_coords]).values

# 获取node name
name = coords_info["Left and Right Hemisphere"]
name_L = ["L".join(name_.split("L(R)")) for name_ in name]
name_R = ["R".join(name_.split("L(R)")) for name_ in name]
node_name = np.hstack([name_L, name_R])
node_name = node_name[sort_idx]

# 获取构成连接的节点名称
id_mat = np.where(weight)
node1 = node_name[id_mat[0]]
node2 = node_name[id_mat[1]]
node = np.hstack([node1, node2])
node = np.unique(node)

# 显示连接网络
weight_filter = weight[id_mat[0], id_mat[1]]
wei_node = np.hstack([node1, node2]).T
wei_node = np.vstack([wei_node, np.hstack([weight_filter, weight_filter])]).T

nodes = [{"name": nd, "symbolSize": np.sum(np.abs(np.float64(wei_node[:,1][np.in1d(wei_node[:,0], str(nd))])))*10} for nd in node]
links = [{"source": str(nd1), "target": str(nd2)} for (nd1, nd2) in zip(node1, node2)]
graph= (
        Graph()
        .add("", nodes,links, repulsion=1000)
        .set_global_opts(title_opts=opts.TitleOpts(title="前0.1%的权重"))
    )
graph.render()


# 只显示靠前的权重
plt.imshow(weight, cmap="RdBu_r")
plt.colorbar()

plotting.plot_connectome(weight, node_coords, annotate=True)

view = plotting.view_connectome(weight, node_coords)
view.open_in_browser()


from chord import Chord
names = [str(i) for i in range(246)]
chrod_fig = Chord(weight, names, colors="d3.schemeSet2").to_html("chrod_fig.html")
