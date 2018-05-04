
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationDataFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';

Energy_Mat = readMat(paste(ReplicationDataFolder, '/energyData/volNormSC_Energy/volNormSC_InitialAll0_TargetIndividualActivationZScore.mat', sep = ''));
Energy = Energy_Mat$Energy;
dir.create(paste(ReplicationDataFolder, '/AgePrediction/volNormSC_Energy', sep = ''));
writeMat(paste(ReplicationDataFolder, '/AgePrediction/volNormSC_Energy/Energy.mat', sep = ''), Energy = Energy);
###################
# Import strength #
###################
# Whole brain strength of volNormSC-weighted network
StrengthInfo <- readMat(paste(ReplicationDataFolder, '/WholeBrainStrength/Strength_volNormSC_803.mat', sep = ''));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$Strength.EigNorm.SubIden);
writeMat(paste(ReplicationDataFolder, '/AgePrediction/volNormSC_Energy/Strength_EigNorm_SubIden.mat', sep = ''), Strength_EigNorm_SubIden = Strength_EigNorm_SubIden);
