
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationDataFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';

Energy_Mat = readMat(paste0(ReplicationDataFolder, '/energyData/InitialAll0_TargetActivationMean.mat'));
Energy = Energy_Mat$Energy.New;
###############################################
# Import demographics, cognition and strength #
###############################################
# Demographics, motion, TBV
AllInfo <- read.csv(paste0(ReplicationDataFolder, '/n949_Behavior_20180522.csv'));
ScanID <- AllInfo$scanid;
Age <- AllInfo$ageAtScan1;
Sex <- AllInfo$sex;
HandednessV2 <- AllInfo$handednessv2;
MotionMeanRelRMS <- AllInfo$dti64MeanRelRMS;
TBV <- AllInfo$mprage_antsCT_vol_TBV;
F1_Exec_Comp_Res_Accuracy <- AllInfo$F1_Exec_Comp_Res_Accuracy;
overall_psychopathology_4factorv2 <- AllInfo$overall_psychopathology_4factorv2;
StrengthInfo <- readMat(paste0(ReplicationDataFolder, '/WholeBrainStrength_FA_949.mat'));
Strength_EigNorm_SubIden <- StrengthInfo$WholeBrainStrength.EigNorm.SubIden;

dir.create(paste0(ReplicationDataFolder, '/AgePrediction'));
writeMat(paste0(ReplicationDataFolder, '/AgePrediction/Energy_Behavior_AllSubjects.mat'), Energy = Energy, Age = Age, Sex = Sex, HandednessV2 = HandednessV2, MotionMeanRelRMS = MotionMeanRelRMS, TBV = TBV, Strength_EigNorm_SubIden = Strength_EigNorm_SubIden, ScanID = ScanID);

