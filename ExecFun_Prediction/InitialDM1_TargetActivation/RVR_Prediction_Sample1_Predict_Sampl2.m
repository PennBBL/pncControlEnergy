
DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
load([DataFolder '/MeanEnergyAgeTBV_Sample1.mat']);
load([DataFolder '/MeanEnergyAgeTBV_Sample2.mat']);

load([DataFolder '/OverallAccuracy_Sample1.mat']);
load([DataFolder '/OverallAccuracy_Sample2.mat']);

ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/RVR_Sample1_Predict_Sample2_MeanEnergyAgeTBV';
RVR_APredictB(MeanEnergyAgeTBV_Sample1, OverallAccuracy_Sample1', MeanEnergyAgeTBV_Sample2, OverallAccuracy_Sample2', [], [], 'Scale', 0, 0, ResultantFolder);
% % Permutation
% ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/RVR_Sample1_Predict_Sample2_MeanEnergyAgeTBV_Permutation';
% mkdir(ResultantFolder);
% for i = 1:1000
%     i
%     ResultantFolder_I = [ResultantFolder '/Time_' num2str(i)];
%     mkdir(ResultantFolder_I);
%     RandIndex = randperm(length(OverallAccuracy_Sample1));
%     OverallAccuracy_Sample1_Rand = OverallAccuracy_Sample1(RandIndex);
%     RVR_APredictB(MeanEnergyAgeTBV_Sample1, OverallAccuracy_Sample1_Rand', MeanEnergyAgeTBV_Sample2, OverallAccuracy_Sample2', [], [], 'Scale', 0, 0, ResultantFolder_I);
% end
% 
% load([DataFolder '/SampleIndex.mat']);
% Behavior = load([DataFolder '/Behavior.mat']);
% Age_Sample1 = Behavior.Age_years(Sample1_Index);
% Age_Sample2 = Behavior.Age_years(Sample2_Index);
% Motion_Sample1 = Behavior.MotionMeanRelRMS(Sample1_Index);
% Motion_Sample2 = Behavior.MotionMeanRelRMS(Sample2_Index);
% TBV_Sample1 = Behavior.TBV(Sample1_Index);
% TBV_Sample2 = Behavior.TBV(Sample2_Index);
% Covariates_Sample1 = [Age_Sample1 Motion_Sample1 TBV_Sample1];
% Covariates_Sample2 = [Age_Sample2 Motion_Sample2 TBV_Sample2];
% ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/RVR_Sample1_Predict_Sample2_MeanEnergyAgeTBV_Cov';
% RVR_APredictB(MeanEnergyAgeTBV_Sample1, OverallAccuracy_Sample1', MeanEnergyAgeTBV_Sample2, OverallAccuracy_Sample2', Covariates_Sample1, Covariates_Sample2, 'Scale', 0, 0, ResultantFolder);
% ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/RVR_Sample1_Predict_Sample2_MeanEnergyAgeTBV_Cov_Permutation';
% mkdir(ResultantFolder);
% for i = 1:1000
%     i
%     ResultantFolder_I = [ResultantFolder '/Time_' num2str(i)];
%     mkdir(ResultantFolder_I);
%     RandIndex = randperm(length(OverallAccuracy_Sample1));
%     OverallAccuracy_Sample1_Rand = OverallAccuracy_Sample1(RandIndex);
%     RVR_APredictB(MeanEnergyAgeTBV_Sample1, OverallAccuracy_Sample1_Rand', MeanEnergyAgeTBV_Sample2, OverallAccuracy_Sample2', Covariates_Sample1, Covariates_Sample2, 'Scale', 0, 0, ResultantFolder_I);
% end

% load([DataFolder '/MeanEnergy_Sample1.mat']);
% load([DataFolder '/MeanEnergy_Sample2.mat']);
% ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/RVR_Sample1_Predict_Sample2_MeanEnergy_Cov';
% RVR_APredictB(MeanEnergy_Sample1, OverallAccuracy_Sample1', MeanEnergy_Sample2, OverallAccuracy_Sample2', Covariates_Sample1, Covariates_Sample2, 'Scale', 0, 0, ResultantFolder);
% ResultantFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/RVR_Sample1_Predict_Sample2_MeanEnergy_Cov_Permutation';
% mkdir(ResultantFolder);
% for i = 1:1000
%     i
%     ResultantFolder_I = [ResultantFolder '/Time_' num2str(i)];
%     mkdir(ResultantFolder_I);
%     RandIndex = randperm(length(OverallAccuracy_Sample1));
%     OverallAccuracy_Sample1_Rand = OverallAccuracy_Sample1(RandIndex);
%     RVR_APredictB(MeanEnergy_Sample1, OverallAccuracy_Sample1_Rand', MeanEnergy_Sample2, OverallAccuracy_Sample2', Covariates_Sample1, Covariates_Sample2, 'Scale', 0, 0, ResultantFolder_I);
% end


% 
% RVR_APredictB(MeanEnergyAgeTBV_Sample1, OverallAccuracy_Sample1', MeanEnergyAgeTBV_Sample2, OverallAccuracy_Sample2', Covariates_Sample1, Covariates_Sample2, 'Scale', 0, 0, ResultantFolder);

% load([DataFolder '/EnergyAgeTBV_Sample1.mat']);
% load([DataFolder '/EnergyAgeTBV_Sample2.mat']);
% RVR_APredictB(EnergyAgeTBV_Sample1, OverallAccuracy_Sample1', EnergyAgeTBV_Sample2, OverallAccuracy_Sample2', Covariates_Sample1, Covariates_Sample2, 'Scale', 0, 0, ResultantFolder);

% load([DataFolder '/Energy_Sample1.mat']);
% load([DataFolder '/Energy_Sample2.mat']);
% RVR_APredictB(Energy_Sample1, OverallAccuracy_Sample1', Energy_Sample2, OverallAccuracy_Sample2', Covariates_Sample1, Covariates_Sample2, 'Scale', 0, 0, ResultantFolder);
% 
% RVR_APredictB(Energy_Sample1, OverallAccuracy_Sample1', Energy_Sample2, OverallAccuracy_Sample2', [], [], 'Scale', 0, 0, ResultantFolder);
