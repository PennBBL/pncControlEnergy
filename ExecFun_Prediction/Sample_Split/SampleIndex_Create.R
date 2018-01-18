

library('R.matlab')
library('caret')
set.seed(1234)
DataFolder = '/Users/zaixucui/Documents/Projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
Behavior <- readMat(paste(DataFolder, '/Behavior.mat', sep = ''))
Sample1_Index <- createDataPartition(Behavior$OverallAccuracy, p = 0.667, list =F,times=1)
All_Index <- c(1:length(Behavior$OverallAccuracy));
Sample2_Index <- All_Index[-Sample1_Index]
writeMat(paste(DataFolder, '/SampleIndex.mat', sep = ''), Sample1_Index = Sample1_Index, Sample2_Index = Sample2_Index);
