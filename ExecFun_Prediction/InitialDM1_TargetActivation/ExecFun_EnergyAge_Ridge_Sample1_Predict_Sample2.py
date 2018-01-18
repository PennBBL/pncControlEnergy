
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/Users/zaixucui/Documents/Projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
EnergyAge_Sample1_Mat = sio.loadmat(DataFolder + '/EnergyAge_Sample1.mat');
EnergyAge_Sample1 = EnergyAge_Sample1_Mat['EnergyAge_Sample1'];
EnergyAge_Sample2_Mat = sio.loadmat(DataFolder + '/EnergyAge_Sample2.mat');
EnergyAge_Sample2 = EnergyAge_Sample2_Mat['EnergyAge_Sample2'];

OverallAccuracy_Sample1_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample1.mat');
OverallAccuracy_Sample1 = OverallAccuracy_Sample1_Mat['OverallAccuracy_Sample1'];
OverallAccuracy_Sample2_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample2.mat');
OverallAccuracy_Sample2 = OverallAccuracy_Sample2_Mat['OverallAccuracy_Sample2'];

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_Sample1_Predict_Sample2_EnergyAge';
Ridge_CZ_Sort_Energy.Ridge_APredictB(EnergyAge_Sample1, OverallAccuracy_Sample1, EnergyAge_Sample2, OverallAccuracy_Sample2, 0, 8, ResultantFolder, 15);
