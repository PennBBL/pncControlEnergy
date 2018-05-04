
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication_20180418/8th_PredictAge');
import Ridge_CZ_Sort_Energy

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/AgePrediction';
# Import sample 1
Energy_Sample1_Mat = sio.loadmat(DataFolder + '/volNormSC_Energy/Energy_Sample1.mat');
Energy_Sample1 = Energy_Sample1_Mat['Energy_Sample1'];
Age_Sample1_Mat = sio.loadmat(DataFolder + '/Age_Sample1.mat');
Age_Sample1 = Age_Sample1_Mat['Age_Sample1'];
Age_Sample1 = np.transpose(Age_Sample1);
Age_Sample1 = Age_Sample1[0];
# Import sample 2
Energy_Sample2_Mat = sio.loadmat(DataFolder + '/volNormSC_Energy/Energy_Sample2.mat');
Energy_Sample2 = Energy_Sample2_Mat['Energy_Sample2'];
Age_Sample2_Mat = sio.loadmat(DataFolder + '/Age_Sample2.mat');
Age_Sample2 = Age_Sample2_Mat['Age_Sample2'];
Age_Sample2 = np.transpose(Age_Sample2);
Age_Sample2 = Age_Sample2[0];
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

########################################
## Using sample 1 to predict sample 2 ##
########################################
ResultantFolder = ReplicationFolder + '/results/volNormSC_Energy/Age_Prediction/Sample1_Predict_Sample2';
#Ridge_CZ_Sort_Energy.Ridge_APredictB(Energy_Sample1, Age_Sample1, Energy_Sample2, Age_Sample2, Alpha_Range, 5, ResultantFolder);
# Permutation test
# Shuffle the age of sample1 1,000 times to train 1,000 random models
ResultantFolder = ReplicationFolder + '/results/volNormSC_Energy/Age_Prediction/Sample1_Predict_Sample2_Permutation';
Ridge_CZ_Sort_Energy.Ridge_APredictB_Permutation(Energy_Sample1, Age_Sample1, Energy_Sample2, Age_Sample2, np.arange(1000), Alpha_Range, 5, ResultantFolder, 1000, '-q all.q')

########################################
## Using sample 2 to predict sample 1 ##
########################################
ResultantFolder = ReplicationFolder + '/results/volNormSC_Energy/Age_Prediction/Sample2_Predict_Sample1';
#Ridge_CZ_Sort_Energy.Ridge_APredictB(Energy_Sample2, Age_Sample2, Energy_Sample1, Age_Sample1, Alpha_Range, 5, ResultantFolder);
# Permutation test
# Shuffle the age of sample2 1,000 times to train 1,000 random models
ResultantFolder = ReplicationFolder + '/results/volNormSC_Energy/Age_Prediction/Sample2_Predict_Sample1_Permutation';
Ridge_CZ_Sort_Energy.Ridge_APredictB_Permutation(Energy_Sample2, Age_Sample2, Energy_Sample1, Age_Sample1, np.arange(1000), Alpha_Range, 5, ResultantFolder, 1000, '-q all.q')
