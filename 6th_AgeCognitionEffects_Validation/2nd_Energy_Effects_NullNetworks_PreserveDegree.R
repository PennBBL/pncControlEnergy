
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

# Demographics, motion, TBV
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n949_Behavior_20180522.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of FA-weighted network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/WholeBrainStrength_FA_949.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

# In-scanner nback task performance
nbackBehAllDprime <- AllInfo$nbackBehAllDprime;
NonNANIndex <- which(!is.na(nbackBehAllDprime));
Behavior_New <- data.frame(Sex_factor = Behavior$Sex_factor[NonNANIndex])
Behavior_New$Age_years <- Behavior$Age_years[NonNANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_New$TBV <- Behavior$TBV[NonNANIndex];
Behavior_New$Strength_EigNorm_SubIden <- Behavior$Strength_EigNorm_SubIden[NonNANIndex];
Behavior_New$nbackBehAllDprime <- nbackBehAllDprime[NonNANIndex];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetMeanActivation_NullNetworks_PreservingDegree');
if (!dir.exists(ResultantFolder))
{
  dir.create(ResultantFolder, recursive = TRUE);
}
Energy_Data_Folder = paste0(ReplicationFolder, '/data/energyData');

#########################
###   Null networks   ###
#########################
for (i in c(1:100))
{
  Energy_Mat_Path <- paste0(Energy_Data_Folder, '/NullNetworks_PreservingDegree/InitialAll0_TargetActivationMean_NullNetwork_', as.character(i), '.mat');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy.New;
  Energy_YeoAvg <- Energy_Mat$Energy.New.YeoAvg;
  Energy_YeoAvg_Cognition <- Energy_YeoAvg[NonNANIndex,];
  ColName <- c("Z", "P", "P_FDR");
  
  # Age effect at nodal level
  dimension <- dim(Energy);
  RegionsQuantity <- dimension[2];
  RowName_Nodal <- character(length = RegionsQuantity);
  for (j in 1:RegionsQuantity)
  { 
    RowName_Nodal[j] = paste("Node", as.character(j));
  }
  Energy_Gam_Age <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
  for (j in 1:RegionsQuantity)
  { 
    tmp_variable <- Energy[, j];
    # Gam analysis was used for age effect
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age[j, 2] <- summary(Energy_Gam)$s.table[, 4];
    # Covert P value to Z value
    Energy_Gam_Age[j, 1] <- qnorm(Energy_Gam_Age[j, 2] / 2, lower.tail=FALSE);
    # Linear model was used to test whether it is a positive or negative relationship
    Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age[j, 1] = -Energy_Gam_Age[j, 1];
    }
  }
  Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
  # Storing the results in both .csv and .mat file
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Age_NodalLevel_NullNetwork_', as.character(i), '.csv'));
  write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_NodalLevel_NullNetwork_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3]);
  
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
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_NullNetwork_', as.character(i), '.csv'));
  write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_NullNetwork_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);
  print(Energy_Gam_Age_YeoAvg);

  #####################################################
  # 3. Cognition effect of energy at Yeo system level #
  #####################################################
  print('###### Cognition effect of energy at Yeo system level ######');
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  {
    tmp_variable <- Energy_YeoAvg_Cognition[, j];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + nbackBehAllDprime + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
    Energy_Gam_Cognition_YeoAvg[j, 1] <- summary(Energy_Gam)$p.t[2];
    Energy_Gam_Cognition_YeoAvg[j, 2] <- summary(Energy_Gam)$p.pv[2];
  }
  Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
  print(Energy_Gam_Cognition_YeoAvg); # print the results, somatomotor, ventral attention, default mode and subcortical were significant
  Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_YeoSystemLevel_NullNetwork_', as.character(i), '.csv'));
  write.csv(Energy_Gam_Cognition_CSV, Energy_Gam_Cognition_CSV);
  Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Cognition_YeoSystemLevel_NullNetwork_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);
}


