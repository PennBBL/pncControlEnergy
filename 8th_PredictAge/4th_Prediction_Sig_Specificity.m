
PredictionResultsFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/results/FA_Energy/Age_Prediction';
PredictionDataFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/AgePrediction';
BehaviorMat = [PredictionDataFolder '/Behavior.mat'];
SampleIndexMat = [PredictionDataFolder '/SampleIndex_SplitHalf.mat'];
% Sample 1 predict sample 2
ActualPath = [PredictionResultsFolder '/Sample1_Predict_Sample2/APredictB.mat'];
tmp = load(ActualPath);
Test_Score = tmp.Test_Score;
Predict_Score = tmp.Predict_Score;
ActualCorr = tmp.Predict_Corr;
ActualMAE = tmp.Predict_MAE;
RandomCell = g_ls([PredictionResultsFolder '/Sample1_Predict_Sample2_Permutation/*/APredictB.mat']);
for i = 1:length(RandomCell)
  tmp = load(RandomCell{i});
  RandomCorr(i) = tmp.Predict_Corr;
  RandomMAE(i) = tmp.Predict_MAE;
end
Corr_Sig = length(find(RandomCorr >= ActualCorr)) / 1000;
MAE_Sig = length(find(RandomMAE <= ActualMAE)) / 1000;
save([PredictionResultsFolder '/Sig_Sample1PredictSample2.mat'], 'Corr_Sig', 'MAE_Sig', 'ActualCorr', 'ActualMAE', 'RandomCorr', 'RandomMAE');
% Specificity
Behavior = load(BehaviorMat);
load(SampleIndexMat);
Sex = Behavior.Sex(Sample2_Index);
Handedness = Behavior.HandednessV2(Sample2_Index);
TBV = Behavior.TBV(Sample2_Index);
Motion = Behavior.MotionMeanRelRMS(Sample2_Index);
Strength = Behavior.Strength_EigNorm_SubIden(Sample2_Index);
Activation_Mean = Behavior.Activation_Mean(Sample2_Index); 
[partialR, P] = partialcorr(double(Test_Score'), double(Predict_Score'), [TBV Strength Motion double(Handedness) double(Sex) Activation_Mean]);

% Sample 2 predict sample 1
ActualPath = [PredictionResultsFolder '/Sample2_Predict_Sample1/APredictB.mat'];
tmp = load(ActualPath);
Test_Score = tmp.Test_Score;
Predict_Score = tmp.Predict_Score;
ActualCorr = tmp.Predict_Corr;
ActualMAE = tmp.Predict_MAE;
RandomCell = g_ls([PredictionResultsFolder '/Sample2_Predict_Sample1_Permutation/*/APredictB.mat']);
for i = 1:length(RandomCell)
  tmp = load(RandomCell{i});
  RandomCorr(i) = tmp.Predict_Corr;
  RandomMAE(i) = tmp.Predict_MAE;
end
Corr_Sig = length(find(RandomCorr >= ActualCorr)) / 1000;
MAE_Sig = length(find(RandomMAE <= ActualMAE)) / 1000;
save([PredictionResultsFolder '/Sig_Sample2PredictSample1.mat'], 'Corr_Sig', 'MAE_Sig', 'ActualCorr', 'ActualMAE', 'RandomCorr', 'RandomMAE');
% Specificity
Sex = Behavior.Sex(Sample1_Index);
Handedness = Behavior.HandednessV2(Sample1_Index);
TBV = Behavior.TBV(Sample1_Index);
Motion = Behavior.MotionMeanRelRMS(Sample1_Index);
Strength = Behavior.Strength_EigNorm_SubIden(Sample1_Index);
Activation_Mean = Behavior.Activation_Mean(Sample1_Index);
[partialR, P] = partialcorr(double(Test_Score'), double(Predict_Score'), [TBV Strength Motion double(Handedness) double(Sex) Activation_Mean]);


