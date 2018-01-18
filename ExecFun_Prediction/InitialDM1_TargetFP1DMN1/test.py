
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

FirstSample_Index = np.arange(500);
SencondSample_index = np.arange(447) + 500;
Energy_First = Energy[FirstSample_Index, :];
Energy_Second = Energy[SencondSample_index, :];
normalize = preprocessing.MinMaxScaler();
Energy_First = normalize.fit_transform(Energy_First);
Energy_Second = normalize.transform(Energy_Second);
clf = linear_model.Ridge(alpha = 1);
clf.fit(Energy_First, OverallAccuracy[FirstSample_Index]);
Second_predict = clf.predict(Energy_Second);
OverallAcc_Corr = np.corrcoef(Second_predict, OverallAccuracy[SencondSample_index]);

Yeo_Index_Mat = sio.loadmat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Yeo_Index = Yeo_Index_Mat['Yeo_7system'];
FP_Index = np.where(Yeo_Index==6);
DM_Index = np.where(Yeo_Index==7);
FPDM_Index = np.concatenate([FP_Index[0], DM_Index[0]]);

ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction';
CZ_ElasticNet_2.ElasticNet_KFold(Energy, OverallAccuracy, 0.5, 10, 1, ResultantFolder, 3, 0);

sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/Lasso');
import Lasso_CZ_Sort_2
Corr, MAE = Lasso_CZ_Sort_2.Lasso_KFold_Sort(Energy, OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);

sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_2
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy, OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy[:,FPDM_Index], OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy_YeoAvg, OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);

sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/LeastSquares');
import LeastSquares_CZ_Sort_2
LeastSquares_CZ_Sort_2.LinearRegression_KFold(Energy_WholeBrainAvg, OverallAccuracy, 10, ResultantFolder);
