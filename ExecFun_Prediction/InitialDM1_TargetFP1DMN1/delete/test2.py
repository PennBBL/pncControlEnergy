
import scipy.io as sio
import numpy as np
import os
import sys
from sklearn import linear_model
from sklearn import preprocessing

DataFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/gamFeatureSelection';
TrainData_Mat = sio.loadmat(DataFolder + '/trainData.mat');
Energy_training = TrainData_Mat['Energy_training'];
OverallAcc_training = TrainData_Mat['OverallAccuracy'];

TestData_Mat = sio.loadmat(DataFolder + '/testData.mat');
Energy_testing = TestData_Mat['Energy_testing'];
OverallAcc_testing = TestData_Mat['OverallAccuracy'];

Gam_Mat = sio.loadmat(DataFolder + '/Energy_Gam_Cognition.mat');
Cognition_P = Gam_Mat['Cognition_P'];
Cognition_P_FDR = Gam_Mat['Cognition_P_FDR'];
#SigIndex = np.where(Cognition_P < 0.05);
#SigIndex = np.where(Cognition_P_FDR < 0.05);
SigIndex = np.where(Gam_Mat['Cognition_P_Bonf'] < 0.05);
SigIndex = SigIndex[0];

Energy_training_2 = Energy_training[:, SigIndex];
Energy_testing_2 = Energy_testing[:, SigIndex];

normalize = preprocessing.MinMaxScaler();
Energy_training_2 = normalize.fit_transform(Energy_training_2);
Energy_testing_2 = normalize.transform(Energy_testing_2);
clf = linear_model.Ridge(alpha = 1);
clf.fit(Energy_training_2, OverallAcc_training);
predict_score = clf.predict(Energy_testing_2);
Corr = np.corrcoef(predict_score, OverallAcc_testing);

sys.path.append('/data/joy/BBL/projects/pncControlEnergy/scripts/Utilities_Regression/Ridge');
import Ridge_CZ_Sort_2
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy, OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy[:,FPDM_Index], OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);
Corr, MAE = Ridge_CZ_Sort_2.Ridge_KFold_Sort(Energy_YeoAvg, OverallAccuracy, 10, np.exp2(np.arange(16) - 10), ResultantFolder, 5);

