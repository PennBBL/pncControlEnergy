
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

#######################################################################
########## Individualized activation as each specific target ##########
#######################################################################

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

Energy_Data_Folder = paste(ReplicationFolder, '/data/energyData', sep = '');
Parameters <- c(0.1, 0.2, 0.5, 0.8, 2, 5, 8, 10);
for (i in c(1:8)){
  Para_Str <- as.character(Parameters[i]);
  if (i < 5){
    Para_Str <- paste(substr(Para_Str, 1, 1), substr(Para_Str, 3, 3), sep = '');
  }
  Energy_Mat_Path <- paste(Energy_Data_Folder, '/FA_Energy/FA_InitialAll0_TargetActivation_T_', Para_Str, '.mat', sep = '');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;
  # Nodal level
  
  # Yeo system level
  Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
}

for (i in c(1:8)){
  Para_Str <- as.character(Parameters[i]);
  if (i < 5){
    Para_Str <- paste(substr(Para_Str, 1, 1), substr(Para_Str, 3, 3), sep = '');
  }
  Energy_Mat_Path <- paste(Energy_Data_Folder, '/FA_Energy/FA_InitialAll0_TargetActivation_rho_', Para_Str, '.mat', sep = '');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;
  WholeBrainAvg <- rowMeans(Energy);
  Gam_WholeBrainAvg <- gam(WholeBrainAvg ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
} 

###############################################
########## Mean activation as target ##########
###############################################

# Import behavior
AllInfo <- read.csv(paste(ReplicationFolder, '/data/BehaviorData/n949_Behavior_20180316.csv', sep = ''));
Behavior <- data.frame(Sex_factor = cut(AllInfo$sex, 2, labels = c("Male", "Female")));
Behavior$Sex_order <- cut(AllInfo$sex, 2, labels = c("Male", "Female"), ordered_result = TRUE);
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);

# Whole brain strength
StrengthInfo <- readMat(paste(ReplicationFolder, '/data/WholeBrainStrength/Strength_FA_949.mat', sep = ''));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$Strength.EigNorm.SubIden);


