
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

# Import behavior
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n949_Behavior_20180522.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of the network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/WholeBrainStrength_FA_949.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

# Executive function performance
F1_Exec_Comp_Res_Accuracy <- AllInfo$F1_Exec_Comp_Res_Accuracy;
nbackBehAllDprime <- AllInfo$nbackBehAllDprime;
NonNANIndex <- which(!is.na(F1_Exec_Comp_Res_Accuracy));
Behavior_New <- data.frame(Sex_factor = Behavior$Sex_factor[NonNANIndex])
Behavior_New$Age_years <- Behavior$Age_years[NonNANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_New$TBV <- Behavior$TBV[NonNANIndex];
F1_Exec_Comp_Res_Accuracy <- F1_Exec_Comp_Res_Accuracy[NonNANIndex];
nbackBehAllDprime <- nbackBehAllDprime[NonNANIndex];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetMeanActivation_SmallerThanNull');
Energy_Data_Folder = paste0(ReplicationFolder, '/data/energyData');
Parameters <- c(0.1, 0.2, 0.5, 0.8, 2, 5, 8, 10);

Index <- readMat(paste0(ReplicationFolder, '/data/SmallerThanNull_Index.mat'));
SmallerThanNull_Index <- Index$SmallerThanNull.Index;

Yeo_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7Systems <- Yeo_Mat$Yeo.7system;

########################
### Vary T parameter ###
########################
for (i in c(1:8))
{
  Para_Str <- as.character(Parameters[i]);
  print(paste0('###### T = ', Para_Str, ' ######'));
  if (i < 5){
    Para_Str <- paste0(substr(Para_Str, 1, 1), substr(Para_Str, 3, 3));
  }
  Energy_Mat_Path <- paste0(Energy_Data_Folder, '/InitialAll0_TargetActivationMean_T_', Para_Str, '.mat');
  Energy_Mat <- readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;

  Energy_YeoAvg <- matrix(0, 949, 8);
  for (i in 1:8)
  {
    System_I_Index <- intersect(which(Yeo_7Systems == i), SmallerThanNull_Index);
    Energy_YeoAvg[, i] <- rowMeans(Energy[, System_I_Index]);
  }

  ColName <- c("Z", "P", "P_FDR");
  # Age effect at Yeo system average level
  print('###### Age effect of energy at Yeo system level ######');
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  {
    tmp_variable <- Energy_YeoAvg[, j];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age_YeoAvg[j, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age_YeoAvg[j, 1] <- qnorm(Energy_Gam_Age_YeoAvg[j, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age_YeoAvg[j, 1] = -Energy_Gam_Age_YeoAvg[j, 1];
    }
  }
  Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_T_', Para_Str, '.csv'));
  write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_T_', Para_Str, '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);
  print(Energy_Gam_Age_YeoAvg);

  # Cognition effect at Yeo system average level
  print('###### Cognition effect of energy at Yeo system level ######');
  Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  {
    tmp_variable <- Energy_YeoAvg[, j];
    tmp_variable <- tmp_variable[NonNANIndex];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + nbackBehAllDprime + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
    Energy_Gam_Cognition_YeoAvg[j, 1] <- summary(Energy_Gam)$p.t[2];
    Energy_Gam_Cognition_YeoAvg[j, 2] <- summary(Energy_Gam)$p.pv[2];
  }
  Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
  Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_YeoSystemLevel_T_', Para_Str, '.csv'));
  write.csv(Energy_Gam_Cognition_YeoAvg, Energy_Gam_Cognition_CSV);
  Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_YeoSystemLevel_T_', Para_Str, '.mat'));
  writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);
  print(Energy_Gam_Cognition_YeoAvg)
}

##########################
### Vary rho parameter ###
##########################
for (i in c(1:8))
{
  Para_Str <- as.character(Parameters[i]);
  print(paste0('###### rho = ', Para_Str, ' ######'));
  if (i < 5){
    Para_Str <- paste0(substr(Para_Str, 1, 1), substr(Para_Str, 3, 3));
  }
  Energy_Mat_Path <- paste0(Energy_Data_Folder, '/InitialAll0_TargetActivationMean_rho_', Para_Str, '.mat');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;

  Energy_YeoAvg <- matrix(0, 949, 8);
  for (i in 1:8)
  {
    System_I_Index <- intersect(which(Yeo_7Systems == i), SmallerThanNull_Index);
    Energy_YeoAvg[, i] <- rowMeans(Energy[, System_I_Index]);
  }

  ColName <- c("Z", "P", "P_FDR");
  # Yeo system average level (age effect)
  print('###### Age effect of energy at Yeo system level ######');
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  {
    tmp_variable <- Energy_YeoAvg[, j];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age_YeoAvg[j, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age_YeoAvg[j, 1] <- qnorm(Energy_Gam_Age_YeoAvg[j, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age_YeoAvg[j, 1] = -Energy_Gam_Age_YeoAvg[j, 1];
    }
  }
  Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_rho_', Para_Str, '.csv'));
  write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_rho_', Para_Str, '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);  
  print(Energy_Gam_Age_YeoAvg);
  # Cognition effect at Yeo system average level
  print('###### Cognition effect of energy at Yeo system level ######');
  Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  { 
    tmp_variable <- Energy_YeoAvg[, j];
    tmp_variable <- tmp_variable[NonNANIndex];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + nbackBehAllDprime + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
    Energy_Gam_Cognition_YeoAvg[j, 1] <- summary(Energy_Gam)$p.t[2];
    Energy_Gam_Cognition_YeoAvg[j, 2] <- summary(Energy_Gam)$p.pv[2];
  }
  Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
  Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_YeoSystemLevel_rho_', Para_Str, '.csv'));
  write.csv(Energy_Gam_Cognition_YeoAvg, Energy_Gam_Cognition_CSV);
  Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_YeoSystemLevel_rho_', Para_Str, '.mat'));
  writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);
  print(Energy_Gam_Cognition_YeoAvg)
} 

