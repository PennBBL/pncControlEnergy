
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication_20180418/8th_PredictAge');
import Ridge_CZ_Sort_Energy

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/AgePrediction';
# Import all samples
Energy_Mat = sio.loadmat(DataFolder + '/FA_Energy/Energy.mat');
Energy = Energy_Mat['Energy'];
Age_Mat = sio.loadmat(DataFolder + '/Age.mat');
Age = Age_Mat['Age'];
Age = np.transpose(Age);
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

ResultantFolder = ReplicationFolder + '/results/FA_Energy/Age_Prediction/Weight';
Ridge_CZ_Sort_Energy.Ridge_Weight(Energy, Age, 1, 2, Alpha_Range, ResultantFolder, 1)



