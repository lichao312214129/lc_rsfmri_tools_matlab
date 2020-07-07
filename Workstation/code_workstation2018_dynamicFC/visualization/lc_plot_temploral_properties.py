# -*- coding: utf-8 -*-
"""
Created on Sat Sep 14 20:30:36 2019
Used to plot temporal properties
@author: lenovo
"""
import sys
sys.path.append(r'D:\My_Codes\easylearn-fmri\eslearn\visualization')
import pandas as pd
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

from el_violine import ViolinPlotMatplotlib as vl

# Inputs
filepath = r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\temporal_propertities.mat'

# Load data
data = sio.loadmat(filepath)

#plt.figure(figsize=(8,10))

# Plot
group = data['group_design_matched']
# sort_group to hc sz bd and mdd
group_sorted = group
group_sorted[:,1], group_sorted[:,2], group_sorted[:,3] = group[:,2], group[:,3], group[:,1]

# Extract metrics for each state
fractional_window = data['fractional_window']
mean_dwelltime = data['mean_dwelltime']
num_transitions = data['num_transitions']

fractional_window = [fractional_window[:,i] for i in range(3)]
fractional_window = [[fractional_window[s][group_sorted[:,i]==1] for i in range(4)] for s in range(3)]

mean_dwelltime = [mean_dwelltime[:,i] for i in range(3)]
mean_dwelltime = [[mean_dwelltime[s][group_sorted[:,i]==1] for i in range(4)] for s in range(3)]

num_transitions = [num_transitions[group_sorted[:,i]==1] for i in range(4)]

#%% Plot
color = ['gainsboro', 'darkgray', 'dimgray', 'k'][::-1]
# fractional_window
plt.figure(figsize=(8,5))
plt.bar([0,2.5,5], 
    [np.mean(fractional_window[0][0]), np.mean(fractional_window[1][0]), np.mean(fractional_window[2][0])],
    yerr=[np.std(fractional_window[0][0])/np.power(210,0.5), np.std(fractional_window[1][0])/np.power(210,0.5), np.std(fractional_window[2][0])/np.power(210,0.5)], 
    color=color[0], width=0.3)

plt.bar([0.5,3,5.5], 
    [np.mean(fractional_window[0][1]), np.mean(fractional_window[1][1]), np.mean(fractional_window[2][1])], 
    yerr=[np.std(fractional_window[0][1])/np.power(150,0.5), np.std(fractional_window[1][1])/np.power(150,0.5), np.std(fractional_window[2][1])/np.power(150,0.5)], 
    color=color[1], width=0.3)

plt.bar([1,3.5,6], 
    [np.mean(fractional_window[0][2]), np.mean(fractional_window[1][2]), np.mean(fractional_window[2][2])], 
    yerr=[np.std(fractional_window[0][2])/np.power(100,0.5), np.std(fractional_window[1][2])/np.power(100,0.5), np.std(fractional_window[2][2])/np.power(100,0.5)], 
    color=color[2], width=0.3)

plt.bar([1.5,4,6.5], 
    [np.mean(fractional_window[0][3]), np.mean(fractional_window[1][3]), np.mean(fractional_window[2][3])], 
    yerr=[np.std(fractional_window[0][3])/np.power(150,0.5), np.std(fractional_window[1][3])/np.power(150,0.5), np.std(fractional_window[2][3])/np.power(150,0.5)], 
    color=color[3], width=0.3)

plt.ylabel('Fraction of time', fontsize=15)
plt.xticks([0,2.5,5, 0.5,3,5.5, 1,3.5,6, 1.5,4,6.5], ['HC', 'HC', 'HC', 'SZ', 'SZ', 'SZ', 'BD', 'BD', 'BD', 'MDD', 'MDD', 'MDD'], fontsize=12)
plt.text(0.5, -0.1, 'State 1', fontsize=15)
plt.text(3.0, -0.1, 'State 2', fontsize=15)
plt.text(5.5, -0.1,'State 3', fontsize=15)

plt.tick_params(labelsize=12)
ax = plt.gca()
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.spines['left'].set_linewidth(1)
ax.spines['bottom'].set_linewidth(1)

