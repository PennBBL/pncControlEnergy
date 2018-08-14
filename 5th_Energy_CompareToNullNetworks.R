
library(R.matlab)
library(ggplot2)

Folder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/energyData';
Energy_Actual_Mat <- readMat(paste0(Folder, '/InitialAll0_TargetFP.mat'));
Energy_Actual <- Energy_Actual_Mat$Energy;
Energy_Actual_WholeBrainAvg <- rowMeans(Energy_Actual);

RepeatQuantity <- 3;
Energy_NullNetworks = matrix(0, 946, 232);
Energy_NullNetworks_WholeBrainAvg = matrix(0, 946, 1);
for (i in 1:3)
{
  tmp <- readMat(paste0(Folder, '/NullNetworks/InitialAll0_TargetFP_NullNetwork_', as.character(i), '.mat'));
  Energy_NullNetworks = Energy_NullNetworks + tmp$Energy;
  Energy_NullNetworks_WholeBrainAvg = Energy_NullNetworks_WholeBrainAvg + rowMeans(tmp$Energy);
}
Energy_NullNetworks = Energy_NullNetworks / RepeatQuantity;
Energy_NullNetworks_WholeBrainAvg = Energy_NullNetworks_WholeBrainAvg / RepeatQuantity;

# Compare the whole brain average energy between actual networks and null networks (paired t-test)
Res <- t.test(Energy_Actual_WholeBrainAvg, Energy_NullNetworks_WholeBrainAvg, paired = TRUE);
print(Res$p.value);
print(mean(Energy_Actual_WholeBrainAvg));
print(mean(Energy_NullNetworks_WholeBrainAvg));



