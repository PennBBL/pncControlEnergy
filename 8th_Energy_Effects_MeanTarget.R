
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

########## Mean activation as target ##########
##########        Age effect         ##########
###############################################
Energy_Mat_Path = paste(ReplicationFolder, '/data/energyData/FA_Energy/FA_InitialAll0_TargetMeanActivationZScore.mat', sep = '');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

# Visualize energy for each system
Yeo_atlas <- readMat(paste(ReplicationFolder, '/data/Yeo_7system.mat', sep = ''));
Energy_SubjectsAvg <- colMeans(Energy);
tmp <- data.frame(Energy_data = log(Energy_SubjectsAvg), Yeo = Yeo_atlas$Yeo.7system);
tmp$Yeo <- factor(tmp$Yeo, levels = c(1:8), labels = c("Visual","SM", "DA", "VA", "limbic","FP","DM","SC"));
qplot(Yeo, Energy_data, data = tmp, geom=c("boxplot","jitter"), fill=Yeo, xlab="Yeo systems", ylab="Energy") + ggtitle("Initial All 0; Target activation") + theme(plot.title = element_text(hjust = 0.5));

# Distance effect
Energy_WholeBrainAvg <- rowMeans(Energy);
Distance <- as.numeric(Energy_Mat$Distance.sum);
# Correlation between energy and distance
cor.test(as.vector(Distance), as.vector(Energy_WholeBrainAvg));
NodeAvg = data.frame(Distance = as.vector(Distance));
NodeAvg$Energy = as.vector(Energy_WholeBrainAvg);
ggplot(NodeAvg, aes(x = Energy, y = Distance)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20));

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

ResultantFolder <- paste(ReplicationFolder, '/results/FA_Energy/InitialAll0_TargetActivation', sep = '');
dir.create(ResultantFolder, recursive = TRUE);
# Age effect of nodal energy
dimension <- dim(Energy);
RegionsQuantity <- dimension[2];
RowName_Nodal <- character(length = RegionsQuantity);
for (i in 1:RegionsQuantity)
{
  RowName_Nodal[i] = paste("Node", as.character(i));
}
ColName <- c("Z", "P", "P_FDR");
Energy_Gam_Age <- matrix(c(1:RegionsQuantity*3), nrow = RegionsQuantity, ncol = 3, dimnames = list(RowName_Nodal, ColName));
for (i in 1:RegionsQuantity)
{
  print(i);
  tmp_variable <- Energy[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
  }
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.csv');
write.csv(Energy_Gam_Age, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age[, 1], Age_P = Energy_Gam_Age[, 2], Age_P_FDR = Energy_Gam_Age[, 3]);

# Age effect of yeo system average energy
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
ColName <- c("Z", "P", "P_FDR");
Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }
  #visreg(Energy_Gam, "Age_years", xlab = "Age (years)", ylab = paste("Average energy ",RowName[i],sep=''), gg = TRUE) + theme(text=element_text(size=20));
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);

#####################################################################################################
####    Specificity analysis: we hypothesized the age effect is specific to executive function   ####
####    So with target of FP 1, other systems 0, the energy should have significant age effect   ####
#### With target of Visual 1, other systems 0, the age effect of energy should not be signficiant####
#####################################################################################################
############################
## Target: FP 1, others 0 ##
############################
Energy_Mat_Path = paste(ReplicationFolder, '/data/energyData/FA_Energy/FA_InitialAll0_TargetFP1.mat', sep = '');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;
Energy_WholeBrainAvg <- rowMeans(Energy);
# whole-brain level
Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(Age_years, k = 4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# Yeo-system level
ResultantFolder <- paste(ReplicationFolder, '/results/FA_Energy/InitialAll0_TargetFP1', sep = '');
dir.create(ResultantFolder, recursive = TRUE);
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
ColName <- c("Z", "P", "P_FDR");
Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4]; 
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }
  #visreg(Energy_Gam, "Age_years", xlab = "Age (years)", ylab = paste("Average energy ",RowName[i],sep=''), gg = TRUE) + theme(text=element_text(size=20));
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);
################################
## Target: Visual 1, others 0 ##
################################
Energy_Mat_Path = paste(ReplicationFolder, '/data/energyData/FA_Energy/FA_InitialAll0_TargetVisual1.mat', sep = '');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;
Energy_WholeBrainAvg <- rowMeans(Energy);
# whole-brain level
Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(Age_years, k = 4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
visreg(Gam_WholeBrainAvg, "Age_years", xlab = "Age (years)", ylab = "Whole brain average energy", gg = TRUE) + theme(text=element_text(size=20));
# Yeo-system level
ResultantFolder <- paste(ReplicationFolder, '/results/FA_Energy/InitialAll0_TargetVisual1', sep = '');
dir.create(ResultantFolder, recursive = TRUE);
SystemsQuantity = 8;
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
ColName <- c("Z", "P", "P_FDR");
Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*3), nrow = SystemsQuantity, ncol = 3, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  print(i);
  tmp_variable <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(tmp_variable ~ s(Age_years, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4]; 
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(tmp_variable ~ Age_years + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }
  #visreg(Energy_Gam, "Age_years", xlab = "Age (years)", ylab = paste("Average energy ",RowName[i],sep=''), gg = TRUE) + theme(text=element_text(size=20));
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoAvg.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3]);
