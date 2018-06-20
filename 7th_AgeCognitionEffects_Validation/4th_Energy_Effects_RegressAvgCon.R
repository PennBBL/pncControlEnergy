
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

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetMeanActivation_SmallerThanNull');
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
AvgControl <- Controllability_Mat$avg.cont;
AvgControl_Yeo = matrix(0, 949, 8);
for (i in 1:8)
{
  System_I_Index = intersect(which(Yeo_7Systems == i), SmallerThanNull_Index);
  AvgControl_Yeo[, i] = rowMeans(AvgControl[, System_I_Index]);
}
AvgControl <- AvgControl[, SmallerThanNull_Index];
AvgControl_WholeBrainAvg <- rowMeans(AvgControl);

# In-scanner nback task performance
nbackBehAllDprime <- AllInfo$nbackBehAllDprime;
NonNANIndex <- which(!is.na(nbackBehAllDprime));
Behavior_New <- data.frame(Sex_factor = Behavior$Sex_factor[NonNANIndex])
Behavior_New$Age_years <- Behavior$Age_years[NonNANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_New$TBV <- Behavior$TBV[NonNANIndex];
nbackBehAllDprime <- nbackBehAllDprime[NonNANIndex];
Energy_YeoAvg_Cognition <- Energy_YeoAvg[NonNANIndex,];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];
AvgControl_Yeo_Cognition <- AvgControl_Yeo[NonNANIndex,];

Energy_WholeBrainAvg <- rowMeans(Energy)
Energy_Gam <- gam(Energy_WholeBrainAvg ~ s(Age_years, k=4) + AvgControl_WholeBrainAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
visreg(Energy_Gam, 'Age_years');

#########################################################
# 2. Age effect of energy at nodal and Yeo system level #
#########################################################
# Nodal level
print('###### Age effect of energy at nodal level ######');
dimension <- dim(Energy);
RegionsQuantity <- dimension[2];
RowName_Nodal <- character(length = RegionsQuantity);
for (i in 1:RegionsQuantity)
{
  RowName_Nodal[i] = paste("Node", as.character(i));
}
ColName <- c("Z", "P", "P_FDR");
# Variable Energy_Gam_Age has three columns, the 1-3 columns were z value, p value and FDR corrected q value accordingly
Energy_Gam_Age <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  tmp_variable <- Energy[, i];
  # Gam analysis was used for age effect
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + AvgControl[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  # Covert P value to Z value
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  # Linear model was used to test whether it is a positive or negative relationship
  Energy_lm <- lm(tmp_variable ~ Age_years + AvgControl[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
  }
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
# Covert the results (151 lines) to the whole 233 lines, the values of the other 82 lines were 1000
RowName_Nodal <- character(length = 233);
for (i in 1:233)
{
  RowName_Nodal[i] = paste("Node", as.character(i));
}
Energy_Gam_Age_New <- matrix(1000, nrow = 233, ncol = 3, dimnames = list(RowName_Nodal, ColName));
Energy_Gam_Age_New[SmallerThanNull_Index, ] = Energy_Gam_Age;
# Storing the results in both .csv and .mat file
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressAvgControl.csv');
write.csv(Energy_Gam_Age_New, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressAvgControl.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_New[, 1], Age_P = Energy_Gam_Age_New[, 2], Age_P_FDR = Energy_Gam_Age_New[, 3]);
print(paste('Resultant file is ', Energy_Gam_Age_Mat, sep = ''));
# Yeo system average level
print('###### Age effect of energy at Yeo system level ######');
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + AvgControl_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + AvgControl_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
print(Energy_Gam_Age_YeoAvg); # print the results, somatomotor, ventral attention, default mode and subcortical were significant
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressAvgControl.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressAvgControl.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);

#####################################################
# 3. Cognition effect of energy at Yeo system level #
#####################################################
print('###### Cognition effect of energy at Yeo system level ######');
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg_Cognition[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + nbackBehAllDprime + AvgControl_Yeo_Cognition[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg); # print the results, somatomotor, ventral attention, default mode and subcortical were significant
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_nbackBehAllDprime_YeoSystemLevel_RegressAvgControl.csv');
write.csv(Energy_Gam_Cognition_CSV, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_nbackBehAllDprime_YeoSystemLevel_RegressAvgControl.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);
