
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication/9th_PredictAge');
import Ridge_CZ_Sort

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/Age_Prediction';
# Import data
Data_Mat = sio.loadmat(DataFolder + '/Energy_Behavior_AllSubjects.mat');
Energy = Data_Mat['Energy'];
Age = Data_Mat['Age'];
Age = np.transpose(Age);
Covariates = np.zeros((946, 5));
Covariates[:,0] = Data_Mat['Sex'];
Covariates[:,1] = Data_Mat['HandednessV2'];
Covariates[:,2] = Data_Mat['MotionMeanRelRMS'];
Covariates[:,3] = Data_Mat['TBV'];
Covariates[:,4] = np.transpose(Data_Mat['Strength_EigNorm_SubIden'])[0];
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

FoldQuantity = 2;

ResultantFolder = ReplicationFolder + '/results/Age_Prediction/2Fold_Sort';
Ridge_CZ_Sort.Ridge_KFold_Sort(Energy, Age, Covariates, FoldQuantity, Alpha_Range, ResultantFolder, 1, 0);

# Permutation test, 1,000 times
Times_IDRange = np.arange(1000);
ResultantFolder = ReplicationFolder + '/results/Age_Prediction/2Fold_Sort_Permutation';
Ridge_CZ_Sort.Ridge_KFold_Sort_Permutation(Energy, Age, Covariates, Times_IDRange, FoldQuantity, Alpha_Range, ResultantFolder, 1, 1000, '-q all.q')
