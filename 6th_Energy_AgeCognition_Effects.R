
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

################################################################
# 1. boxplot the energy for each system                        #
#    only display regions with small energy than null networks #
################################################################
Yeo_atlas <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7Systems <- Yeo_atlas$Yeo.7system[SmallerThanNull_Index];
Energy_SubjectsAvg <- colMeans(Energy);
tmp <- data.frame(Energy_data = log(Energy_SubjectsAvg), Yeo = Yeo_7Systems);
tmp$Yeo <- factor(tmp$Yeo, levels = c(1:8), labels = c("Visual", "Somatomotor", "Dorsal Attention", "Ventral Attention", "Limbic", "Frontoparietal", "Default Mode", "Subcortical"));
Fig <- ggplot(tmp, aes(x = Yeo, y = Energy_data)) + geom_boxplot(fill = c("#AF33AD", "#7499C2", "#00A131", "#E443FF", "#EBE297", "#F5BA2E", "#E76178", "#5091CD"), width = 0.7) + geom_jitter()
Fig <- Fig + labs(x = "", y = "log(Energy)") + theme_classic()
Fig + theme(axis.text = element_text(size= 18, colour="black"), axis.title=element_text(size = 24), axis.text.x = element_text(angle = 45, hjust = 1));
ggsave('/data/jux/BBL/projects/pncControlEnergy/scripts/PlotResults/FA_Network/Energyln_Boxplot_154.tiff', width = 20, height = 20, units = "cm");

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

#########################################################
# 2. Age effect of energy at nodal and Yeo system level #
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
print(Energy_Gam_Age_YeoAvg); # print the results, somatomotor, ventral attention, default mode and subcortical were significant
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);

# Nodal level
print('###### Age effect of energy at nodal level ######');
Energy_Gam_Age <- matrix(0, 154, 3); # Because 154 regions that represent lower energy in real network compared to null network were used here
for (i in 1:154)
{
  tmp_variable <- Energy[, i];
  # Gam analysis was used for age effect
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  # Covert P value to Z value
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  # Linear model was used to test whether it is a positive or negative relationship
  Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
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
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.csv');
write.csv(Energy_Gam_Age_New, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_New[, 1], Age_P = Energy_Gam_Age_New[, 2], Age_P_FDR = Energy_Gam_Age_New[, 3]);
print(paste('Resultant file is ', Energy_Gam_Age_Mat, sep = ''));

################################################################
# 3. nback-task effect of energy at nodal and Yeo system level #
################################################################
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

# Yeo system average level
print('###### Cognition effect of energy at Yeo system level ######');
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Cognition_YeoAvg <- matrix(0, nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg_Cognition[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + nbackBehAllDprime + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg); 
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_nbackBehAllDprime_YeoSystemLevel.csv');
write.csv(Energy_Gam_Cognition_CSV, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_nbackBehAllDprime_YeoSystemLevel.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);

# At nodal level, no regions were signficant after FDR correction
# But as subcortical system was significant at system level, we are interested to look at the uncorrected P value of regions in subcortical system
print('###### N-back task effect of energy at nodal level ######');
Energy_Gam_Cognition <- matrix(0, 154, 2); 
for (i in 1:154)
{
  tmp_variable <- Energy_Cognition[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + nbackBehAllDprime + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
# Covert the results (151 lines) to the whole 233 lines, the values of the other 82 lines were 1000
Energy_Gam_Cognition_New <- matrix(0, nrow = 233, ncol = 2, dimnames = list(RowName_Nodal_233, c("Z", "P")));
Energy_Gam_Cognition_New[SmallerThanNull_Index, ] = Energy_Gam_Cognition;
# Storing the results in both .csv and .mat file
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_nbackBehAllDprime_NodalLevel.csv');
write.csv(Energy_Gam_Cognition_New, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_nbackBehAllDprime_NodalLevel.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_New[, 1], Cognition_P = Energy_Gam_Cognition_New[, 2]);
print(paste('Resultant file is ', Energy_Gam_Cognition_Mat, sep = ''));

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
Energy_Cognition <- Energy[NonNANIndex,];
Energy_YeoAvg_Cognition <- Energy_YeoAvg[NonNANIndex,];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];

print('###### Excutive performance effect of energy at Yeo system level ######');
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg_Cognition[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1_Exec_Comp_Res_Accuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg); 
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_nbackBehAllDprime_YeoSystemLevel.csv');
write.csv(Energy_Gam_Cognition_CSV, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy_YeoSystemLevel.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_YeoAvg[, 1], Cognition_P = Energy_Gam_Cognition_YeoAvg[, 2], Cognition_P_FDR = Energy_Gam_Cognition_YeoAvg[, 3]);

# Effect of accuracy of social cognition and memory abilities
# We hypothesized there is no significant correlation
# Also, the 66th and 611th subjects does not have F2_Social_Cog_Accuracy and F3_Memory_Accuracy
# Social cognitive accuracy
F2_Social_Cog_Accuracy <- AllInfo$F2_Social_Cog_Accuracy[NonNANIndex];
print('###### Social cognition effect of energy at Yeo system level ######');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg_Cognition[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F2_Social_Cog_Accuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg);
# Memory accuracy
F3_Memory_Accuracy <- AllInfo$F3_Memory_Accuracy[NonNANIndex];
print('###### Memory effect of energy at Yeo system level ######');
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  tmp_variable <- Energy_YeoAvg_Cognition[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F3_Memory_Accuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
print(Energy_Gam_Cognition_YeoAvg);



