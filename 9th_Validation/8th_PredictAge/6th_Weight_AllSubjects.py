
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication_20180418/8th_PredictAge');
import Ridge_CZ_Sort_Energy

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/AgePrediction';
# Import all samples
Energy_Mat = sio.loadmat(DataFolder + '/volNormSC_Energy/Energy.mat');
Energy = Energy_Mat['Energy'];
Age_Mat = sio.loadmat(DataFolder + '/Age_AllSubjects.mat');
Age = Age_Mat['Age_AllSubjects'];
Age = np.transpose(Age);
Age = Age[0];
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

ResultantFolder = ReplicationFolder + '/results/volNormSC_Energy/Age_Prediction/Weight';
Ridge_CZ_Sort_Energy.Ridge_Weight(Energy, Age, 1, 5, Alpha_Range, ResultantFolder, 1)



