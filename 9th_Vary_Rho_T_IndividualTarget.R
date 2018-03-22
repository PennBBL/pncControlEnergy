
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

#######################################################################
########## Individualized activation as each specific target ##########
#######################################################################

# Import behavior
AllInfo <- read.csv(paste(ReplicationFolder, '/data/BehaviorData/n677_Behavior_20180316.csv', sep = ''));
Behavior <- data.frame(Sex_factor = cut(AllInfo$sex, 2, labels = c("Male", "Female")));
Behavior$Sex_order <- cut(AllInfo$sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);

# Whole brain strength
StrengthInfo <- readMat(paste(ReplicationFolder, '/data/WholeBrainStrength/Strength_FA_677.mat', sep = ''));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$Strength.EigNorm.SubIden);

ResultantFolder <- paste(ReplicationFolder, '/results/FA_Energy/InitialAll0_TargetIndividualActivationZScore', sep = '');
Energy_Data_Folder = paste(ReplicationFolder, '/data/energyData', sep = '');
Parameters <- c(0.1, 0.2, 0.5, 0.8, 2, 5, 8, 10);

########################
### Vary T parameter ###
########################
for (i in c(1:8))
{
  Para_Str <- as.character(Parameters[i]);
  if (i < 5){
    Para_Str <- paste(substr(Para_Str, 1, 1), substr(Para_Str, 3, 3), sep = '');
  }
  Energy_Mat_Path <- paste(Energy_Data_Folder, '/FA_Energy/FA_InitialAll0_TargetIndividualActivationZScore_T_', Para_Str, '.mat', sep = '');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;
  Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;
  # Nodal level
  dimension <- dim(Energy);
  RegionsQuantity <- dimension[2];
  RowName_Nodal <- character(length = RegionsQuantity);
  for (i in 1:RegionsQuantity)
  {
    RowName_Nodal[i] = paste("Node", as.character(i));
  }
  ColName <- c("Z", "P", "P_FDR");
  Energy_Gam_Age <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
  for (i in 1:RegionsQuantity)
  {
    print(i);
    tmp_variable <- Energy[, i];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
    }
  }
  Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste('Energy_Gam_Age_NodalLevel_T_', Para_Str, '.csv', sep = ''));
  write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste('Energy_Gam_Age_NodalLevel_T_', Para_Str, '.mat', sep = ''));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3]);
  # Yeo system average level
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (i in 1:SystemsQuantity)
  {
    print(i);
    tmp_variable <- Energy_YeoAvg[, i];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
    }
  }
  Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste('Energy_Gam_Age_YeoAvg_T_', Para_Str, '.csv', sep = ''));
  write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste('Energy_Gam_Age_YeoAvg_T_', Para_Str, '.mat', sep = ''));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);
}

##########################
### Vary rho parameter ###
##########################
for (i in c(1:8))
{
  Para_Str <- as.character(Parameters[i]);
  if (i < 5){
    Para_Str <- paste(substr(Para_Str, 1, 1), substr(Para_Str, 3, 3), sep = '');
  }
  Energy_Mat_Path <- paste(Energy_Data_Folder, '/FA_Energy/FA_InitialAll0_TargetIndividualActivationZScore_rho_', Para_Str, '.mat', sep = '');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;
  Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;
  # Nodal level
  dimension <- dim(Energy);
  RegionsQuantity <- dimension[2];
  RowName_Nodal <- character(length = RegionsQuantity);
  for (i in 1:RegionsQuantity)
  {
    RowName_Nodal[i] = paste("Node", as.character(i));
  }
  ColName <- c("Z", "P", "P_FDR");
  Energy_Gam_Age <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
  for (i in 1:RegionsQuantity)
  {
    print(i);
    tmp_variable <- Energy[, i];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
    }
  }
  Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste('Energy_Gam_Age_NodalLevel_rho_', Para_Str, '.csv', sep = ''));
  write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste('Energy_Gam_Age_NodalLevel_rho_', Para_Str, '.mat', sep = ''));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3]);
  # Yeo system average level
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
  for (i in 1:SystemsQuantity)
  {
    print(i);
    tmp_variable <- Energy_YeoAvg[, i];
    Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
    }
  }
  Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste('Energy_Gam_Age_YeoAvg_rho_', Para_Str, '.csv', sep = ''));
  write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste('Energy_Gam_Age_YeoAvg_rho_', Para_Str, '.mat', sep = ''));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);  
} 

