#!/usr/bin/env python
# coding: utf-8


import os
import scipy.io as sio
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from collections import Counter
from sklearn.model_selection  import StratifiedShuffleSplit
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.feature_selection import RFECV
from sklearn.svm import LinearSVC
from sklearn.linear_model import LogisticRegression, RidgeClassifier
from sklearn import metrics
from nilearn import plotting
from pyecharts.charts import Graph
from pyecharts import options as opts

#%% ===========================输入===========================
data_file = r"F:\workshop\demo_data\data"
label_file = r"F:\workshop\demo_data\targets.xlsx"

#%% ===========================读取特征和标签===========================
# 读取保存数据的文件名
files_name = os.listdir(data_file)
files = [os.path.join(data_file, fn) for fn in files_name]  # 获取所有功能连接的文件地址
label = pd.read_excel(label_file)
# print(f"files={files}")
print(label)

# 加载第一个功能连接， 查看数据形式
onefc = sio.loadmat(files[0])
print(f"数据类型为：{type(onefc)}")
# 查看字典的keys
print(f"功能连接的keys为: {onefc.keys()}")
# 第4个item是数据，我们查看数据的情况
dd = onefc[list(onefc.keys())[3]]
print(f"功能连接特征的原始形状为：{dd.shape}")
plt.imshow(dd, cmap="jet")
plt.colorbar()

# 逐个读取每个被试的功能连接， 并将所有数据放入data
# 因为功能连接是一个对称矩阵，即上三角和下三角是对称的，所以后续加载数据的时候，我们只保留上三角即可
mask = np.ones(np.shape(dd))
mask = np.triu(mask, 1)
mask  = mask == 1
plt.imshow(mask)
plt.colorbar()
plt.show()

# 加载并提取每个功能连接数据的上三角部分
data = []
for file in files:
    dd = sio.loadmat(file)
    dd = dd[list(dd.keys())[3]]
    dd = dd[mask]  # 用mask筛选上三角矩阵
    data.append(dd)
data = np.array(data)  # 将data转换为numpy.array
print(f"###特征的形状：{data.shape}###")
pd.DataFrame(data).head(5)

#%% ===========================将每个被试特征与其标签对齐===========================
# 1.第一步提取文件名中的被试名
files_name = pd.Series(files_name)
files_id = files_name.str.findall(".*sub.?\d*")
files_id = pd.DataFrame([fi[0] for fi in files_id])
# 2.将label按照文件名顺序重新排序
label_sorted = pd.merge(files_id, label, left_on=0, right_on="__ID__")
label_sorted = label_sorted["__Targets__"].values

# 为了后续演示，我故意在特征中随机设置5000个缺失值
n_sub = len(data)
id_nan = np.random.permutation(data.size)[:5000]
data = data.reshape([-1,1])
data[id_nan,] = np.nan
data = data.reshape(n_sub,-1)  

#%% =============================划分数据=============================
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

#%% =============================数据检查与处理=============================
# 检查训练集中缺失值
nan_value = np.sum(np.isnan(feature_train), axis=0)
print(f"所有特征中，最多的缺失值数量为：{np.max(nan_value)}")  # 最大的缺失值

# 缺失值不多，选择用均值填充缺失值
feature_train = pd.DataFrame(feature_train)
feature_validation = pd.DataFrame(feature_validation)
feature_test = pd.DataFrame(feature_test)

fill_value = feature_train.mean()  # 只能用训练集的参数，因为实际应用中我们往往不能获取测试集的数据
feature_train = pd.DataFrame(feature_train)
feature_train.fillna(value=fill_value, inplace=True)
feature_validation.fillna(value=fill_value, inplace=True)
feature_test.fillna(value=fill_value, inplace=True)

# 检查训练集特征数值为0的样本比例
zero_value = np.sum(feature_train==0, axis=0)
print(f"全为0的特征数量为: {np.max(zero_value)}")

# 规范化数据
scaler = StandardScaler()
feature_train_ = scaler.fit_transform(feature_train)
feature_validation_ = scaler.transform(feature_validation)  # 对验证集和测试集在规范化时，要用训练集的参数
feature_test_ = scaler.transform(feature_test)
pd.DataFrame(feature_train).head(5)

