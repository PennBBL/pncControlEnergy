
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_Energy

DataFolder = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction';
AgeTBVMeanEnergy_Mat = sio.loadmat(DataFolder + '/AgeTBVMeanEnergy_FPDM.mat');
AgeTBVMeanEnergy = AgeTBVMeanEnergy_Mat['AgeTBVMeanEnergy_FPDM'];

Behavior_Mat = sio.loadmat(DataFolder + '/Behavior.mat');
OverallAccuracy = Behavior_Mat['OverallAccuracy'];

ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_3FCV_AgeTBVMeanEnergy_FPDM';
Ridge_CZ_Sort_Energy.Ridge_KFold_Sort(AgeTBVMeanEnergy, OverallAccuracy, 3, np.exp2(np.arange(16) - 10), ResultantFolder, 5, 0);

