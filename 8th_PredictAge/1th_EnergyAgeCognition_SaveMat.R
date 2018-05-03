
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationDataFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';

Energy_Mat = readMat(paste(ReplicationDataFolder, '/energyData/FA_Energy/FA_InitialAll0_TargetIndividualActivationZScore.mat', sep = ''));
Energy = Energy_Mat$Energy;
###############################################
# Import demographics, cognition and strength #
###############################################
# Demographics, motion, TBV
AllInfo <- read.csv(paste(ReplicationDataFolder, '/BehaviorData/n803_Behavior_20180321.csv', sep = ''));
Sex <- AllInfo$sex;
Age <- AllInfo$ageAtScan1;
HandednessV2 <- AllInfo$handednessv2;
MotionMeanRelRMS <- AllInfo$dti64MeanRelRMS;
TBV <- AllInfo$mprage_antsCT_vol_TBV;
F1ExecCompResAccuracy <- AllInfo$F1_Exec_Comp_Res_Accuracy;
# Whole brain strength of FA-weighted network
StrengthInfo <- readMat(paste(ReplicationDataFolder, '/WholeBrainStrength/Strength_FA_803.mat', sep = ''));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$Strength.EigNorm.SubIden);
# Activation 
Activation_Path <- paste(ReplicationDataFolder, '/Activation_803.mat', sep = '');
tmp <- readMat(Activation_Path);
Activation_Mean <- rowMeans(tmp$Activation.2b0b);

dir.create(paste(ReplicationDataFolder, '/AgePrediction', sep = ''));
writeMat(paste(ReplicationDataFolder, '/AgePrediction/Energy.mat', sep = ''), Energy = Energy);
writeMat(paste(ReplicationDataFolder, '/AgePrediction/Behavior.mat', sep = ''), Sex = Sex, Age = Age, HandednessV2 = HandednessV2, MotionMeanRelRMS = MotionMeanRelRMS, TBV = TBV, F1ExecCompResAccuracy = F1ExecCompResAccuracy, Strength_EigNorm_SubIden = Strength_EigNorm_SubIden, Activation_Mean = Activation_Mean);
