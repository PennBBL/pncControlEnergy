
import scipy.io as sio
import numpy as np
import os
import sys
from sklearn import linear_model
from sklearn import preprocessing
sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/ElasticNet')
import CZ_ElasticNet_2

DataFolder = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction';
Energy_Mat = sio.loadmat(DataFolder + '/Energy.mat');
Energy = Energy_Mat['Energy'];
Energy_WholeBrainAvg = np.mean(Energy, axis = 1);

Energy_YeoAvg_Mat = sio.loadmat(DataFolder + '/Energy_YeoAvg.mat');
Energy_YeoAvg = Energy_YeoAvg_Mat['Energy_YeoAvg'];

Behavior_Mat = sio.loadmat(DataFolder + '/Behavior.mat');
OverallAccuracy = Behavior_Mat['OverallAccuracy'];
Age_years = Behavior_Mat['Age_years'];
MotionMeanRelRMS = Behavior_Mat['MotionMeanRelRMS'];
TBV = Behavior_Mat['TBV'];

sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_2
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy, OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy[:,FPDM_Index], OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy_YeoAvg, OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);

ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction';
sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/LeastSquares');
import LeastSquares_CZ_Sort_2
LeastSquares_CZ_Sort_2.LinearRegression_KFold_Sort(Energy_WholeBrainAvg, OverallAccuracy, 10, ResultantFolder);
