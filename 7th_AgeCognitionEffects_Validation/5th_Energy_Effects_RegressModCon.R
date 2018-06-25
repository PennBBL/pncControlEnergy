
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

Energy_Mat_Path = paste0(ReplicationFolder, '/data/energyData/InitialAll0_TargetActivationMean.mat');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy.New;

Index <- readMat(paste0(ReplicationFolder, '/data/SmallerThanNull_Index.mat'));
SmallerThanNull_Index <- Index$SmallerThanNull.Index;

Yeo_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7Systems <- Yeo_Mat$Yeo.7system;
Energy_YeoAvg <- matrix(0, 949, 8);
for (i in 1:8)
{
  System_I_Index <- intersect(which(Yeo_7Systems == i), SmallerThanNull_Index);
  Energy_YeoAvg[, i] <- rowMeans(Energy[, System_I_Index]);
}
Energy <- Energy[, SmallerThanNull_Index];

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetMeanActivation');
if (!dir.exists(ResultantFolder))
{
  dir.create(ResultantFolder, recursive = TRUE);
}

###############################################
# Import demographics, cognition and strength #
###############################################
# Demographics, motion, TBV
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n949_Behavior_20180522.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of the network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/WholeBrainStrength_FA_949.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

# Import average controllability 
Controllability_Mat <- readMat(paste0(ReplicationFolder, '/data/Controllability/Lausanne125_Control.mat'));
ModControl <- Controllability_Mat$mod.cont;
ModControl_Yeo = matrix(0, 949, 8);
for (i in 1:8)
{
  System_I_Index = intersect(which(Yeo_7Systems == i), SmallerThanNull_Index);
  ModControl_Yeo[, i] = rowMeans(ModControl[, System_I_Index]);
}
ModControl <- ModControl[, SmallerThanNull_Index];

#########################################################
# 1. Age effect of energy at nodal and Yeo system level #
#########################################################
# Yeo system average level
print('###### Age effect of energy at Yeo system level ######');
SystemsQuantity = 8;
ColName <- c("Z", "P", "P_FDR");
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Age_YeoAvg <- matrix(0, nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  tmp_variable <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + ModControl_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4]; 
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + ModControl_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
print(Energy_Gam_Age_YeoAvg); 
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressAvgControl.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressAvgControl.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);

# Nodal level
print('###### Age effect of energy at nodal level ######');
Energy_Gam_Age <- matrix(0, 154, 3); # Because 154 regions that represent lower energy in real network compared to null network were used here
for (i in 1:154)
{
  tmp_variable <- Energy[, i];
  # Gam analysis was used for age effect
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + ModControl[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  # Covert P value to Z value
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  # Linear model was used to test whether it is a positive or negative relationship
  Energy_lm <- lm(tmp_variable ~ Age_years + ModControl[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
  }
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
# Covert the results (151 lines) to the whole 233 lines, the values of the other 82 lines were 100
RowName_Nodal_233 <- character(length = 233);
for (i in 1:233)
{
  RowName_Nodal_233[i] = paste("Node", as.character(i));
}
Energy_Gam_Age_New <- matrix(0, nrow = 233, ncol = 3, dimnames = list(RowName_Nodal_233, ColName));
Energy_Gam_Age_New[SmallerThanNull_Index, ] = Energy_Gam_Age;
# Storing the results in both .csv and .mat file
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressModControl.csv');
write.csv(Energy_Gam_Age_New, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressModControl.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_New[, 1], Age_P = Energy_Gam_Age_New[, 2], Age_P_FDR = Energy_Gam_Age_New[, 3]);
print(paste('Resultant file is ', Energy_Gam_Age_Mat, sep = ''));

#################################################################
# 2. n-back task effect of average energy of subcortical system #
#################################################################
# In-scanner nback task performance
nbackBehAllDprime <- AllInfo$nbackBehAllDprime;
NonNANIndex <- which(!is.na(nbackBehAllDprime));
Behavior_New <- data.frame(Sex_factor = Behavior$Sex_factor[NonNANIndex])
Behavior_New$Age_years <- Behavior$Age_years[NonNANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_New$TBV <- Behavior$TBV[NonNANIndex];
nbackBehAllDprime <- nbackBehAllDprime[NonNANIndex];
Energy_Cognition <- Energy[NonNANIndex,];
Energy_YeoAvg_Cognition <- Energy_YeoAvg[NonNANIndex,];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];
ModControl_Yeo_Cognition <- ModControl_Yeo[NonNANIndex,];

# Yeo system average level
# N-back task effect of average energy of subcortical system
print('###### Cognition effect of average energy of subcortical system ######');
tmp_variable <- Energy_YeoAvg_Cognition[, 8];
Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + nbackBehAllDprime + ModControl_Yeo_Cognition[,8] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
print(paste0('P value is: ', as.character(summary(Energy_Gam)$p.pv[2])))

####################################################
# 4. Executive function effect at Yeo system level #
#    Put in the supplementary material             #
####################################################
# Executive function
F1_Exec_Comp_Res_Accuracy <- AllInfo$F1_Exec_Comp_Res_Accuracy;
NonNANIndex <- which(!is.na(F1_Exec_Comp_Res_Accuracy)); # The 66th and 611th subjects does not have F1_Exec_Comp_Res_Accuracy metric
Behavior_New <- data.frame(Sex_factor = Behavior$Sex_factor[NonNANIndex])
Behavior_New$Age_years <- Behavior$Age_years[NonNANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_New$TBV <- Behavior$TBV[NonNANIndex];
F1_Exec_Comp_Res_Accuracy <- F1_Exec_Comp_Res_Accuracy[NonNANIndex];
Energy_YeoAvg_Cognition <- Energy_YeoAvg[NonNANIndex,];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];
ModControl_Yeo_Cognition <- ModControl_Yeo[NonNANIndex,];

print('###### Excutive performance effect of average energy of subcortical system ######');
tmp_variable <- Energy_YeoAvg_Cognition[, 8];
Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1_Exec_Comp_Res_Accuracy + ModControl_Yeo_Cognition[,8] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
P_ExecutiveFunction <- summary(Energy_Gam)$p.pv[2];
print(paste0('P value: ', as.character(P_ExecutiveFunction)));
# Social cognition  
F2_Social_Cog_Accuracy <- AllInfo$F2_Social_Cog_Accuracy[NonNANIndex];
print('###### Social cognition effect of average energy of subcortical system ######');
tmp_variable <- Energy_YeoAvg_Cognition[, 8];
Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F2_Social_Cog_Accuracy + ModControl_Yeo_Cognition[,8] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
P_SocialCognition <- summary(Energy_Gam)$p.pv[2];
print(paste0('P value: ', as.character(P_SocialCognition)));
# Memory accuracy
F3_Memory_Accuracy <- AllInfo$F3_Memory_Accuracy[NonNANIndex];
print('###### Memory effect of average energy of subcortical system ######');
tmp_variable <- Energy_YeoAvg_Cognition[, 8];
Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F3_Memory_Accuracy + ModControl_Yeo_Cognition[,8] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
P_Memory <- summary(Energy_Gam)$p.pv[2];
print(paste0('P value: ', as.character(P_Memory)));
