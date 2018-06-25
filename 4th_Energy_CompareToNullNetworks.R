
library(R.matlab)
library(ggplot2)

Folder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/energyData';
Energy_Actual_Mat <- readMat(paste0(Folder, '/InitialAll0_TargetActivationMean.mat'));
Yeo_Mat <- readMat('/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/Yeo_7system.mat');
Yeo_Systems <- Yeo_Mat$Yeo.7system;
Energy_Actual <- Energy_Actual_Mat$Energy.New;
Energy_Actual_WholeBrainAvg <- rowMeans(Energy_Actual);

RepeatQuantity <- 100;
Energy_NullNetworks = matrix(0, 949, 233);
Energy_NullNetworks_WholeBrainAvg = matrix(0, 949, 1);
for (i in 1:100)
{
  tmp <- readMat(paste0(Folder, '/NullNetworks/InitialAll0_TargetActivationMean_NullNetwork_', as.character(i), '.mat'));
  Energy_NullNetworks = Energy_NullNetworks + tmp$Energy.New;
  Energy_NullNetworks_WholeBrainAvg = Energy_NullNetworks_WholeBrainAvg + rowMeans(tmp$Energy.New);
}
Energy_NullNetworks = Energy_NullNetworks / RepeatQuantity;
Energy_NullNetworks_WholeBrainAvg = Energy_NullNetworks_WholeBrainAvg / RepeatQuantity;

# Compare the whole brain average energy between actual networks and null networks (paired t-test)
Res <- t.test(Energy_Actual_WholeBrainAvg, Energy_NullNetworks_WholeBrainAvg, paired = TRUE);
print(Res$p.value);
print(mean(Energy_Actual_WholeBrainAvg));
print(mean(Energy_NullNetworks_WholeBrainAvg));

# Compare energy between actual and null networks for each node (paired t-test)
P_Value <- matrix(0, 233, 1);
T_Value <- matrix(0, 233, 1);
for (i in 1:233)
{
  tmp <- t.test(Energy_Actual[, i], Energy_NullNetworks[, i], paired = TRUE);
  P_Value[i] <- tmp$p.value;
  T_Value[i] <- tmp$statistic;
}
P_Value_FDR <- p.adjust(P_Value, 'fdr');
SmallerThanNull_Index <- which(T_Value < 0 & P_Value_FDR < 0.05);
writeMat('/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/SmallerThanNull_Index.mat', SmallerThanNull_Index = SmallerThanNull_Index, T_Value = T_Value);


