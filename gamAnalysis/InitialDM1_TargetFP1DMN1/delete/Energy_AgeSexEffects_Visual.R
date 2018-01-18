
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

Energy_Data_Folder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetVisual1DMN1.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;

Behavior <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);

tmp <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
Behavior$TBV <- as.numeric(tmp$TBV);

# Analysis of the whole brain average energy
WholeBrainAvg <- rowMeans(Energy);
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

Gam_WholeBrainAvg_Inter <- gam(WholeBrainAvg ~ s(Age_years, by = Sex_order, k = 4) + s(Age_years, k = 4) + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);

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

ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/Development_Effects/NodalLevel';
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3], Age_P_Bonf = Energy_Gam_Age[, 4]);
Energy_Gam_Sex_CSV <- file.path(ResultantFolder, 'Energy_Gam_Sex.csv');
write.csv(Energy_Gam_Sex, Energy_Gam_Sex_CSV);
Energy_Gam_Sex_Mat <- file.path(ResultantFolder, 'Energy_Gam_Sex.mat');
writeMat(Energy_Gam_Sex_Mat, Sex_Z = Energy_Gam_Sex[, 1], Sex_P = Energy_Gam_Sex[, 2], Sex_P_FDR = Energy_Gam_Sex[, 3], Sex_P_Bonf = Energy_Gam_Sex[, 4]);

