
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

#######################################################################
########## Individualized activation as each specific target ##########
#######################################################################

Energy_Mat_Path = paste(ReplicationFolder, '/data/energyData/FA_Energy/FA_InitialAll0_TargetIndividualActivationZScore.mat', sep = '');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

# Visualize energy for each system
Yeo_atlas <- readMat(paste(ReplicationFolder, '/data/Yeo_7system.mat', sep = ''));
Energy_SubjectsAvg <- colMeans(Energy);
tmp <- data.frame(Energy_data = log(Energy_SubjectsAvg), Yeo = Yeo_atlas$Yeo.7system);
tmp$Yeo <- factor(tmp$Yeo, levels = c(1:8), labels = c("Visual","SM", "DA", "VA", "limbic","FP","DM","SC"));
qplot(Yeo, Energy_data, data = tmp, geom=c("boxplot","jitter"), fill=Yeo, xlab="Yeo systems", ylab="Energy") + ggtitle("Initial All 0; Target activation") + theme(plot.title = element_text(hjust = 0.5));

# Distance effect
Energy_WholeBrainAvg <- rowMeans(Energy);
Distance <- as.numeric(Energy_Mat$Distance.sum);
# Correlation between energy and distance
cor.test(as.vector(Distance), as.vector(Energy_WholeBrainAvg));
NodeAvg = data.frame(Distance = as.vector(Distance));
NodeAvg$Energy = as.vector(Energy_WholeBrainAvg);
ggplot(NodeAvg, aes(x = Energy, y = Distance)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20));

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

# For cognition effect of energy
NANIndex = as.matrix(which(!is.na(AllInfo$Overall_Accuracy)));
Behavior_New <- data.frame(Age_years = Behavior$Age_years[NANIndex]);
Behavior_New$Sex_factor <- Behavior$Sex_factor[NANIndex];
Behavior_New$Sex_order <- Behavior$Sex_order[NANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NANIndex];
Behavior_New$TBV <- Behavior$TBV[NANIndex];
Behavior_New$OverallAccuracy <- AllInfo$Overall_Accuracy[NANIndex];
Behavior_New$F1ExecCompResAccuracy <- AllInfo$F1_Exec_Comp_Res_Accuracy[NANIndex];
Behavior_New$F3MemoryAccuracy <- AllInfo$F3_Memory_Accuracy[NANIndex];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NANIndex];

# Correlation between energy and activation
Activation <- readMat(paste(ReplicationFolder, '/data/ActivationData/nback_2b0b_20180202.mat', sep = ''));
Activation_2b0b <- Activation$Activation.2b0b;
# nodal correlation
P_Activation_Energy = matrix(0, 233, 1);
T_Activation_Energy = matrix(0, 233, 1);
for (i in c(1:233)) 
{         
  i      
  Gam_Activation_Energy <- gam(Activation_2b0b[,i] ~ Energy[,i] + s(Age_years, k = 4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  P_Activation_Energy[i] <- summary(Gam_Activation_Energy)$p.table[2,4];
  T_Activation_Energy[i] <- summary(Gam_Activation_Energy)$p.table[2,3];
}            
P_Activation_Energy_fdr = p.adjust(P_Activation_Energy, "fdr");
ResultantFolder <- paste(ReplicationFolder, '/results/FA_Energy/InitialAll0_TargetIndividualActivationZScore', sep = '');
dir.create(ResultantFolder, recursive = TRUE);
Activation_Energy_Mat <- file.path(ResultantFolder, 'Activation_Energy_Relation.mat');
writeMat(Activation_Energy_Mat, T_Activation_Energy = T_Activation_Energy, P_Activation_Energy = P_Activation_Energy, P_Activation_Energy_fdr = P_Activation_Energy_fdr);

# Age effect of nodal energy
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
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3]);

# Age effect of yeo system average energy
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
  #visreg(Energy_Gam, "Age_years", xlab = "Age (years)", ylab = paste("Average energy ",RowName[i],sep=''), gg = TRUE) + theme(text=element_text(size=20));
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);

