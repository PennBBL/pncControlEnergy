
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/Users/zaixucui/Documents/Projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
EnergyAgeTBV_Sample1_Mat = sio.loadmat(DataFolder + '/EnergyAgeTBV_Sample1.mat');
EnergyAgeTBV_Sample1 = EnergyAgeTBV_Sample1_Mat['EnergyAgeTBV_Sample1'];
EnergyAgeTBV_Sample2_Mat = sio.loadmat(DataFolder + '/EnergyAgeTBV_Sample2.mat');
EnergyAgeTBV_Sample2 = EnergyAgeTBV_Sample2_Mat['EnergyAgeTBV_Sample2'];

OverallAccuracy_Sample1_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample1.mat');
OverallAccuracy_Sample1 = OverallAccuracy_Sample1_Mat['OverallAccuracy_Sample1'];
OverallAccuracy_Sample2_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample2.mat');
OverallAccuracy_Sample2 = OverallAccuracy_Sample2_Mat['OverallAccuracy_Sample2'];

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_Sample1_Predict_Sample2_EnergyAgeTBV';
Ridge_CZ_Sort_Energy.Ridge_APredictB(EnergyAgeTBV_Sample1, OverallAccuracy_Sample1, EnergyAgeTBV_Sample2, OverallAccuracy_Sample2, 0, 8, ResultantFolder, 15);
