
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

#######################################################################
########## Individualized activation as each specific target ##########
##########       Results after regressing activation         ##########
#######################################################################

Energy_Mat_Path = paste(ReplicationFolder, '/data/energyData/FA_Energy/FA_InitialAll0_TargetIndividualActivationZScore.mat', sep = '');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

ResultantFolder <- paste(ReplicationFolder, '/results/FA_Energy/InitialAll0_TargetIndividualActivationZScore', sep = '');
if (!dir.exists(ResultantFolder))
{ 
  dir.create(ResultantFolder, recursive = TRUE);
}

###############################################
# Import demographics, cognition and strength #
###############################################
# Demographics, motion, TBV
AllInfo <- read.csv(paste(ReplicationFolder, '/data/BehaviorData/n803_Behavior_20180321.csv', sep = ''));
Behavior <- data.frame(Sex_factor = cut(AllInfo$sex, 2, labels = c("Male", "Female")));
Behavior$Sex_order <- cut(AllInfo$sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of FA-weighted network
StrengthInfo <- readMat(paste(ReplicationFolder, '/data/WholeBrainStrength/Strength_FA_803.mat', sep = ''));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$Strength.EigNorm.SubIden);
# Cognition (Note: one subject does not have cognition data, so we remove this subject for cognition effect analysis)
NANIndex = as.matrix(which(!is.na(AllInfo$Overall_Accuracy)));
Behavior_New <- data.frame(Age_years = Behavior$Age_years[NANIndex]);
Behavior_New$Sex_factor <- Behavior$Sex_factor[NANIndex];
Behavior_New$Sex_order <- Behavior$Sex_order[NANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NANIndex];
Behavior_New$TBV <- Behavior$TBV[NANIndex];
Behavior_New$OverallAccuracy <- AllInfo$Overall_Accuracy[NANIndex];
Behavior_New$F1ExecCompResAccuracy <- AllInfo$F1_Exec_Comp_Res_Accuracy[NANIndex];
Behavior_New$F2SocialCogAccuracy <- AllInfo$F2_Social_Cog_Accuracy[NANIndex];
Behavior_New$F3MemoryAccuracy <- AllInfo$F3_Memory_Accuracy[NANIndex];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NANIndex];
# Extract activation data
Activation_Mat <- readMat(paste(ReplicationFolder, '/data/Activation_803.mat', sep = ''));
Activation <- Activation_Mat$Activation.2b0b;
Activation_Cognition <- Activation[NANIndex,];

YeoAtlas_Mat <- readMat(paste(ReplicationFolder, '/data/Yeo_7system.mat', sep = ''));
Activation_Yeo = matrix(0, 803, 8);
for (i in 1:8)
{
  SystemI_indice = which(YeoAtlas_Mat$Yeo.7system == i);
  Activation_Yeo[, i] = rowMeans(Activation[, SystemI_indice]); 
}
Activation_Yeo_Cognition <- Activation_Yeo[NANIndex,];

######################################################
# Age effect of energy at nodal and Yeo system level #
######################################################
# Nodal level
print('Age effect of energy at nodal level (FA matrix)');
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
  tmp_variable <- Energy[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Activation[,i] +  Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + Activation[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
  }
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressActivation.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressActivation.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3]);
print('Finished!');
print(paste('Resultant file is ', Energy_Gam_Age_Mat, sep = ''));
# Yeo system average level
print('Age effect of energy at Yeo system level (FA matrix)');
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Activation_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + Activation_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }
  #visreg(Energy_Gam, "Age_years", xlab = "Age (years)", ylab = paste("Average energy ",RowName[i],sep=''), gg = TRUE) + theme(text=element_text(size=20));
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
print(Energy_Gam_Age_YeoAvg);
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressActivation.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressActivation.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);

##################################################
# Cognition effect of energy at Yeo system level #
##################################################

dimension <- dim(Activation);
RegionsQuantity <- dimension[2];
RowName_Nodal <- character(length = RegionsQuantity);
for (i in 1:RegionsQuantity)
{
  RowName_Nodal[i] = paste("Node", as.character(i));
}
ColName <- c("Z", "P", "P_FDR");
Activation_Gam_Cognition <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  if (sum(Activation_Cognition[,i]) == 0)
  {
    next;
    Activation_Gam_Cognition[i, 1] = 0;
    Activation_Gam_Cognition[i, 2:3] = 1000;
  }
  tmp_variable <- Activation_Cognition[, i];
  Activation_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy +  Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Activation_Gam_Cognition[i, 2] <- summary(Activation_Gam)$p.pv[2];
  Activation_Gam_Cognition[i, 1] <- summary(Activation_Gam)$p.t[2];
}
Index = which(Activation_Gam_Cognition[, 1] != 0);
Activation_Gam_Cognition[Index, 3] <- p.adjust(Activation_Gam_Cognition[Index, 2], "fdr");
#######
dimension <- dim(Activation);
RegionsQuantity <- dimension[2];
RowName_Nodal <- character(length = RegionsQuantity);
for (i in 1:RegionsQuantity)
{
  RowName_Nodal[i] = paste("Node", as.character(i));
}
ColName <- c("Z", "P", "P_FDR");
Activation_Gam_Cognition <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  if (sum(Activation_Cognition[,i]) == 0)
  {
    next;
    Activation_Gam_Cognition[i, 1] = 0;
    Activation_Gam_Cognition[i, 2:3] = 1000;
  }
  tmp_variable <- Activation_Cognition[, i];
  Activation_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy +  Sex_factor + HandednessV2 + MotionMeanRelRMS, method = "REML", data = Behavior_New);
  Activation_Gam_Cognition[i, 2] <- summary(Activation_Gam)$p.pv[2];
  Activation_Gam_Cognition[i, 1] <- summary(Activation_Gam)$p.t[2];
}
Index = which(Activation_Gam_Cognition[, 1] != 0);
Activation_Gam_Cognition[Index, 3] <- p.adjust(Activation_Gam_Cognition[Index, 2], "fdr");

# OverallAccuracy
print('OverallAccuracy effect of energy at Yeo system level (FA matrix)');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Activation_Yeo_Cognition[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg);
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_OverallAccuracy_YeoSystemLevel_RegressActivation.csv');
write.csv(Energy_Gam_Cognition_YeoAvg, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_OverallAccuracy_YeoSystemLevel_RegressActivation.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);

# F1ExecCompResAccuracy
print('F1ExecCompResAccuracy effect of energy at Yeo system level (FA matrix)');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy + Activation_Yeo_Cognition[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg);
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy_YeoSystemLevel_RegressActivation.csv');
write.csv(Energy_Gam_Cognition_YeoAvg, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy_YeoSystemLevel_RegressActivation.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);

#F2SocialCogAccuracy
print('###### F2SocialCogAccuracy effect of energy at Yeo system level (FA matrix) ######');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F2SocialCogAccuracy + Activation_Yeo_Cognition[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg); # No system is significant
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_F2SocialCogAccuracy_YeoSystemLevel_RegressActivation.csv');
write.csv(Energy_Gam_Cognition_YeoAvg, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_F2SocialCogAccuracy_YeoSystemLevel_RegressActivation.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);

# F3MemoryAccuracy
print('F3MemoryAccuracy effect of energy at Yeo system level (FA matrix)');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F3MemoryAccuracy + Activation_Yeo_Cognition[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr"); 
print(Energy_Gam_Cognition_YeoAvg);
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_F3MemoryAccuracy_YeoSystemLevel_RegressActivation.csv');
write.csv(Energy_Gam_Cognition_YeoAvg, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_F3MemoryAccuracy_YeoSystemLevel_RegressActivation.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);
