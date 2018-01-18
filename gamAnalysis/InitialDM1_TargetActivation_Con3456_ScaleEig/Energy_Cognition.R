
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

Energy_Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetActi_Con3456_ScaleEig.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

Behavior <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);

Tissue <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
Behavior$TBV <- as.numeric(Tissue$TBV);

Cognition <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_cnb_factor_scores_tymoore_20151006.mat');
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

# Analysis of the whole brain average energy
Index <- which(Energy[1,] != 0);
WholeBrainAvg <- rowMeans(Energy[,Index]);
WholeBrainAvg <- WholeBrainAvg[NANIndex];
# correlation between whole brain average energy and cognition
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "OverallAccuracy", xlab = "Cognition", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# Bootstrap
Subjects_ID <- c(1:947);
PValue_Bootstrap = matrix(0, 1000, 1);
for (i in 1:1000)
{
  print(i);
  Sample_Index <- sample(Subjects_ID, 947, replace = TRUE);
  WholeBrainAvg_Bootstrap <- WholeBrainAvg[Sample_Index]; 
  Behavior_Bootstrap <- data.frame(Sex_factor = Behavior_New$Sex_factor[Sample_Index]);
  Behavior_Bootstrap$Age_years <- Behavior_New$Age_years[Sample_Index];
  Behavior_Bootstrap$HandednessV2 <- Behavior_New$HandednessV2[Sample_Index];
  Behavior_Bootstrap$MotionMeanRelRMS <- Behavior_New$MotionMeanRelRMS[Sample_Index];
  Behavior_Bootstrap$TBV <- Behavior_New$TBV[Sample_Index];
  Behavior_Bootstrap$OverallAccuracy <- Behavior_New$OverallAccuracy[Sample_Index];
  Gam_WholeBrainAvg_Bootstrap <- gam(WholeBrainAvg_Bootstrap ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_Bootstrap);
  PValue_Bootstrap[i] = summary(Gam_WholeBrainAvg_Bootstrap)$p.pv[2];
}
# interaction with sex
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + OverallAccuracy * Sex_order + OverallAccuracy + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

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
  tmp_variable <- Energy[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
  # interaction with sex
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k = 4) + OverallAccuracy * Sex_order + OverallAccuracy + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  Energy_Gam_CogSexInter[i, 1] <- summary(Energy_Gam)$p.t[8];
  Energy_Gam_CogSexInter[i, 2] <- summary(Energy_Gam)$p.pv[8];
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition[, 4] <- p.adjust(Energy_Gam_Cognition[, 2], "bonferroni");
Energy_Gam_CogSexInter[, 3] <- p.adjust(Energy_Gam_CogSexInter[, 2], "fdr");
Energy_Gam_CogSexInter[, 4] <- p.adjust(Energy_Gam_CogSexInter[, 2], "bonferroni");
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/Cognition_Effects/NodalLevel';
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_Cognition.csv');
write.csv(Energy_Gam_Cognition, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_Cognition.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition[, 1], Cognition_P = Energy_Gam_Cognition[, 2], Cognition_P_FDR = Energy_Gam_Cognition[, 3], Cognition_P_Bonf = Energy_Gam_Cognition[, 4]);
Energy_Gam_CogSexInter_CSV <- file.path(ResultantFolder, 'Energy_Gam_CogSexInter.csv');
write.csv(Energy_Gam_CogSexInter, Energy_Gam_CogSexInter_CSV);
Energy_Gam_CogSexInter_Mat <- file.path(ResultantFolder, 'Energy_Gam_CogSexInter.mat');
writeMat(Energy_Gam_CogSexInter_Mat, CogSexInter_Z = Energy_Gam_CogSexInter[, 1], CogSexInter_P = Energy_Gam_CogSexInter[, 2], CogSexInter_P_FDR = Energy_Gam_CogSexInter[, 3], CogSexInter_P_Bonf = Energy_Gam_CogSexInter[, 4]);

# Cognition and interaction effect on yeo system average energy
SystemsQuantity = 8;
RowName = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*4), nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName, ColName));
Energy_Gam_CogSexInter_YeoAvg <- matrix(c(1:SystemsQuantity*4), nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName, ColName));
for (i in 1:SystemsQuantity)
{
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];  
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
  # interaction with sex
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k = 4) + OverallAccuracy * Sex_order + OverallAccuracy + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  Energy_Gam_CogSexInter_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[8];
  Energy_Gam_CogSexInter_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[8];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
Energy_Gam_Cognition_YeoAvg[, 4] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "bonferroni");
Energy_Gam_CogSexInter_YeoAvg[, 3] <- p.adjust(Energy_Gam_CogSexInter_YeoAvg[, 2], "fdr");
Energy_Gam_CogSexInter_YeoAvg[, 4] <- p.adjust(Energy_Gam_CogSexInter_YeoAvg[, 2], "bonferroni");
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/Cognition_Effects/YeoSystemLevel';
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_Cognition_YeoAvg.csv');
write.csv(Energy_Gam_Cognition_YeoAvg, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_Cognition_YeoAvg.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3], Cognition_P_Bonf = Energy_Gam_Cognition_YeoAvg[, 4]);
Energy_Gam_CogSexInter_CSV <- file.path(ResultantFolder, 'Energy_Gam_CogSexInter_YeoAvg.csv');
write.csv(Energy_Gam_CogSexInter_YeoAvg, Energy_Gam_CogSexInter_CSV);
Energy_Gam_CogSexInter_Mat <- file.path(ResultantFolder, 'Energy_Gam_CogSexInter_YeoAvg.mat');
writeMat(Energy_Gam_CogSexInter_Mat, CogSexInter_Z = Energy_Gam_CogSexInter_YeoAvg[, 1], CogSexInter_P = Energy_Gam_CogSexInter_YeoAvg[, 2], CogSexInter_P_FDR = Energy_Gam_CogSexInter_YeoAvg[, 3], CogSexInter_P_Bonf = Energy_Gam_CogSexInter_YeoAvg[, 4]);


