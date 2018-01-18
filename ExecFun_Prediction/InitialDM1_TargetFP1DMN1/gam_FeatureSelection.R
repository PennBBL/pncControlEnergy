
library(R.matlab);
library(mgcv);

Energy_Data_Folder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetFP1DMN1.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

Behavior <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);

Tissue <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
Behavior$TBV <- as.numeric(Tissue$TBV);

Cognition <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n949_cnb_factor_scores_tymoore_20151006.mat');
Behavior$OverallAccuracy <- Cognition$OverallAccuracy;

NANIndex = as.matrix(which(!is.na(Behavior$OverallAccuracy)));
Behavior_New <- data.frame(Age_years = Behavior$Age_years[NANIndex]);
Behavior_New$Sex_factor <- Behavior$Sex_factor[NANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NANIndex];
Behavior_New$TBV <- Behavior$TBV[NANIndex];
Behavior_New$OverallAccuracy <- Behavior$OverallAccuracy[NANIndex];

Energy <- Energy[NANIndex,];
Energy_YeoAvg <- Energy_YeoAvg[NANIndex,];

ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/FeatureSelection';

# Split training samples and test samples
TrainingIndex <- c(1:500);
TestingIndex <- c(501:947);
Energy_training <- Energy[TrainingIndex,];
Energy_testing <- Energy[TestingIndex,];
Behavior_New_training <- data.frame(Age_years = Behavior_Nevior_New$Age_years[TrainingIndex,]);
Behavior_New_training$Sex_factor <- Behavior_New$Sex_factor[TrainingIndex];
Behavior_New_training$HandednessV2 <- Behavior_New$HandednessV2[TrainingIndex];
Behavior_New_training$MotionMeanRelRMS <- Behavior_New$MotionMeanRelRMS[TrainingIndex];
Behavior_New_training$TBV <- Behavior_New$TBV[TrainingIndex];
Behavior_New_training$OverallAccuracy <- Behavior_New$OverallAccuracy[TrainingIndex];
Age_years <- Behavior_New$Age_years[TestingIndex,];
Sex_factor <- Behavior_New$Sex_factor[TestingIndex,];
HandednessV2 <- Behavior_New$HandednessV2[TestingIndex,];
MotionMeanRelRMS <- Behavior_New$MotionMeanRelRMS[TestingIndex,];
TBV <- Behavior_New$TBV[TestingIndex,];
OverallAccuracy <- Behavior_New$OverallAccuracy[TestingIndex,];
writeMat(file.path(ResultantFolder, 'testData.mat'), Energy_testing = Energy_testing, Age_years = Age_years, Sex_factor = Sex_factor, HandednessV2 = HandednessV2, MotionMeanRelRMS = MotionMeanRelRMS, TBV = TBV, OverallAccuracy = OverallAccuracy);

# Relationship between cognition and nodal energy
dimension <- dim(Energy);
RegionsQuantity <- dimension[2];
RowName <- character(length = RegionsQuantity);
for (i in 1:RegionsQuantity)
{
  RowName[i] = paste("Node", as.character(i));
}
ColName <- c("Z", "P", "P_FDR", "P_Bonf");
Energy_Gam_Cognition <- matrix(c(1:RegionsQuantity*4), nrow = RegionsQuantity, ncol = 4, dimnames = list(RowName, ColName));
Energy_Gam_CogSexInter <- matrix(c(1:RegionsQuantity*4), nrow = RegionsQuantity, ncol = 4, dimnames = list(RowName, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  # correlation between whole brain average energy and cognition
  Energy_Gam <- gam(Energy_training ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New_training);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition[, 4] <- p.adjust(Energy_Gam_Cognition[, 2], "bonferroni");
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_Cognition.csv');
write.csv(Energy_Gam_Cognition, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_Cognition.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition[, 1], Cognition_P = Energy_Gam_Cognition[, 2], Cognition_P_FDR = Energy_Gam_Cognition[, 3], Cognition_P_Bonf = Energy_Gam_Cognition[, 4]);
