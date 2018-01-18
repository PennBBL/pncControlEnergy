
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction';
Energy_Mat = sio.loadmat(DataFolder + '/Energy.mat');
Energy = Energy_Mat['Energy'];

Behavior_Mat = sio.loadmat(DataFolder + '/Behavior.mat');
OverallAccuracy = Behavior_Mat['OverallAccuracy'];

# Permutation, 1000 times
Permutation_Folder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_3FCV_Permutation';
Ridge_CZ_Sort_Energy.Ridge_KFold_Sort_Permutation(Energy, OverallAccuracy, np.arange(1000), 3, np.exp2(np.arange(16) - 10), Permutation_Folder, 5, 200, '-q all.q');

