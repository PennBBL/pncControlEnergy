
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/Users/zaixucui/Documents/Projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
EnergyAge_Sample1_Mat = sio.loadmat(DataFolder + '/EnergyAge_Sample1.mat');
EnergyAge_Sample1 = EnergyAge_Sample1_Mat['EnergyAge_Sample1'];

OverallAccuracy_Sample1_Mat = sio.loadmat(DataFolder + '/OverallAccuracy_Sample1.mat');
OverallAccuracy_Sample1 = OverallAccuracy_Sample1_Mat['OverallAccuracy_Sample1'];

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_10FCV_EnergyAge';
Ridge_CZ_Sort_Energy.Ridge_KFold_Sort(EnergyAge_Sample1, OverallAccuracy_Sample1, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 15, 0);
