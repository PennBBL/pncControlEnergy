
# First kind relation between energy and significant activation/deactivation

library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);
library(GeneNet);

Energy_Data_Folder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetFP1DMN1.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);

Activation_Mat_Path <- '/data/joy/BBL/projects/pncControlEnergy/data/subjectData/nback_2b0b_20170427.mat';
Activation_Mat <- readMat(Activation_Mat_Path);
Activation_2b0b <- Activation_Mat$Activation.2b0b;

NA_Mask = matrix(0, 949, 1);
for (i in 1:233)
{
  tmp <- Activation_2b0b[, i];
  tmp[which(!is.na(tmp))] = 0;
  tmp[which(is.na(tmp))] = 1;
  NA_Mask = NA_Mask + tmp;
}
# NA_Mask[which(NA_Mask != 0)] = 1;

Exclude_Mask <- as.matrix(Activation_Mat$nbackExclude) + as.matrix(Activation_Mat$nbackZerobackExclude) + NA_Mask;
Exclude_Mask[which(Exclude_Mask != 0)] = 1;

RetainIndex <- which(!Exclude_Mask);
Scan_ID <- Energy_Mat$scan.ID[RetainIndex];
Energy <- Energy_Mat$Energy[RetainIndex,];
Activation_2b0b <- Activation_Mat$Activation.2b0b[RetainIndex,];
Energy_SubAvg <- colMeans(Energy);
Activation_2b0b_SubAvg <- colMeans(Activation_2b0b);
Corr_1 <- cor.test(Energy_SubAvg, Activation_2b0b_SubAvg);
data_All <- data.frame(Energy_SubAvg = Energy_SubAvg, Activation_2b0b_SubAvg = Activation_2b0b_SubAvg);
ggplot(data_All, aes(x = Energy_SubAvg, y = Activation_2b0b_SubAvg))+geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

  # Correlate across regions in FP&DM, and then correlate across regions in other systems
Yeo_Systems_Mat <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Yeo_Systems_Index <- Yeo_Systems_Mat$Yeo.7system;
Energy_SubAvg_FPDM <- Energy_SubAvg[which(Yeo_Systems_Index == 6 | Yeo_Systems_Index == 7)];
Activation_2b0b_SubAvg_FPDM <- Activation_2b0b_SubAvg[which(Yeo_Systems_Index == 6 | Yeo_Systems_Index == 7)];
Corr_1_FPDM <- cor.test(Energy_SubAvg_FPDM, Activation_2b0b_SubAvg_FPDM);
data_All <- data.frame(Energy_SubAvg_FPDM = Energy_SubAvg_FPDM, Activation_2b0b_SubAvg_FPDM = Activation_2b0b_SubAvg_FPDM);
ggplot(data_All, aes(x = Energy_SubAvg_FPDM, y = Activation_2b0b_SubAvg_FPDM))+geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

Energy_SubAvg_Others <- Energy_SubAvg[which(Yeo_Systems_Index != 6 & Yeo_Systems_Index != 7)];
Activation_2b0b_SubAvg_Others <- Activation_2b0b_SubAvg[which(Yeo_Systems_Index != 6 & Yeo_Systems_Index != 7)];
Corr_1_Others <- cor.test(Energy_SubAvg_Others, Activation_2b0b_SubAvg_Others); 
data_All <- data.frame(Energy_SubAvg_Others = Energy_SubAvg_Others, Activation_2b0b_SubAvg_Others = Activation_2b0b_SubAvg_Others);
ggplot(data_All, aes(x = Energy_SubAvg_Others, y = Activation_2b0b_SubAvg_Others))+geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

# find regions with significant activation/deactivation
Activation_PValue = matrix(0, 233, 1);
Energy_PValue = matrix(0, 233, 1);
for (i in 1:233)
{
  OneSampleTtest <- t.test(Activation_2b0b[, i], mu = 0);
  Activation_PValue[i] <- OneSampleTtest$p.value;
  OneSampleTtest <- t.test(Energy[, i], mu = 0);
  Energy_PValue[i] <- OneSampleTtest$p.value;
}
Activation_PValue_FDR <- p.adjust(Activation_PValue, 'fdr');
Activation_PValue_Bonf <- p.adjust(Activation_PValue, 'bonferroni');
Energy_PValue_FDR <- p.adjust(Energy_PValue, 'fdr');
Energy_PValue_Bonf <- p.adjust(Energy_PValue, 'bonferroni');  # results indicated that energy of all regions were significant higher than 0

