
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction';
Energy_Mat = sio.loadmat(DataFolder + '/EnergyAgeTBV.mat');
EnergyAgeTBV = Energy_Mat['EnergyAgeTBV'];

Behavior_Mat = sio.loadmat(DataFolder + '/Behavior.mat');
OverallAccuracy = Behavior_Mat['OverallAccuracy'];

ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_Weight_EnergyAgeTBV';
Ridge_CZ_Sort_Energy.Ridge_Weight(EnergyAgeTBV, OverallAccuracy, np.exp2(np.arange(16) - 10), 3, ResultantFolder, 5);

