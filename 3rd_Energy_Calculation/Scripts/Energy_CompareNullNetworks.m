
clear

Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/energyData/FA_Energy';
Energy_Actual_Mat = load([Folder '/FA_InitialAll0_TargetActivationMean.mat']);
Energy_Actual = mean(Energy_Actual_Mat.Energy, 2);
% Energy with null networks
RepeatQuantity = 20;
Energy_NullNetworks = zeros(949, 1);
for i = 1:RepeatQuantity
  tmp = load([Folder '/FA_InitialAll0_TargetActivationMean_NullNetwork_' num2str(i) '.mat']);
  Energy_NullNetworks = Energy_NullNetworks + mean(tmp.Energy, 2);
end
Energy_NullNetworks = Energy_NullNetworks / RepeatQuantity;
% Compare
[~, P] = ttest(Energy_Actual, Energy_NullNetworks)
Energy_Actual_Mean = mean(Energy_Actual)
Energy_NullNetworks_Mean = mean(Energy_NullNetworks)
