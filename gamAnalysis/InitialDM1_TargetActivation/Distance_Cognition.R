
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

Energy_Data_Folder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetActivation.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Distance <- rowSums(Energy_Mat$Distance[,501:1001]);

Behavior <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);

Tissue <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
Behavior$TBV <- as.numeric(Tissue$TBV);

Cognition <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_cnb_factor_scores_tymoore_20151006.mat');
Behavior$OverallAccuracy <- Cognition$OverallAccuracy;
Behavior$OverallAccuracyAr <- Cognition$OverallAccuracyAr;

NANIndex = as.matrix(which(!is.na(Behavior$OverallAccuracy)));
Behavior_New <- data.frame(Age_years = Behavior$Age_years[NANIndex]);
Behavior_New$Sex_factor <- Behavior$Sex_factor[NANIndex];
Behavior_New$Sex_order <- Behavior$Sex_order[NANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NANIndex];
Behavior_New$TBV <- Behavior$TBV[NANIndex];
Behavior_New$OverallAccuracy <- Behavior$OverallAccuracy[NANIndex];
Behavior_New$OverallAccuracyAr <- Behavior$OverallAccuracyAr[NANIndex];

Distance <- Distance[NANIndex];
Gam_Distance <- gam(Distance ~ s(Age_years, k = 4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_Distance, "OverallAccuracy", xlab = "Cognition", ylab = "Distance", gg = TRUE) + theme(text=element_text(size=20));
# interaction with sex
Gam_Distance <- gam(Distance ~ s(Age_years, k = 4) + OverallAccuracy * Sex_order + OverallAccuracy + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

