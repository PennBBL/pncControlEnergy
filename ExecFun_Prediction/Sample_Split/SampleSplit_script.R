
library(R.matlab)

Data_Folder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
Behavior_Mat = readMat(paste(Data_Folder, '/Behavior.mat', sep = ''));
Energy_Mat = readMat(paste(Data_Folder, '/Energy.mat', sep = ''));
SampleIndex_Mat = readMat(paste(Data_Folder, '/SampleIndex.mat', sep = ''));
Sample1_Index = SampleIndex_Mat$Sample1.Index;
Sample2_Index = SampleIndex_Mat$Sample2.Index;

Energy_Sample1 = Energy_Mat$Energy[Sample1_Index,];
Energy_Sample2 = Energy_Mat$Energy[Sample2_Index,];

OverallAccuracy_Sample1 = Behavior_Mat$OverallAccuracy[Sample1_Index];
OverallAccuracy_Sample2 = Behavior_Mat$OverallAccuracy[Sample2_Index];

writeMat(paste(Data_Folder, '/Energy_Sample1.mat', sep = ''), Energy_Sample1 = Energy_Sample1);
writeMat(paste(Data_Folder, '/Energy_Sample2.mat', sep = ''), Energy_Sample2 = Energy_Sample2);
writeMat(paste(Data_Folder, '/OverallAccuracy_Sample1.mat', sep = ''), OverallAccuracy_Sample1 = OverallAccuracy_Sample1);
writeMat(paste(Data_Folder, '/OverallAccuracy_Sample2.mat', sep = ''), OverallAccuracy_Sample2 = OverallAccuracy_Sample2);

Age_Sample1 = Behavior_Mat$Age.years[Sample1_Index];
TBV_Sample1 = Behavior_Mat$TBV[Sample1_Index];
Age_Sample2 = Behavior_Mat$Age.years[Sample2_Index];
TBV_Sample2 = Behavior_Mat$TBV[Sample2_Index];

EnergyAge_Sample1 = cbind(Energy_Sample1, Age_Sample1);
EnergyAge_Sample2 = cbind(Energy_Sample2, Age_Sample2);
writeMat(paste(Data_Folder, '/EnergyAge_Sample1.mat', sep = ''), EnergyAge_Sample1 = EnergyAge_Sample1);
writeMat(paste(Data_Folder, '/EnergyAge_Sample2.mat', sep = ''), EnergyAge_Sample2 = EnergyAge_Sample2);

EnergyTBV_Sample1 = cbind(Energy_Sample1, TBV_Sample1);
EnergyTBV_Sample2 = cbind(Energy_Sample2, TBV_Sample2);
writeMat(paste(Data_Folder, '/EnergyTBV_Sample1.mat', sep = ''), EnergyTBV_Sample1 = EnergyTBV_Sample1);
writeMat(paste(Data_Folder, '/EnergyTBV_Sample2.mat', sep = ''), EnergyTBV_Sample2 = EnergyTBV_Sample2);

EnergyAgeTBV_Sample1 = cbind(Energy_Sample1, Age_Sample1, TBV_Sample1);
EnergyAgeTBV_Sample2 = cbind(Energy_Sample2, Age_Sample2, TBV_Sample2);
writeMat(paste(Data_Folder, '/EnergyAgeTBV_Sample1.mat', sep = ''), EnergyAgeTBV_Sample1 = EnergyAgeTBV_Sample1);
writeMat(paste(Data_Folder, '/EnergyAgeTBV_Sample2.mat', sep = ''), EnergyAgeTBV_Sample2 = EnergyAgeTBV_Sample2);

MeanEnergy_Sample1 = rowMeans(Energy_Sample1);
MeanEnergy_Sample2 = rowMeans(Energy_Sample2);
writeMat(paste(Data_Folder, '/MeanEnergy_Sample1.mat', sep = ''), MeanEnergy_Sample1 = MeanEnergy_Sample1);
writeMat(paste(Data_Folder, '/MeanEnergy_Sample2.mat', sep = ''), MeanEnergy_Sample2 = MeanEnergy_Sample2);

MeanEnergyAge_Sample1 = cbind(MeanEnergy_Sample1, Age_Sample1);
MeanEnergyAge_Sample2 = cbind(MeanEnergy_Sample2, Age_Sample2);
writeMat(paste(Data_Folder, '/MeanEnergyAge_Sample1.mat', sep = ''), MeanEnergyAge_Sample1 = MeanEnergyAge_Sample1);
writeMat(paste(Data_Folder, '/MeanEnergyAge_Sample2.mat', sep = ''), MeanEnergyAge_Sample2 = MeanEnergyAge_Sample2);

MeanEnergyTBV_Sample1 = cbind(MeanEnergy_Sample1, TBV_Sample1);
MeanEnergyTBV_Sample2 = cbind(MeanEnergy_Sample2, TBV_Sample2);
writeMat(paste(Data_Folder, '/MeanEnergyTBV_Sample1.mat', sep = ''), MeanEnergyTBV_Sample1 = MeanEnergyTBV_Sample1);
writeMat(paste(Data_Folder, '/MeanEnergyTBV_Sample2.mat', sep = ''), MeanEnergyTBV_Sample2 = MeanEnergyTBV_Sample2);

MeanEnergyAgeTBV_Sample1 = cbind(MeanEnergy_Sample1, Age_Sample1, TBV_Sample1);
MeanEnergyAgeTBV_Sample2 = cbind(MeanEnergy_Sample2, Age_Sample2, TBV_Sample2);
writeMat(paste(Data_Folder, '/MeanEnergyAgeTBV_Sample1.mat', sep = ''), MeanEnergyAgeTBV_Sample1 = MeanEnergyAgeTBV_Sample1);
writeMat(paste(Data_Folder, '/MeanEnergyAgeTBV_Sample2.mat', sep = ''), MeanEnergyAgeTBV_Sample2 = MeanEnergyAgeTBV_Sample2);

AgeTBV_Sample1 = cbind(Age_Sample1, TBV_Sample1);
AgeTBV_Sample2 = cbind(Age_Sample2, TBV_Sample2);
writeMat(paste(Data_Folder, '/AgeTBV_Sample1.mat', sep = ''), AgeTBV_Sample1 = AgeTBV_Sample1);
writeMat(paste(Data_Folder, '/AgeTBV_Sample2.mat', sep = ''), AgeTBV_Sample2 = AgeTBV_Sample2);
