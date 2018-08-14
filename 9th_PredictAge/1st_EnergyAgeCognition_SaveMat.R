
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationDataFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';

Energy_Mat = readMat(paste0(ReplicationDataFolder, '/energyData/InitialAll0_TargetFP.mat'));
Energy = Energy_Mat$Energy;
###############################################
# Import demographics, cognition and strength #
###############################################
# Demographics, motion, TBV
AllInfo <- read.csv(paste0(ReplicationDataFolder, '/n946_Behavior_20180807.csv'));
ScanID <- AllInfo$scanid;
Age <- AllInfo$ageAtScan1/12;
Sex <- AllInfo$sex;
HandednessV2 <- AllInfo$handednessv2;
MotionMeanRelRMS <- AllInfo$dti64MeanRelRMS;
TBV <- AllInfo$mprage_antsCT_vol_TBV;
StrengthInfo <- readMat(paste0(ReplicationDataFolder, '/WholeBrainStrength_Prob_946.mat'));
Strength_EigNorm_SubIden <- StrengthInfo$WholeBrainStrength.EigNorm.SubIden;

dir.create(paste0(ReplicationDataFolder, '/Age_Prediction'));
writeMat(paste0(ReplicationDataFolder, '/Age_Prediction/Energy_Behavior_AllSubjects.mat'), Energy = Energy, Age = Age, Sex = Sex, HandednessV2 = HandednessV2, MotionMeanRelRMS = MotionMeanRelRMS, TBV = TBV, Strength_EigNorm_SubIden = Strength_EigNorm_SubIden, ScanID = ScanID);

