
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

Energy_Mat_Path = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/Replication/SC_InitialAll0_TargetActivation.mat';
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

AllInfo <- read.csv('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_Behavior_20180202.csv');
Behavior <- data.frame(Sex_factor = cut(AllInfo$sex, 2, labels = c("Male", "Female")));
Behavior$Sex_order <- cut(AllInfo$sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);

# Age effect of the whole brain average energy
WholeBrainAvg <- rowMeans(Energy);
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# Age effect of nodal energy
dimension <- dim(Energy);
RegionsQuantity <- dimension[2];
RowName_Nodal <- character(length = RegionsQuantity);
for (i in 1:RegionsQuantity)
{
  RowName_Nodal[i] = paste("Node", as.character(i));
}
ColName <- c("Z", "P", "P_FDR", "P_Bonf");
Energy_Gam_Age <- matrix(c(1:RegionsQuantity*4), nrow = RegionsQuantity, ncol = 4, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  Energy_Gam <- gam(Energy[, i] ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_Age[i, c(1:2)] <- summary(Energy_Gam)$s.table[, 3:4];
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
Energy_Gam_Age[, 4] <- p.adjust(Energy_Gam_Age[, 2], "bonferroni");
ResultantFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/SC_Energy/Replication/InitialAll0_TargetActivation';
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3], Age_P_Bonf = Energy_Gam_Age[, 4]);

# Age effect of yeo system average energy
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*4), nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, c(1:2)] <- summary(Energy_Gam)$s.table[, 3:4];
  #visreg(Energy_Gam, "Age_years", xlab = "Age (years)", ylab = paste("Average energy ",RowName[i],sep=''), gg = TRUE) + theme(text=element_text(size=20));
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
Energy_Gam_Age_YeoAvg[, 4] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "bonferroni");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3], Age_P_Bonf = Energy_Gam_Age_YeoAvg[, 4]);

# Cognition effect of energy
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

# Whole brain average energy
WholeBrainAvg <- WholeBrainAvg[NANIndex];
# Overall accuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "OverallAccuracy", xlab = "Overall Accuracy", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# F1ExecCompResAccuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F1ExecCompResAccuracy", xlab = "F1ExecCompResAccuracy", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# F2SocialCogAccuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F2SocialCogAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F2SocialCogAccuracy", xlab = "F2SocialCogAccuracy", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# F3MemoryAccuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F3MemoryAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F3MemoryAccuracy", xlab = "F3MemoryAccuracy", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# Nodal energy
Energy_Gam_Cognition <- matrix(c(1:RegionsQuantity*4), nrow = RegionsQuantity, ncol = 4, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  tmp_variable <- Energy[, i];
  tmp_variable <- tmp_variable[NANIndex];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition[, 4] <- p.adjust(Energy_Gam_Cognition[, 2], "bonferroni");
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy.csv');
write.csv(Energy_Gam_Cognition, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_F1ExecCompResAccuracy.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition[, 1], Cognition_P = Energy_Gam_Cognition[, 2], Cognition_P_FDR = Energy_Gam_Cognition[, 3], Cognition_P_Bonf = Energy_Gam_Cognition[, 4]);

# Distance effect
Energy_WholeBrainAvg <- rowMeans(Energy);
Distance <- as.numeric(Energy_Mat$Distance.sum);
# Correlation between energy and distance
cor.test(as.vector(Distance), as.vector(Energy_WholeBrainAvg));
NodeAvg = data.frame(Distance = as.vector(Distance));
NodeAvg$Energy = as.vector(Energy_WholeBrainAvg);
ggplot(NodeAvg, aes(x = Energy, y = Distance)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20));

# Age effect of distance
Gam_Distance <- gam(Distance ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_Distance, "Age_years", xlab = "Age (years)", ylab = "Distance", gg = TRUE) + theme(text=element_text(size=20));
Distance <- Distance[NANIndex];
# Overall accuracy
Gam_Distance <- gam(Distance ~ s(Age_years, k = 4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_Distance, "OverallAccuracy", xlab = "Overall Accuracy", ylab = "Distance", gg = TRUE) + theme(text=element_text(size=20));
# F1ExecCompResAccuracy
Gam_Distance <- gam(Distance ~ s(Age_years, k = 4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_Distance, "F1ExecCompResAccuracy", xlab = "F1ExecCompResAccuracy", ylab = "Distance", gg = TRUE) + theme(text=element_text(size=20));
# F2SocialCogAccuracy
Gam_Distance <- gam(Distance ~ s(Age_years, k = 4) + F2SocialCogAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_Distance, "F2SocialCogAccuracy", xlab = "F2SocialCogAccuracy", ylab = "Distance", gg = TRUE) + theme(text=element_text(size=20));
# F3MemoryAccuracy
Gam_Distance <- gam(Distance ~ s(Age_years, k = 4) + F3MemoryAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_Distance, "F3MemoryAccuracy", xlab = "F3MemoryAccuracy", ylab = "Distance", gg = TRUE) + theme(text=element_text(size=20));

# Correlation between energy and activation
Activation <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/nback_2b0b_20180202.mat');
Activation_New <- data.frame(scanid = Activation$scanid);
Activation_New$Activation.2b0b <- Activation$Activation.2b0b;
Activation_New$Activation_NodalAvg <- rowMeans(Activation$Activation.2b0b);
Energy_New <- data.frame(scanid = t(Energy_Mat$scan.ID));
Energy_New$Energy_NodalAvg <- rowMeans(Energy_Mat$Energy);
Energy_New$Energy <- Energy_Mat$Energy;
# The subjects' order in activation (677 subjects) is different from that of energy (949 subjects), so use merge function to make them the same
Activation_Energy <- merge(Activation_New, Energy_New, by = "scanid");
Behavior$scanid <- AllInfo$scanid;
Activation_Energy <- merge(Activation_Energy, Behavior, by = "scanid");
Activation <- Activation_Energy$Activation.2b0b;
Activation_Abs <- abs(Activation);
Energy <- Activation_Energy$Energy;
# nodal correlation
P_Activation_Energy = matrix(0, 233, 1);
P_ActivationAbs_Energy = matrix(0, 233, 1);
for (i in c(1:233))
{ 
  i
  Gam_Activation_Energy <- gam(Activation[,i] ~ Energy[,i] + s(Age_years, k = 4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Activation_Energy);
  P_Activation_Energy[i] <- summary(Gam_Activation_Energy)$p.table[2,4];
  
  Gam_Activation_Energy <- gam(Activation_Abs[,i] ~ Energy[,i] + s(Age_years, k = 4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Activation_Energy);
  P_ActivationAbs_Energy[i] <- summary(Gam_Activation_Energy)$p.table[2,4];
}
P_Activation_Energy_fdr = p.adjust(P_Activation_Energy, "fdr");
P_ActivationAbs_Energy_fdr = p.adjust(P_ActivationAbs_Energy, "fdr");

# Specificity of age effect on the situation of target state of activation
# Target: FP 1
Energy_Mat_Path = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/Replication/SC_InitialAll0_TargetFP1.mat';
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
WholeBrainAvg <- rowMeans(Energy);
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# Target: Motor 1
Energy_Mat_Path = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/Replication/SC_InitialAll0_TargetMotor1.mat';
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
WholeBrainAvg <- rowMeans(Energy);
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# Target: Visual 1
Energy_Mat_Path = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/Replication/SC_InitialAll0_TargetVisual1.mat';
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
WholeBrainAvg <- rowMeans(Energy);
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
