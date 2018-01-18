
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/Users/zaixucui/Documents/Projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
AgeTBV_Sample1_Mat = sio.loadmat(DataFolder + '/AgeTBV_Sample1.mat');
AgeTBV_Sample1 = AgeTBV_Sample1_Mat['AgeTBV_Sample1'];
AgeTBV_Sample2_Mat = sio.loadmat(DataFolder + '/AgeTBV_Sample2.mat');
AgeTBV_Sample2 = AgeTBV_Sample2_Mat['AgeTBV_Sample2'];

OverallAccuracy_Sample1_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample1.mat');
OverallAccuracy_Sample1 = OverallAccuracy_Sample1_Mat['OverallAccuracy_Sample1'];
OverallAccuracy_Sample2_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample2.mat');
OverallAccuracy_Sample2 = OverallAccuracy_Sample2_Mat['OverallAccuracy_Sample2'];

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_Sample1_Predict_Sample2_AgeTBV';
Ridge_CZ_Sort_Energy.Ridge_APredictB(AgeTBV_Sample1, OverallAccuracy_Sample1, AgeTBV_Sample2, OverallAccuracy_Sample2, 0, 0.00097656, ResultantFolder, 15);
