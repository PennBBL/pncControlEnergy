
clear

Replication_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
AgeEffect_Mat = load([Replication_Folder '/results/FA_Energy/InitialAll0_TargetMeanActivation_EnergyDivideActivation/Energy_Gam_Age_NodalLevel.mat']);
NodalZ = AgeEffect_Mat.Age_Z;

Activation_Mat = load([Replication_Folder '/data/Activation_677_Avg.mat']);
Mean_NodalActivation = Activation_Mat.Activation_677_Avg;

Energy_Mat = load([Replication_Folder '/data/energyData/FA_Energy/FA_InitialAll0_TargetActivationMean.mat']);
Mean_NodalEnergy = mean(Energy_Mat.Energy_New);

corr(NodalZ, Mean_NodalActivation)
corr(NodalZ, Mean_NodalEnergy')

Decreasing_Index = find(AgeEffect_Mat.Age_Z < 0 & AgeEffect_Mat.Age_P_FDR < 0.05);
Increasing_Index = find(AgeEffect_Mat.Age_Z > 0 & AgeEffect_Mat.Age_P_FDR < 0.05);
mean(Mean_NodalActivation(Decreasing_Index))
[m n]=ttest(Mean_NodalActivation(Decreasing_Index))
mean(Mean_NodalActivation(Increasing_Index))
[m n]=ttest(Mean_NodalActivation(Increasing_Index))

