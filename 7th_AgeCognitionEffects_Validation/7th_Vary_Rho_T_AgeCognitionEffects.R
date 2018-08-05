
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication_Prob';

# Import behavior
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n946_Behavior_20180712.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$AgeYears <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of the network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/WholeBrainStrength_Prob_946.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetMeanActivation');
Energy_Data_Folder = paste0(ReplicationFolder, '/data/energyData');
Parameters <- c(0.1, 0.2, 0.5, 0.8, 2, 5, 8, 10);

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
  Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

  ColName <- c("Z", "P", "P_FDR");
  # Age effect at whole-brain average level
  Energy_WholeBrainAvg <- rowMeans(Energy);
  Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_lm_WholeBrainAvg <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  P_Value = summary(Energy_Gam_WholeBrainAvg)$s.table[, 4];
  if (summary(Energy_lm_WholeBrainAvg)$coefficients[2,3] < 0) {
    Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE);
  }  else {
    Z_Value = qnorm(P_Value / 2, lower.tail=FALSE);
  }
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_WholeBrainLevel_T_', Para_Str, '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Z_Value, Age_P = P_Value);
  print(Z_Value)

  # Age effect at Yeo system average level
  print('###### Age effect of energy at Yeo system level ######');
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  {
    tmp_variable <- Energy_YeoAvg[, j];
    Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age_YeoAvg[j, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age_YeoAvg[j, 1] <- qnorm(Energy_Gam_Age_YeoAvg[j, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
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
  Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

  ColName <- c("Z", "P", "P_FDR");
  # Age effect at whole-brain average level
  Energy_WholeBrainAvg <- rowMeans(Energy);
  Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_lm_WholeBrainAvg <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  P_Value = summary(Energy_Gam_WholeBrainAvg)$s.table[, 4];
  if (summary(Energy_lm_WholeBrainAvg)$coefficients[2,3] < 0) {
    Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE);
  }  else {
    Z_Value = qnorm(P_Value / 2, lower.tail=FALSE);
  }
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_WholeBrainLevel_rho_', Para_Str, '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Z_Value, Age_P = P_Value);
  print(Z_Value)

  # Yeo system average level (age effect)
  print('###### Age effect of energy at Yeo system level ######');
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  {
    tmp_variable <- Energy_YeoAvg[, j];
    Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age_YeoAvg[j, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age_YeoAvg[j, 1] <- qnorm(Energy_Gam_Age_YeoAvg[j, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
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
} 

