DynFC : Dynamic functional connectivity estimation and analysis scripts
Nora Leonardi, 2013

This code implements the estimation and analysis of dynamic functional connectivity as described in 

Leonardi, N., et al., "Principal components of functional connectivity: A new approach to study dynamic brain connectivity during rest", NeuroImage 2013

You can run main_dynFC to see an example use and then modify it according to your needs:
>> main_dynFC


Contents 

- concatA: temporally concatenate dynFC matrices of multiple subjects
- DynConnSynthData.mat: example simulated data for 2 subjects
- dynFC: estimate dynamic functional connectivity
- GCP_peaks: select a subset of or all dynFC estimates (windows)
- main_dynFC: example script showing how to use the toolbox
- plot_TCS_dynconn: plots time course data and estimated dynFC for each subject
- plotCMfromVec: plot vectorized correlation matrix in symmetric form
- process_options: helper script
- smoothwavelet_n: used by dynFC
- wavelet_n: used by dynFC