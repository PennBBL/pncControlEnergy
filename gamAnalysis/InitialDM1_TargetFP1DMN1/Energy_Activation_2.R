
# Second kind relation between energy and activation/deactivation, but first seach out the regions with significant correlation between energy and cognition and between activation and cognition

library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);
library(GeneNet);

Energy_Data_Folder = '/data/joy/BBL/projects/pncClinDtiControl/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_Initial_DM.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);

Activation_Mat_Path <- '/data/joy/BBL/projects/pncClinDtiControl/data/subjectData/nback_2b0b_20170427.mat';
Activation_Mat <- readMat(Activation_Mat_Path);
Activation_2b0b <- Activation_Mat$Activation.2b0b;

NA_Mask = matrix(0, 1089, 1);
for (i in 1:233)
{
  tmp <- Activation_2b0b[, i];
  tmp[which(!is.na(tmp))] = 0;
  tmp[which(is.na(tmp))] = 1;
  NA_Mask = NA_Mask + tmp;
}
# NA_Mask[which(NA_Mask != 0)] = 1;

Behavior <- readMat('/data/joy/BBL/projects/pncClinDtiControl/data/subjectData/n1089_Bifactor_DtiMotion_Demogra.mat');
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);
Tissue <- readMat('/data/joy/BBL/projects/pncClinDtiControl/data/subjectData/n1089_ctVol20170412.mat');
Behavior$TBV <- as.numeric(Tissue$TBV);
Cognition <- readMat('/data/joy/BBL/projects/pncClinDtiControl/data/subjectData/n1089_cnb_factor_scores_tymoore_20151006.mat');
Behavior$OverallAccuracy <- Cognition$OverallAccuracy;
Cognition_NAIndex = Cognition$OverallAccuracy;
Cognition_NAIndex[which(!is.na(Cognition_NAIndex))] = 0;
Cognition_NAIndex[which(is.na(Cognition_NAIndex))] = 1;

Exclude_Mask <- as.matrix(Activation_Mat$nbackExclude) + as.matrix(Activation_Mat$nbackZerobackExclude) + NA_Mask + Cognition_NAIndex;
Exclude_Mask[which(Exclude_Mask != 0)] = 1;

RetainIndex <- which(!Exclude_Mask);
Scan_ID <- Energy_Mat$scan.ID[RetainIndex];
Energy <- Energy_Mat$Energy[RetainIndex,];
Activation_2b0b <- Activation_Mat$Activation.2b0b[RetainIndex,];

Behavior_New <- data.frame(Age_years = Behavior$Age_years[RetainIndex]);
Behavior_New$Sex_factor <- Behavior$Sex_factor[RetainIndex];
Behavior_New$Sex_order <- Behavior$Sex_order[RetainIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[RetainIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[RetainIndex];
Behavior_New$TBV <- Behavior$TBV[RetainIndex];
Behavior_New$OverallAccuracy <- Behavior$OverallAccuracy[RetainIndex];

P_Energy = matrix(0, 233, 1);
P_Activation = matrix(0, 233, 1);
P_Energy_FDR = matrix(0, 233, 1);
P_Activation_FDR = matrix(0, 233, 1);
# Activation_2b0b = z.transform(Activation_2b0b);
for (i in 1:233)
{
  print(i);
  tmp_variable <- Energy[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  P_Energy[i] <- summary(Energy_Gam)$p.pv[2];
  tmp_variable <- Activation_2b0b[, i];
  Activation_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  P_Activation[i] <- summary(Activation_Gam)$p.pv[2];
}
P_Energy_FDR <- p.adjust(P_Energy, "fdr");
Energy_SigMask <- P_Energy_FDR;
Energy_SigMask[which(P_Energy_FDR < 0.05)] = 1 ;
Energy_SigMask[which(P_Energy_FDR >= 0.05)] = 0;
P_Activation_FDR <- p.adjust(P_Activation, "fdr");
Activation_SigMask <- P_Activation_FDR;
Activation_SigMask[which(P_Activation_FDR < 0.05)] = 1;
Activation_SigMask[which(P_Activation_FDR >= 0.05)] = 0;

Energy_SubAvg = colMeans(Energy);
Energy_Sig = Energy_SubAvg * Energy_SigMask;
Activation_2b0b_SubAvg = colMeans(Activation_2b0b);
Activation_2b0b_Sig = Activation_2b0b_SubAvg * Activation_SigMask;
cor.test(Energy_Sig, Activation_2b0b_Sig);

Intersect_SigIndex = intersect(which(Energy_SigMask == 1), which(Activation_SigMask == 1));
Activation_SigRegionAvg <- rowMeans(Activation_2b0b[, Intersect_SigIndex]);
Energy_SigRegionAvg <- rowMeans(Energy[, Intersect_SigIndex]);
Activation_Energy_Gam <- gam(Energy_SigRegionAvg ~ s(Age_years, k = 4) + Activation_SigRegionAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

PValue = matrix(0, 233, 1);
for (i in 1:233)
{       
  Activation_Energy_Gam <- gam(Energy[, i] ~ s(Age_years, k = 4) + Activation_2b0b[, i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);   
  PValue[i] <- summary(Activation_Energy_Gam)$p.pv[2];
}
PValue = p.adjust(PValue[Intersect_SigIndex], 'fdr'); # only correct the regions with significant activation under FDR

ResultantFolder <- '/data/joy/BBL/projects/pncClinDtiControl/results/Energy_Analysis/Energy_Activation';
writeMat(paste(ResultantFolder, '/Energy_SubAvg.mat', sep = ''), Scan_ID = Scan_ID, Energy = Energy, Activation_2b0b = Activation_2b0b, Energy_SubAvg = Energy_SubAvg, Activation_2b0b_SubAvg = Activation_2b0b_SubAvg);

 
