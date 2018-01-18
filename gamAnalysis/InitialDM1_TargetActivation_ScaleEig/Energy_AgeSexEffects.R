
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

Energy_Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetActivation_ScaleEig.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

Behavior <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);

tmp <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
Behavior$TBV <- as.numeric(tmp$TBV);

# Analysis of the whole brain average energy
WholeBrainAvg <- rowMeans(Energy);
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# As age effect is significant, do bootstrap to validate this effect
  # Bootstrap: sample subjects in replacement
  # Bootstrap indicated the 95% interval is [2.18e-08,0.067]
Subjects_ID <- c(1:949);
PValue_Bootstrap = matrix(0, 1000, 1);
for (i in 1:1000)
{
  print(i);
  Sample_Index <- sample(Subjects_ID, 949, replace=TRUE);
  WholeBrainAvg_Bootstrap <- WholeBrainAvg[Sample_Index]; 
  Behavior_Bootstrap <- data.frame(Sex_factor = Behavior$Sex_factor[Sample_Index]);
  Behavior_Bootstrap$Age_years <- Behavior$Age_years[Sample_Index];
  Behavior_Bootstrap$HandednessV2 <- Behavior$HandednessV2[Sample_Index];
  Behavior_Bootstrap$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[Sample_Index];
  Behavior_Bootstrap$TBV <- Behavior$TBV[Sample_Index];
  Gam_WholeBrainAvg_Bootstrap <- gam(WholeBrainAvg_Bootstrap ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_Bootstrap);
  PValue_Bootstrap[i] = summary(Gam_WholeBrainAvg_Bootstrap)$s.table[4];
}
# Display sex effect (not significant)
visreg(Gam_WholeBrainAvg, "Sex_factor", xlab = "Sex", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

Gam_WholeBrainAvg_Inter <- gam(WholeBrainAvg ~ s(Age_years, by = Sex_order, k = 4) + s(Age_years, k = 4) + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg_Inter, "Age_years", by = "Sex_order", overlay = TRUE, xlab = "Age (years)", ylab = "Whole brain average energy");
visreg(Gam_WholeBrainAvg_Inter, "Age_years", by = "Sex_order", overlay = TRUE, partial = FALSE, xlab = "Age (years)", ylab = "Whole brain average energy");

# Analysis of age & sex effect on nodal energy
dimension <- dim(Energy);
RegionsQuantity <- dimension[2];
RowName <- character(length = RegionsQuantity);
for (i in 1:RegionsQuantity)
{
  RowName[i] = paste("Node", as.character(i));
}
ColName <- c("Z", "P", "P_FDR", "P_Bonf");
Energy_Gam_Age <- matrix(c(1:RegionsQuantity*4), nrow = RegionsQuantity, ncol = 4, dimnames = list(RowName, ColName));
Energy_Gam_Sex <- matrix(c(1:RegionsQuantity*4), nrow = RegionsQuantity, ncol = 4, dimnames = list(RowName, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  Energy_Gam <- gam(Energy[, i] ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_Age[i, c(1:2)] <- summary(Energy_Gam)$s.table[, 3:4];
  Energy_Gam_Sex[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Sex[i, 2] <- summary(Energy_Gam)$p.pv[2];
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
Energy_Gam_Sex[, 3] <- p.adjust(Energy_Gam_Sex[, 2], "fdr");
Energy_Gam_Age[, 4] <- p.adjust(Energy_Gam_Age[, 2], "bonferroni");
Energy_Gam_Sex[, 4] <- p.adjust(Energy_Gam_Sex[, 2], "bonferroni");

ResultantFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetActivation_ScaleEig/Development_Effects/NodalLevel';
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3], Age_P_Bonf = Energy_Gam_Age[, 4]);
Energy_Gam_Sex_CSV <- file.path(ResultantFolder, 'Energy_Gam_Sex.csv');
write.csv(Energy_Gam_Sex, Energy_Gam_Sex_CSV);
Energy_Gam_Sex_Mat <- file.path(ResultantFolder, 'Energy_Gam_Sex.mat');
writeMat(Energy_Gam_Sex_Mat, Sex_Z = Energy_Gam_Sex[, 1], Sex_P = Energy_Gam_Sex[, 2], Sex_P_FDR = Energy_Gam_Sex[, 3], Sex_P_Bonf = Energy_Gam_Sex[, 4]);

# Interaction effect between age & sex on nodal energy
Energy_Gam_AgeSexInter <- matrix(c(1:RegionsQuantity*4), nrow = RegionsQuantity, ncol = 4, dimnames = list(RowName, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  tmp_variable <- Energy[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, by = Sex_order, k = 4) + s(Age_years, k = 4) + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_AgeSexInter[i, c(1:2)] <- summary(Energy_Gam)$s.table[1, 3:4];
  #visreg(Energy_Gam, "Age_years", by = "Sex_order", overlay = TRUE, xlab = "Age (years)", ylab = "Energy");
}
Energy_Gam_AgeSexInter[, 3] <- p.adjust(Energy_Gam_AgeSexInter[, 2], "fdr");
Energy_Gam_AgeSexInter[, 4] <- p.adjust(Energy_Gam_AgeSexInter[, 2], "bonferroni");
Energy_Gam_AgeSexInter_CSV <- file.path(ResultantFolder, 'Energy_Gam_AgeSexInter.csv');
write.csv(Energy_Gam_AgeSexInter, Energy_Gam_AgeSexInter_CSV);
Energy_Gam_AgeSexInter_Mat <- file.path(ResultantFolder, 'Energy_Gam_AgeSexInter.mat');
writeMat(Energy_Gam_AgeSexInter_Mat, AgeSexInter_Z = Energy_Gam_AgeSexInter[, 1], AgeSexInter_P = Energy_Gam_AgeSexInter[, 2], AgeSexInter_P_FDR = Energy_Gam_AgeSexInter[, 3], AgeSexInter_P_Bonf = Energy_Gam_AgeSexInter[, 4]);

# Age, sex and interaction effect on yeo system average energy
SystemsQuantity = 8;
RowName = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*4), nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName, ColName));
Energy_Gam_Sex_YeoAvg <- matrix(c(1:SystemsQuantity*4), nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName, ColName));
Energy_Gam_AgeSexInter_YeoAvg <- matrix(c(1:SystemsQuantity*4), nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName, ColName));
for (i in 1:SystemsQuantity)
{
  print(i);
  Energy_Gam <- gam(Energy_YeoAvg[, i] ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, c(1:2)] <- summary(Energy_Gam)$s.table[, 3:4];
  Energy_Gam_Sex_YeoAvg[i, 1] <- summary(Energy_Gam)$p.t[2];
  Energy_Gam_Sex_YeoAvg[i, 2] <- summary(Energy_Gam)$p.pv[2];
  Energy_Gam <- gam(Energy_YeoAvg[, i] ~ s(Age_years, by = Sex_order, k = 4) + s(Age_years, k = 4) + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_AgeSexInter_YeoAvg[i, c(1:2)] <- summary(Energy_Gam)$s.table[1, 3:4];
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
Energy_Gam_Sex_YeoAvg[, 3] <- p.adjust(Energy_Gam_Sex_YeoAvg[, 2], "fdr");
Energy_Gam_AgeSexInter_YeoAvg[, 3] <- p.adjust(Energy_Gam_AgeSexInter_YeoAvg[, 2], "fdr");
Energy_Gam_Age_YeoAvg[, 4] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "bonferroni");
Energy_Gam_Sex_YeoAvg[, 4] <- p.adjust(Energy_Gam_Sex_YeoAvg[, 2], "bonferroni");
Energy_Gam_AgeSexInter_YeoAvg[, 4] <- p.adjust(Energy_Gam_AgeSexInter_YeoAvg[, 2], "bonferroni");
ResultantFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetActivation_ScaleEig/Development_Effects/YeoSystemLevel';
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3], Age_P_Bonf = Energy_Gam_Age_YeoAvg[, 4]);
Energy_Gam_Sex_CSV <- file.path(ResultantFolder, 'Energy_Gam_Sex_YeoAvg.csv');
write.csv(Energy_Gam_Sex_YeoAvg, Energy_Gam_Sex_CSV);
Energy_Gam_Sex_Mat <- file.path(ResultantFolder, 'Energy_Gam_Sex_YeoAvg.mat');
writeMat(Energy_Gam_Sex_Mat, Sex_Z = Energy_Gam_Sex_YeoAvg[, 1], Sex_P = Energy_Gam_Sex_YeoAvg[, 2], Sex_P_FDR = Energy_Gam_Sex_YeoAvg[, 3], Sex_P_Bonf = Energy_Gam_Sex_YeoAvg[, 4]);
Energy_Gam_AgeSexInter_CSV <- file.path(ResultantFolder, 'Energy_Gam_AgeSexInter_YeoAvg.csv');
write.csv(Energy_Gam_AgeSexInter_YeoAvg, Energy_Gam_AgeSexInter_CSV);
Energy_Gam_AgeSexInter_Mat <- file.path(ResultantFolder, 'Energy_Gam_AgeSexInter_YeoAvg.mat');
writeMat(Energy_Gam_AgeSexInter_Mat, AgeSexInter_Z = Energy_Gam_AgeSexInter_YeoAvg[, 1], AgeSexInter_P = Energy_Gam_AgeSexInter_YeoAvg[, 2], AgeSexInter_P_FDR = Energy_Gam_AgeSexInter_YeoAvg[, 3], AgeSexInter_P_Bonf = Energy_Gam_AgeSexInter_YeoAvg[, 4]);