Activation_PValue_FDR_SigIndex <- which(Activation_PValue_FDR < 0.05);
Activation_2b0b_SubAvg_Sig <- Activation_2b0b_SubAvg[Activation_PValue_FDR_SigIndex];
Energy_SubAvg_Sig <- Energy_SubAvg[Activation_PValue_FDR_SigIndex];
Corr_2 = cor.test(Activation_2b0b_SubAvg_Sig, Energy_SubAvg_Sig);
data_All=data.frame(Energy_SubAvg_Sig=Energy_SubAvg_Sig,Activation_2b0b_SubAvg_Sig=Activation_2b0b_SubAvg_Sig);
ggplot(data_All, aes(x=Energy_SubAvg_Sig,y=Activation_2b0b_SubAvg_Sig))+geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

  # Correlate across regions in FP&DM, and then correlate across regions in other systems
Activation_PValue_FDR_SigIndex_FPDM <- which(Activation_PValue_FDR < 0.05 & (Yeo_Systems_Index == 6 | Yeo_Systems_Index == 7));
Activation_2b0b_SubAvg_Sig_FPDM <- Activation_2b0b_SubAvg[Activation_PValue_FDR_SigIndex_FPDM];
Energy_SubAvg_Sig_FPDM <- Energy_SubAvg[Activation_PValue_FDR_SigIndex_FPDM];
Corr_2_FPDM <- cor.test(Activation_2b0b_SubAvg_Sig_FPDM, Energy_SubAvg_Sig_FPDM);
data_All <- data.frame(Energy_SubAvg_Sig_FPDM = Energy_SubAvg_Sig_FPDM, Activation_2b0b_SubAvg_Sig_FPDM = Activation_2b0b_SubAvg_Sig_FPDM);
ggplot(data_All, aes(x=Energy_SubAvg_Sig_FPDM, y=Activation_2b0b_SubAvg_Sig_FPDM))+geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

Activation_PValue_FDR_SigIndex_Others <- which(Activation_PValue_FDR < 0.05 & (Yeo_Systems_Index != 6 & Yeo_Systems_Index != 7));
Activation_2b0b_SubAvg_Sig_Others <- Activation_2b0b_SubAvg[Activation_PValue_FDR_SigIndex_Others];
Energy_SubAvg_Sig_Others <- Energy_SubAvg[Activation_PValue_FDR_SigIndex_Others];
Corr_2_Others <- cor.test(Activation_2b0b_SubAvg_Sig_Others, Energy_SubAvg_Sig_Others);
data_All <- data.frame(Activation_2b0b_SubAvg_Sig_Others = Activation_2b0b_SubAvg_Sig_Others, Energy_SubAvg_Sig_Others = Energy_SubAvg_Sig_Others);
ggplot(data_All, aes(x=Energy_SubAvg_Sig_Others, y=Activation_2b0b_SubAvg_Sig_Others)) + geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

# Bonferroni correction
Activation_PValue_Bonf_SigIndex <- which(Activation_PValue_Bonf < 0.05);
Activation_2b0b_SubAvg_Sig <- Activation_2b0b_SubAvg[Activation_PValue_Bonf_SigIndex];
Energy_SubAvg_Sig <- Energy_SubAvg[Activation_PValue_Bonf_SigIndex];
Corr_3 = cor.test(Activation_2b0b_SubAvg_Sig, Energy_SubAvg_Sig);
data_All=data.frame(Energy_SubAvg_Sig=Energy_SubAvg_Sig,Activation_2b0b_SubAvg_Sig=Activation_2b0b_SubAvg_Sig);
ggplot(data_All, aes(x=Energy_SubAvg_Sig,y=Activation_2b0b_SubAvg_Sig))+geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

  # Correlate across regions in FP&DM, and then correlate across regions in other systems
Activation_PValue_Bonf_SigIndex_FPDM <- which(Activation_PValue_Bonf < 0.05 & (Yeo_Systems_Index == 6 | Yeo_Systems_Index == 7));
Activation_2b0b_SubAvg_Sig_FPDM <- Activation_2b0b_SubAvg[Activation_PValue_Bonf_SigIndex_FPDM];
Energy_SubAvg_Sig_FPDM <- Energy_SubAvg[Activation_PValue_Bonf_SigIndex_FPDM];
Corr_3_FPDM <- cor.test(Activation_2b0b_SubAvg_Sig_FPDM, Energy_SubAvg_Sig_FPDM);
data_All <- data.frame(Energy_SubAvg_Sig_FPDM = Energy_SubAvg_Sig_FPDM, Activation_2b0b_SubAvg_Sig_FPDM = Activation_2b0b_SubAvg_Sig_FPDM);
ggplot(data_All, aes(x=Energy_SubAvg_Sig_FPDM, y=Activation_2b0b_SubAvg_Sig_FPDM))+geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

