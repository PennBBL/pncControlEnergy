
Results_Folder = '/Users/zaixucui/Documents/Projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/';
Actual_Mat = load([Results_Folder '/Ridge_Sample1_Predict_Sample2_MeanEnergyAgeTBV/APredictB.mat']);
Permutation_Cell = g_ls([Results_Folder '/Ridge_Sample1_Predict_Sample2_MeanEnergyAgeTBV_Permutation/Time_*/APredictB.mat']);

Data_Folder = '/Users/zaixucui/Documents/Projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
load([Data_Folder '/SampleIndex.mat']);
load([Data_Folder '/Behavior.mat']);
Age_Sample2 = Age_years(Sample2_Index);
TBV_Sample2 = TBV(Sample2_Index);
Motion_Sample2 = MotionMeanRelRMS(Sample2_Index);

for i = 1:length(Permutation_Cell)
    tmp = load(Permutation_Cell{i});
    Corr_Rand(i) = tmp.Predict_Corr;
    MAE_Rand(i) = tmp.Predict_MAE;
    ParCorr_Rand(i) = partialcorr(tmp.Predict_Score', tmp.Test_Score', [Age_Sample2 TBV_Sample2]);
end
figure;
hist(ParCorr_Rand);

Permutation_Cell = g_ls([Results_Folder '/Ridge_Sample1_Predict_Sample2_EnergyAgeTBV_Permutation/Time_*/APredictB.mat']);
for i = 1:length(Permutation_Cell)
    tmp = load(Permutation_Cell{i});
    Corr_Rand(i) = tmp.Predict_Corr;
    MAE_Rand(i) = tmp.Predict_MAE;
end
figure;
hist(Corr_Rand);
figure;
hist(MAE_Rand);

