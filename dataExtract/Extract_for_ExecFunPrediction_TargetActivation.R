
library(R.matlab);

Energy_Data_Folder <- '/Users/zaixucui/Documents/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetActivation.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

Behavior <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Scan_ID <- Behavior$Scan.ID.SC
Age_years <- Behavior$Age/12;
Sex <- Behavior$Sex;
Race <- Behavior$Race;
Race2 <- Behavior$Race2;
HandednessV2 <- Behavior$HandednessV2;
MotionMeanRelRMS <- Behavior$MotionMeanRelRMS;

Tissue <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
TBV <- Tissue$TBV;

Cognition <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_cnb_factor_scores_tymoore_20151006.mat');
OverallAccuracy <- Cognition$OverallAccuracy;

NANIndex <- as.matrix(which(!is.na(OverallAccuracy)));
Scan_ID <- Scan_ID[NANIndex];
Age_years <- Age_years[NANIndex];
Sex <- Sex[NANIndex];
Race <- Race[NANIndex];
Race2 <- Race2[NANIndex];
HandednessV2 <- HandednessV2[NANIndex];
MotionMeanRelRMS <- MotionMeanRelRMS[NANIndex];
TBV <- TBV[NANIndex];
OverallAccuracy <- OverallAccuracy[NANIndex];
ResultantFolder <- '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
writeMat(file.path(ResultantFolder, 'Behavior.mat'), Scan_ID = Scan_ID, Age_years = Age_years, Sex = Sex, Race = Race, Race2 = Race2, HandednessV2 = HandednessV2, MotionMeanRelRMS = MotionMeanRelRMS, TBV = TBV, OverallAccuracy = OverallAccuracy);
Energy <- Energy[NANIndex, ];
Energy_YeoAvg <- Energy_YeoAvg[NANIndex, ];
writeMat(file.path(ResultantFolder, 'Energy.mat'), Energy = Energy);
writeMat(file.path(ResultantFolder, 'Energy_YeoAvg.mat'), Energy_YeoAvg = Energy_YeoAvg);

