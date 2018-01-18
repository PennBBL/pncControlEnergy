
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/Users/zaixucui/Documents/projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetFP1DMN1';
Energy_Mat = sio.loadmat(DataFolder + '/Energy.mat');
Energy = Energy_Mat['Energy'];

Behavior_Mat = sio.loadmat(DataFolder + '/Behavior.mat');
OverallAccuracy = Behavior_Mat['OverallAccuracy'];

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetFP1DMN1/ExecFun_Prediction/Ridge_3FCV22';
Ridge_CZ_Sort_Energy.Ridge_KFold_Sort(Energy[np.arange,], OverallAccuracy[np.arange], 3, np.exp2(np.arange(16) - 10), ResultantFolder, 5, 0);

