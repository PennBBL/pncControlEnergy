
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

Energy_Data_Folder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetActivation.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Distance <- rowSums(Energy_Mat$Distance[,501:1001]);

Behavior <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);

tmp <- readMat('/Users/zaixucui/Documents/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
Behavior$TBV <- as.numeric(tmp$TBV);

# Analysis of the whole brain average energy
Gam_Distance <- gam(Distance ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_Distance, "Age_years", xlab = "Age (years)", ylab = "Distance", gg = TRUE) + theme(text=element_text(size=20));
# Display sex effect (not significant)
visreg(Gam_Distance, "Sex_factor", xlab = "Sex", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

Gam_Distance_Inter <- gam(Distance ~ s(Age_years, by = Sex_order, k = 4) + s(Age_years, k = 4) + Sex_order + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
visreg(Gam_Distance_Inter, "Age_years", by = "Sex_order", overlay = TRUE, xlab = "Age (years)", ylab = "Whole brain average energy");
visreg(Gam_Distance_Inter, "Age_years", by = "Sex_order", overlay = TRUE, partial = FALSE, xlab = "Age (years)", ylab = "Whole brain average energy");