plt.subplots_adjust(wspace = 0.2, hspace =0.2)
plt.tight_layout()
pdf = PdfPages(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\fractional_window.pdf')
pdf.savefig()
pdf.close()

# mean_dwelltime
plt.figure(figsize=(8,5))
plt.bar([0,2.5,5], 
    [np.mean(mean_dwelltime[0][0]), np.mean(mean_dwelltime[1][0]), np.mean(mean_dwelltime[2][0])], 
    yerr=[np.std(mean_dwelltime[0][0])/np.power(210,0.5), np.std(mean_dwelltime[1][0])/np.power(210,0.5), np.std(mean_dwelltime[2][0]/np.power(210,0.5))], 
    width=0.3, color=color[0])

plt.bar([0.5,3,5.5],
    [np.mean(mean_dwelltime[0][1]), np.mean(mean_dwelltime[1][1]), np.mean(mean_dwelltime[2][1])],
     yerr=[np.std(mean_dwelltime[0][1])/np.power(150,0.5), np.std(mean_dwelltime[1][1])/np.power(150,0.5), np.std(mean_dwelltime[2][1])/np.power(150,0.5)],
     width=0.3, color=color[1])

plt.bar([1,3.5,6], 
    [np.mean(mean_dwelltime[0][2]), np.mean(mean_dwelltime[1][2]), np.mean(mean_dwelltime[2][2])],
    yerr=[np.std(mean_dwelltime[0][2])/np.power(100,0.5), np.std(mean_dwelltime[1][2])/np.power(100,0.5), np.std(mean_dwelltime[2][2])/np.power(100,0.5)],
    width=0.3, color=color[2])

plt.bar([1.5,4,6.5],
    [np.mean(mean_dwelltime[0][3]), np.mean(mean_dwelltime[1][3]), np.mean(mean_dwelltime[2][3])],
    yerr=[np.std(mean_dwelltime[0][3])/np.power(150,0.5), np.std(mean_dwelltime[1][3])/np.power(150,0.5), np.std(mean_dwelltime[2][3])/np.power(150,0.5)],
    width=0.3, color=color[3])

plt.ylabel('Mean dwell time', fontsize=15)
plt.xticks([0,2.5,5, 0.5,3,5.5, 1,3.5,6, 1.5,4,6.5], ['HC', 'HC', 'HC', 'SZ', 'SZ', 'SZ', 'BD', 'BD', 'BD', 'MDD', 'MDD', 'MDD'], fontsize=12)
plt.text(0.5, -6.5, 'State 1', fontsize=15)
plt.text(3.0, -6.5, 'State 2', fontsize=15)
plt.text(5.5, -6.5,'State 3', fontsize=15)

plt.tick_params(labelsize=12)
ax = plt.gca()
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.spines['left'].set_linewidth(1)
ax.spines['bottom'].set_linewidth(1)

plt.subplots_adjust(wspace = 0.2, hspace =0.2)
plt.tight_layout()
pdf = PdfPages(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\mean_dwelltime.pdf')
pdf.savefig()
pdf.close()


# number of transitions
plt.figure(figsize=(3,5))
plt.bar([0,0.5,1,1.5], 
    [np.mean(num_transitions[0]), np.mean(num_transitions[1]), np.mean(num_transitions[2]),np.mean(num_transitions[3])], 
    yerr=[np.std(num_transitions[0])/np.power(210,0.5), np.std(num_transitions[1])/np.power(159,0.5), np.std(num_transitions[2]/np.power(100,0.5)), np.std(num_transitions[3]/np.power(150,0.5))], 
    width=0.3, color=[color[0], color[1], color[2], color[3]])


plt.ylabel('Number of transitions', fontsize=15)
plt.xticks([0,0.5,1,1.5], ['HC', 'SZ', 'BD', 'MDD'], fontsize=12)
plt.tick_params(labelsize=12)
ax = plt.gca()
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.spines['left'].set_linewidth(1)
ax.spines['bottom'].set_linewidth(1)

plt.subplots_adjust(wspace = 0.2, hspace =0.2)
plt.tight_layout()
pdf = PdfPages(r'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\number_of_transitions.pdf')
pdf.savefig()
pdf.close()