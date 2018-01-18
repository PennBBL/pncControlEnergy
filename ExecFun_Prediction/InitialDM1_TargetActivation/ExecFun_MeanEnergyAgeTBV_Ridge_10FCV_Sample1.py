
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/Users/zaixucui/Documents/Projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
MeanEnergyAgeTBV_Sample1_Mat = sio.loadmat(DataFolder + '/MeanEnergyAgeTBV_Sample1.mat');
MeanEnergyAgeTBV_Sample1 = MeanEnergyAgeTBV_Sample1_Mat['MeanEnergyAgeTBV_Sample1'];

OverallAccuracy_Sample1_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample1.mat');
OverallAccuracy_Sample1 = OverallAccuracy_Sample1_Mat['OverallAccuracy_Sample1'];

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_10FCV_MeanEnergyAgeTBV';
Ridge_CZ_Sort_Energy.Ridge_KFold_Sort(MeanEnergyAgeTBV_Sample1, OverallAccuracy_Sample1, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 15, 0);