Activation_PValue_Bonf_SigIndex_Others <- which(Activation_PValue_Bonf < 0.05 & (Yeo_Systems_Index != 6 & Yeo_Systems_Index != 7));
Corr_3_Others <- cor.test(Activation_2b0b_SubAvg_Sig_Others, Energy_SubAvg_Sig_Others);
data_All <- data.frame(Activation_2b0b_SubAvg_Sig_Others = Activation_2b0b_SubAvg_Sig_Others, Energy_SubAvg_Sig_Others = Energy_SubAvg_Sig_Others);
ggplot(data_All, aes(x=Energy_SubAvg_Sig_Others, y=Activation_2b0b_SubAvg_Sig_Others)) + geom_point()+geom_smooth(method=lm)+theme(axis.text=element_text(size=15),axis.title=element_text(size=18))

# Correlation of regional average energy across subjects, regressing out age, sex, handedness, head motion, TBV
# Behaviors
Behavior <- readMat('/data/joy/BBL/projects/pncClinDtiControl/data/subjectData/n1089_Bifactor_DtiMotion_Demogra.mat');
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);
Tissue <- readMat('/data/joy/BBL/projects/pncClinDtiControl/data/subjectData/n1089_ctVol20170412.mat');
Behavior$TBV <- as.numeric(Tissue$TBV);

Behavior_New <- data.frame(Age_years = Behavior$Age_years[RetainIndex]);
Behavior_New$Sex_factor <- Behavior$Sex_factor[RetainIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[RetainIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[RetainIndex];
Behavior_New$TBV <- Behavior$TBV[RetainIndex];

Activation_SigRegionAvg <- rowMeans(Activation_2b0b);
Energy_SigRegionAvg <- rowMeans(Energy);
Activation_Energy_Gam <- gam(Energy_SigRegionAvg ~ s(Age_years, k = 4) + Activation_SigRegionAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

Activation_SigRegionAvg <- rowMeans(Activation_2b0b[, Activation_PValue_Bonf_SigIndex]);
Energy_SigRegionAvg <- rowMeans(Energy[, Activation_PValue_Bonf_SigIndex]);
Activation_Energy_Gam <- gam(Energy_SigRegionAvg ~ s(Age_years, k = 4) + Activation_SigRegionAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

PValue = matrix(0, 233, 1);
for (i in 1:233)
{
  Activation_Energy_Gam <- gam(Energy[, i] ~ s(Age_years, k = 4) + Activation_2b0b[, i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  PValue[i] <- summary(Activation_Energy_Gam)$p.pv[2];
}
PValue = p.adjust(PValue[Activation_PValue_FDR_SigIndex], 'fdr'); # only correct the regions with significant activation under FDR
PValue = p.adjust(PValue[Activation_PValue_Bonf_SigIndex], 'fdr'); # only correct the regions with significant activation under Bonferroni

ResultantFolder <- '/data/joy/BBL/projects/pncClinDtiControl/results/Energy_Analysis/Energy_Activation';
writeMat(paste(ResultantFolder, '/Energy_Activation_SubAvg.mat', sep = ''), Scan_ID = Scan_ID, Energy = Energy, Activation_2b0b = Activation_2b0b, Energy_SubAvg = Energy_SubAvg, Activation_2b0b_SubAvg = Activation_2b0b_SubAvg, Activation_2b0b_SubAvg_Z = Activation_2b0b_SubAvg_Z, Activation_PValue_FDR_SigIndex = Activation_PValue_FDR_SigIndex, Activation_PValue_Bonf_SigIndex = Activation_PValue_Bonf_SigIndex);

 
Energy_RegionAvg = rowMeans(Energy);
PValue = matrix(0, 233, 1);
for (i in 1:233)
{
  Activation_Energy_Gam <- gam(Energy_RegionAvg ~ s(Age_years, k = 4) + Activation_2b0b[, i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  PValue[i] <- summary(Activation_Energy_Gam)$p.pv[2];
}
PValue = p.adjust(PValue[Activation_PValue_FDR_SigIndex], 'fdr');
PValue = p.adjust(PValue[Activation_PValue_Bonf_SigIndex], 'fdr');


Activation_2b0b_RegionAvg = rowMeans(Activation_2b0b);
PValue = matrix(0, 233, 1);
for (i in 1:233)
{
  Activation_Energy_Gam <- gam(Energy[, i] ~ s(Age_years, k = 4) + Activation_2b0b_RegionAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
  PValue[i] <- summary(Activation_Energy_Gam)$p.pv[2];
}
PValue = p.adjust(PValue[Activation_PValue_FDR_SigIndex], 'fdr');
PValue = p.adjust(PValue[Activation_PValue_Bonf_SigIndex], 'fdr');
