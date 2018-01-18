
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/Users/zaixucui/Documents/Projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
MeanEnergyAgeTBV_Sample1_Mat = sio.loadmat(DataFolder + '/MeanEnergyAgeTBV_Sample1.mat');
MeanEnergyAgeTBV_Sample1 = MeanEnergyAgeTBV_Sample1_Mat['MeanEnergyAgeTBV_Sample1'];
MeanEnergyAgeTBV_Sample2_Mat = sio.loadmat(DataFolder + '/MeanEnergyAgeTBV_Sample2.mat');
MeanEnergyAgeTBV_Sample2 = MeanEnergyAgeTBV_Sample2_Mat['MeanEnergyAgeTBV_Sample2'];

OverallAccuracy_Sample1_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample1.mat');
OverallAccuracy_Sample1 = OverallAccuracy_Sample1_Mat['OverallAccuracy_Sample1'];
OverallAccuracy_Sample2_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample2.mat');
OverallAccuracy_Sample2 = OverallAccuracy_Sample2_Mat['OverallAccuracy_Sample2'];

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_Sample1_Predict_Sample2_MeanEnergyAgeTBV_Permutation';
Ridge_CZ_Sort_Energy.Ridge_APredictB_Permutation(MeanEnergyAgeTBV_Sample1, OverallAccuracy_Sample1, MeanEnergyAgeTBV_Sample2, OverallAccuracy_Sample2, np.arange(1000), 0, 0.00097656, ResultantFolder, 1, 1000, '-q all.q');