# Nodal energy
# OverallAccuracy
Energy_Gam_Cognition <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  tmp_variable <- Energy[, i];
  tmp_variable <- tmp_variable[NANIndex]; 
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_OverallAccuracy.csv');
write.csv(Energy_Gam_Cognition, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_OverallAccuracy.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition[, 1], Cognition_P = Energy_Gam_Cognition[, 2], Cognition_P_FDR = Energy_Gam_Cognition[, 3]);
# F1ExecCompResAccuracy
Energy_Gam_Cognition <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  tmp_variable <- Energy[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy.csv');
write.csv(Energy_Gam_Cognition, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition[, 1], Cognition_P = Energy_Gam_Cognition[, 2], Cognition_P_FDR = Energy_Gam_Cognition[, 3]);

# Yeo system level
# OverallAccuracy
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
# F1ExecCompResAccuracy
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
# F3MemoryAccuracy
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F3MemoryAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr"); 

# Psychopathology, whole-brain average energy
Energy_WholeBrainAvg <- rowMeans(Energy);
Behavior$Psychosis_corrtrait_Sr <- AllInfo$psychosis_sr_corrtraits;
Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(Age_years, k = 4) + Psychosis_corrtrait_Sr + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Psychosis_corrtrait_Sr", xlab = "Psychosis_corrtrait_Sr", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

###############################################
######### Validation: volNormSC matrix ########
###### Age, cognition, Psychosis effects ######
###############################################
Energy_Mat_Path = paste(ReplicationFolder, '/data/energyData/volNormSC_Energy/volNormSC_InitialAll0_TargetIndividualActivationZScore.mat', sep = '');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;
# Whole brain strength
StrengthInfo <- readMat(paste(ReplicationFolder, '/data/WholeBrainStrength/Strength_volNormSC_677.mat', sep = ''));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$Strength.EigNorm.SubIden);
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NANIndex];
ResultantFolder <- paste(ReplicationFolder, '/results/volNormSC_Energy/InitialAll0_TargetIndividualActivationZScore', sep = '');
dir.create(ResultantFolder, recursive = TRUE);
# Age effect of nodal energy
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
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3]);
# Age effect of Yeo system level
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
  #visreg(Energy_Gam, "Age_years", xlab = "Age (years)", ylab = paste("Average energy ",RowName[i],sep=''), gg = TRUE) + theme(text=element_text(size=20));
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);
# Cognition effect of energy
# Nodal level
# OverallAccuracy
Energy_Gam_Cognition <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{ 
  print(i);
  tmp_variable <- Energy[, i];
  tmp_variable <- tmp_variable[NANIndex]; 
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_OverallAccuracy.csv');
write.csv(Energy_Gam_Cognition, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_OverallAccuracy.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition[, 1], Cognition_P = Energy_Gam_Cognition[, 2], Cognition_P_FDR = Energy_Gam_Cognition[, 3]);
# F1ExecCompResAccuracy
Energy_Gam_Cognition <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{ 
  print(i);
  tmp_variable <- Energy[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy.csv');
write.csv(Energy_Gam_Cognition, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition[, 1], Cognition_P = Energy_Gam_Cognition[, 2], Cognition_P_FDR = Energy_Gam_Cognition[, 3]);
# Yeo system level
# OverallAccuracy
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
# F1ExecCompResAccuracy
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
# F3MemoryAccuracy
Energy_Gam_Cognition_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F3MemoryAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition_YeoAvg[, 3] <- p.adjust(Energy_Gam_Cognition_YeoAvg[, 2], "fdr");
# Psychopathology, whole-brain average energy
Energy_WholeBrainAvg <- rowMeans(Energy);
Behavior$Psychosis_corrtrait_Sr <- AllInfo$psychosis_sr_corrtraits;
Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(Age_years, k = 4) + Psychosis_corrtrait_Sr + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Psychosis_corrtrait_Sr", xlab = "Psychosis_corrtrait_Sr", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