#%% =============================特征工程：降维 + 特征选择=============================
# 降维
pca = PCA(n_components=0.95, random_state=666)
feature_train_ = pca.fit_transform(feature_train_)
feature_validation_ = pca.transform(feature_validation_)  # 使用训练集的参数给验证集和测试集做降维
feature_test_ = pca.transform(feature_test_)
print(f"###降维后特征维度由{feature_train.shape[1]}变为{feature_train_.shape[1]}###")
pd.DataFrame(feature_train_).head(5)

# 递归特征消除筛选特征
selector = RFECV(LinearSVC(random_state=666), step=5, cv=5, n_jobs=3)
selector = selector.fit(feature_train_, label_train)
feature_train_ = selector.transform(feature_train_)

# 对验证集和测试集做特征选择，要用训练集的参数
feature_validation_ = selector.transform(feature_validation_)
feature_test_ = selector.transform(feature_test_)
print(f"###递归特征消除法选择特征后，特征维度为{feature_train_.shape[1]}###")
print(f"被剔除的特征的编号为：\n{pd.DataFrame(np.where(1-selector.support_)).values}")
pd.DataFrame(feature_train_).head(5)

#%% ============================训练模型============================
# model = LinearSVC(C=1, random_state=666)
model = RidgeClassifier(random_state=666)
model.fit(feature_train_, label_train)

#%% ============================模型验证============================
# 最好使用外部验证集
pred_train_label = model.predict(feature_train_)
pred_val_label = model.predict(feature_validation_)


# 模型验证，以及根据验证情况调参
acc_train = metrics.accuracy_score(label_train, pred_train_label)
f1score_train = metrics.f1_score(label_train, pred_train_label)
acc_validation = metrics.accuracy_score(label_validation, pred_val_label)
f1score_validation = metrics.f1_score(label_validation, pred_val_label)
print(f"acc_train = {acc_train:.3f}; f1score_train = {f1score_train}\nacc_validation = {acc_validation:.8f}; f1score_validaton = {f1score_validation}")

#%% ============================最终的测试============================
# 最好使用外部测试集
pred_test_label = model.predict(feature_test_)
pred_test_prob = model.decision_function(feature_test_)
acc_test = metrics.accuracy_score(label_test, pred_test_label)
f1score_test = metrics.f1_score(label_test, pred_test_label)
print(f"acc_test = {acc_test:.8f}; f1score_test = {f1score_test}\n")

#%% ============================结果可视化============================
# 获取权重
wei = model.coef_
wei = (wei - wei.mean()) / wei.std()
wei = selector.inverse_transform(wei)
wei = pca.inverse_transform(wei)
weight = np.zeros(mask.shape)
weight[mask] = wei[0]
weight = weight + weight.T

# 只显示前0.2%的权重
threshold = 99.8
topperc = np.percentile(np.abs(weight), threshold)
weight[np.abs(weight) < topperc] = 0

# 获取MNI坐标
coords_file = r"F:\workshop\demo_data\BNA_subregions.xlsx"
coords_info = pd.read_excel(coords_file)

# 获取MNI坐标
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

nodes = [{"name": nd, "symbolSize": np.sum(np.abs(np.float64(wei_node[:,1][np.in1d(wei_node[:,0], str(nd))])))*20} for nd in node]
links = [{"source": str(nd1), "target": str(nd2)} for (nd1, nd2) in zip(node1, node2)]
graph= (
        Graph()
        .add("", nodes, links, repulsion=100)
        .set_global_opts(title_opts=opts.TitleOpts(title=f"前{100-threshold:.2f}%的权重"))
    )
graph.render_notebook()



# 矩阵显示
plt.figure(figsize=(10,10))
plt.imshow(weight, cmap="RdBu_r")
plt.colorbar()
plt.show()

# 脑图显示
plotting.plot_connectome(weight, node_coords, node_size=0, annotate=True)
plt.show()
view = plotting.view_connectome(weight, node_coords)
view



