
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication_20180522/8th_PredictAge');
import Ridge_CZ_Sort_Energy

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/AgePrediction';
# Import data
Data_Mat = sio.loadmat(DataFolder + '/Energy_FA_AllSubjects.mat');
Energy = Data_Mat['Energy'];
Age = Data_Mat['Age'];
Age = np.transpose(Age);
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

FoldQuantity = 2;

ResultantFolder = ReplicationFolder + '/results/FA_Energy/Age_Prediction/2Fold';
Ridge_CZ_Sort_Energy.Ridge_KFold_Sort(Energy, Age, FoldQuantity, Alpha_Range, ResultantFolder, 1, 0);

