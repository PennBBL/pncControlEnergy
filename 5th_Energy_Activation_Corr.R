
library(R.matlab)
library(mgcv)

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

EnergyFolder <- paste0(ReplicationFolder, '/data/energyData/FA_Energy');
Energy_Mat <- readMat(paste0(EnergyFolder, '/FA_InitialAll0_TargetActivationMean.mat'));
Energy_Mat$scan.ID <- as.numeric(Energy_Mat$scan.ID);
Activation_677_Mat <- readMat('/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/Activation_677_Avg.mat');

indice = matrix(0, 677, 1)
for (i in c(1:677))
{
  indice[i] = match(Activation_677_Mat$scan.ID.Activation[i], Energy_Mat$scan.ID);
}
Energy_677 = Energy_Mat$Energy.New[indice,];

# Behavior data
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/BehaviorData/n949_Behavior_20180522.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$Age_years <- as.numeric(AllInfo$ageAtScan1);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of FA-weighted network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/WholeBrainStrength/Strength_FA_949.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$Strength.EigNorm.SubIden);
NodalStrength_EigNorm_SubIden <- as.numeric(StrengthInfo$NodalStrength.EigNorm.SubIden);

Behavior_New <- data.frame(Sex_factor = Behavior$Sex_factor[indice]);
Behavior_New$Age_years <- Behavior$Age_years[indice];
Behavior_New$HandednessV2 <- Behavior$HandednessV2[indice];
Behavior_New$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[indice];
Behavior_New$TBV <- Behavior$TBV[indice];
Behavior_New$Strength_EigNorm_SubIden <- Strength_EigNorm_SubIden[indice];

# Nodal level
P_Activation_Energy = matrix(0, 233, 1);
for (i in c(1:233))
{
  tmp_Activation <- Activation_677_Mat$Activation.677[,i];
  tmp_Energy <- Energy_677[,i];
  Gam_Energy_Activation <- gam(tmp_Energy ~ tmp_Activation + s(Age_years, k = 4) + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior_New);
  P_Activation_Energy[i] <- summary(Gam_Energy_Activation)$p.table[2,4];
}
P_Activation_Energy_fdr <- p.adjust(P_Activation_Energy, "fdr");

# Whole brain average level
Energy_WholeBrainAvg <- rowMeans(Energy_677);
Activation_WholeBrainAvg <- rowMeans(Activation_677_Mat$Activation.677);
Gam_Energy_Activation_WholeBrain <- gam(Energy_WholeBrainAvg ~ Activation_WholeBrainAvg + s(Age_years, k = 4) + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior_New);
P_Activation_Energy_WholeBrain <- summary(Gam_Energy_Activation_WholeBrain)$p.table[2,4];

# Yeo system level
Yeo_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_System <- Yeo_Mat$Yeo.7system;
Energy_Yeo <- matrix(0, 233, 8);
Activation_Yeo <- matrix(0, 233, 8);
P_Activation_Energy_Yeo = matrix(0, 8, 1);
for (i in c(1:8))
{
  System_indices <- which(Yeo_System == i);
  Energy_Yeo <- rowMeans(Energy_677[, System_indices])
  Activation_Yeo <- rowMeans(Activation_677_Mat$Activation.677[, System_indices]);
  Gam_Energy_Activation_Yeo <- gam(Energy_Yeo ~ Activation_Yeo + s(Age_years, k = 4) + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior_New);
  P_Activation_Energy_Yeo[i] <- summary(Gam_Energy_Activation_Yeo)$p.table[2,4];
}
P_Activation_Energy_Yeo_fdr <- p.adjust(P_Activation_Energy_Yeo, "fdr");
