
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

Energy_Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData';
Energy_Mat_Path <- paste(Energy_Data_Folder, '/SC_Energy/SC_InitialDM1_TargetActi_Con3456_ScaleEig.mat', sep = '/');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

Behavior <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_Demogra_DtiMotion.mat');
Behavior$Age_years <- as.numeric(Behavior$Age/12);
Behavior$Sex_factor <- cut(Behavior$Sex, 2, labels = c("Male", "Female"));
Behavior$Sex_order <- cut(Behavior$Sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$HandednessV2 <- as.factor(Behavior$HandednessV2);
Behavior$MotionMeanRelRMS <- as.numeric(Behavior$MotionMeanRelRMS);

Tissue <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_ctVol20170412.mat');
Behavior$TBV <- as.numeric(Tissue$TBV);

Cognition <- readMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_cnb_factor_scores_tymoore_20151006.mat');
#Behavior$OverallAccuracy <- Cognition$OverallAccuracy;
#Behavior$OverallAccuracyAr <- Cognition$OverallAccuracyAr;

NANIndex = as.matrix(which(!is.na(Cognition$OverallAccuracy)));
Behavior_New <- data.frame(Age_years = Behavior$Age_years[NANIndex]);
Behavior_New$Sex_factor <- Behavior$Sex_factor[NANIndex];
Behavior_New$Sex_order <- Behavior$Sex_order[NANIndex];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[NANIndex];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NANIndex];
Behavior_New$TBV <- Behavior$TBV[NANIndex];
Behavior_New$OverallAccuracy <- Cognition$OverallAccuracy[NANIndex];
Behavior_New$OverallAccuracyAr <- Cognition$OverallAccuracyAr[NANIndex];
Behavior_New$OverallEfficiency <- Cognition$OverallEfficiency[NANIndex];
Behavior_New$OverallSpeed <- Cognition$OverallSpeed[NANIndex];
Behavior_New$F1ExecCompResAccuracy <- Cognition$F1ExecCompResAccuracy[NANIndex];
Behavior_New$F2SocialCogAccuracy <- Cognition$F2SocialCogAccuracy[NANIndex];
Behavior_New$F3MemoryAccuracy <- Cognition$F3MemoryAccuracy[NANIndex];
Behavior_New$F1ComplexReasoningEfficiency <- Cognition$F1ComplexReasoningEfficiency[NANIndex];
Behavior_New$F2MemoryEfficiency <- Cognition$F2MemoryEfficiency[NANIndex];
Behavior_New$F3ExecutiveEfficiency <- Cognition$F3ExecutiveEfficiency[NANIndex];
Behavior_New$F4SocialCognitionEfficiency <- Cognition$F4SocialCognitionEfficiency[NANIndex];
Behavior_New$F1SlowSpeed <- Cognition$F1SlowSpeed[NANIndex];
Behavior_New$F2FastSpeed <- Cognition$F2FastSpeed[NANIndex];
Behavior_New$F3MemorySpeed <- Cognition$F3MemorySpeed[NANIndex];

# Analysis of the whole brain average energy
Index <- which(Energy[1,] != 0);
WholeBrainAvg <- rowMeans(Energy[,Index]);
WholeBrainAvg <- WholeBrainAvg[NANIndex];
# energy and overall accuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + OverallAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "OverallAccuracy", xlab = "Cognition", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# energy vs. OverallEfficiency
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + OverallEfficiency + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "OverallEfficiency", xlab = "Overall Efficiency", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# energy vs. OverallSpeed
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + OverallSpeed + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

# energy vs. F1ExecCompResAccuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F1ExecCompResAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F1ExecCompResAccuracy", xlab = "F1ExecCompResAccuracy", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# energy vs. F2SocialCogAccuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F2SocialCogAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F2SocialCogAccuracy", xlab = "F2SocialCogAccuracy", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# energy vs. F3MemoryAccuracy
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F3MemoryAccuracy + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F3MemoryAccuracy", xlab = "F3MemoryAccuracy", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# energy vs. F1ComplexReasoningEfficiency
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F1ComplexReasoningEfficiency + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F1ComplexReasoningEfficiency", xlab = "F1ComplexReasoningEfficiency", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# energy vs. F2MemoryEfficiency
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F2MemoryEfficiency + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F2MemoryEfficiency", xlab = "F2MemoryEfficiency", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
  
# energy vs. F3ExecutiveEfficiency
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F3ExecutiveEfficiency + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
visreg(Gam_WholeBrainAvg, "F3ExecutiveEfficiency", xlab = "F3ExecutiveEfficiency", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));

# energy vs. F4SocialCognitionEfficiency
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F4SocialCognitionEfficiency + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

# energy vs. F1SlowSpeed
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F1SlowSpeed + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

# energy vs. F2FastSpeed
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F2FastSpeed + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);

# energy vs. F3MemorySpeed
Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k = 4) + F3MemorySpeed + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior_New);
    
