
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

# Demographics, motion, TBV
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n946_Behavior_20180807.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$AgeYears <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of FA-weighted network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/WholeBrainStrength_Prob_946.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetFP_NullNetworks');
if (!dir.exists(ResultantFolder))
{
  dir.create(ResultantFolder, recursive = TRUE);
}
Energy_Data_Folder = paste0(ReplicationFolder, '/data/energyData');

#################
### Age effects #
#################
for (i in c(1:100))
{
  Energy_Mat_Path <- paste0(Energy_Data_Folder, '/NullNetworks/InitialAll0_TargetFP_NullNetwork_', as.character(i), '.mat');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;
  Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

  # Age effect at whole-brain level
  Energy_WholeBrainAvg <- rowMeans(Energy);
  Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_lm_WholeBrainAvg <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  P_Value = summary(Energy_Gam_WholeBrainAvg)$s.table[, 4];
  if (summary(Energy_lm_WholeBrainAvg)$coefficients[2,3] < 0) {
    Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE);
  }  else {
    Z_Value = qnorm(P_Value / 2, lower.tail=FALSE);
  }
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_WholeBrainLevel_NullNetwork_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Z_Value, Age_P = P_Value);
  print(Z_Value)

  ColName <- c("Z", "P", "P_FDR");
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
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_NullNetwork_', as.character(i), '.csv'));
  write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_NullNetwork_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);
  print(Energy_Gam_Age_YeoAvg);

  # Age effect at nodal level
  print('###### Age effect of energy at nodal level ######');
  Energy_Gam_Age <- matrix(0, 232, 3);
  for (j in 1:232)
  { 
    tmp_variable <- Energy[, j];
    # Gam analysis was used for age effect
    Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age[j, 2] <- summary(Energy_Gam)$s.table[, 4];
    # Covert P value to Z value
    Energy_Gam_Age[j, 1] <- qnorm(Energy_Gam_Age[j, 2] / 2, lower.tail=FALSE);
    # Linear model was used to test whether it is a positive or negative relationship
    Energy_lm <- lm(tmp_variable ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age[j, 1] = -Energy_Gam_Age[j, 1];
    }
  }
  Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
  # Write the results to a new matrix with 233 rows, set the values of 192th row as 1
  RowName_Nodal_233 <- character(length = 233);
  for (j in 1:233)
  {
    RowName_Nodal_233[j] = paste("Node", as.character(j));
  }
  Energy_Gam_Age_New <- matrix(1, nrow = 233, ncol = 3, dimnames = list(RowName_Nodal_233, ColName));
  Energy_Gam_Age_New[c(1:191, 193:233), ] = Energy_Gam_Age;
  # Storing the results in both .csv and .mat file
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Age_NodalLevel_NullNetwork_', as.character(i), '.csv'));
  write.csv(Energy_Gam_Age_New, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_NodalLevel_NullNetwork_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_New[, 1], Age_P = Energy_Gam_Age_New[, 2], Age_P_FDR = Energy_Gam_Age_New[, 3]);
}

#########################
### Cognition effects ###
#########################
NonNANIndex <- which(!is.na(AllInfo$F3_Executive_Efficiency));
Behavior_Cognition <- data.frame(ExecutiveEfficiency = as.numeric(AllInfo$F3_Executive_Efficiency[NonNANIndex]));
Behavior_Cognition$AgeYears <- Behavior$AgeYears[NonNANIndex];
Behavior_Cognition$Sex_factor <- Behavior$Sex_factor[NonNANIndex];
Behavior_Cognition$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_Cognition$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_Cognition$TBV <- Behavior$TBV[NonNANIndex];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];
for (i in c(1:100))
{
  Energy_Mat_Path <- paste0(Energy_Data_Folder, '/NullNetworks/InitialAll0_TargetFP_NullNetwork_', as.character(i), '.mat');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;
  Energy_Cognition <- Energy[NonNANIndex,];
  
  print('###### Cognition effect of energy at nodal level ######');
  Energy_Gam_Cognition <- matrix(0, 232, 3);
  for (j in 1:232)
  {
    tmp_variable <- Energy_Cognition[, j];
    # Gam analysis was used for age effect
    Energy_Gam <- gam(tmp_variable ~ ExecutiveEfficiency + s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_Cognition);
    Energy_Gam_Cognition[j, 1] <- summary(Energy_Gam)$p.table[2, 3];
    Energy_Gam_Cognition[j, 2] <- summary(Energy_Gam)$p.table[2, 4];
  }
  Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
  # Write the results to a new matrix with 233 rows, set the values of 192th row as 1
  RowName_Nodal_233 <- character(length = 233);
  for (j in 1:233)
  {
    RowName_Nodal_233[j] = paste("Node", as.character(i));
  }
  Energy_Gam_Cognition_New <- matrix(1, nrow = 233, ncol = 3, dimnames = list(RowName_Nodal_233, c("Z", "P", "P_FDR")));
  Energy_Gam_Cognition_New[c(1:191, 193:233), ] = Energy_Gam_Cognition;
  # Storing the results in both .csv and .mat file
  Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_NodalLevel_NullNetwork_', as.character(i), '.csv'));
  write.csv(Energy_Gam_Cognition_New, Energy_Gam_Cognition_CSV);
  Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_NodalLevel_NullNetwork_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_New[, 1], Cognition_P = Energy_Gam_Cognition_New[, 2], Cognition_P_FDR = Energy_Gam_Cognition_New[, 3]);
  print(paste('Resultant file is ', Energy_Gam_Cognition_Mat, sep = ''));
}
