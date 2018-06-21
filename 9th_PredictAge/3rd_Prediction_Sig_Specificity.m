
clear

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
AgePrediction_ResFolder = [ReplicationFolder '/results/Age_Prediction/2Fold_Sort'];
Prediction_Fold0 = load([AgePrediction_ResFolder '/Fold_0_Score.mat']);
Corr_Actual_Fold0 = Prediction_Fold0.Corr;
MAE_Actual_Fold0 = Prediction_Fold0.MAE;
Index_Fold0 = Prediction_Fold0.Index + 1;
Prediction_Fold1 = load([AgePrediction_ResFolder '/Fold_1_Score.mat']);
Corr_Actual_Fold1 = Prediction_Fold1.Corr;
MAE_Actual_Fold1 = Prediction_Fold1.MAE;
Index_Fold1 = Prediction_Fold1.Index + 1;
%% Significance
AgePrediction_PermutationFolder = [ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Permutation'];
% Fold 0
Permutation_Fold0_Cell = g_ls([AgePrediction_PermutationFolder '/Time_*/Fold_0_Score.mat']);
for i = 1:1000
  tmp = load(Permutation_Fold0_Cell{i});
  Corr_Rand_Fold0(i) = tmp.Corr;
  MAE_Rand_Fold0(i) = tmp.MAE;
end
Corr_Fold0_Sig = length(find(Corr_Rand_Fold0 >= Corr_Actual_Fold0)) / 1000;
MAE_Fold0_Sig = length(find(MAE_Rand_Fold0 <= MAE_Actual_Fold0)) / 1000;
save([ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Fold0_Sig.mat'], 'Corr_Actual_Fold0', 'MAE_Actual_Fold0', 'Corr_Rand_Fold0', 'MAE_Rand_Fold0', 'Corr_Fold0_Sig', 'MAE_Fold0_Sig');
% Fold 1
Permutation_Fold1_Cell = g_ls([AgePrediction_PermutationFolder '/Time_*/Fold_1_Score.mat']);
for i = 1:1000
  tmp = load(Permutation_Fold1_Cell{i});
  Corr_Rand_Fold1(i) = tmp.Corr;
  MAE_Rand_Fold1(i) = tmp.MAE;
end
Corr_Fold1_Sig = length(find(Corr_Rand_Fold1 >= Corr_Actual_Fold1)) / 1000;
MAE_Fold1_Sig = length(find(MAE_Rand_Fold1 <= MAE_Actual_Fold1)) / 1000;
save([ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Fold1_Sig.mat'], 'Corr_Actual_Fold1', 'MAE_Actual_Fold1', 'Corr_Rand_Fold1', 'MAE_Rand_Fold1', 'Corr_Fold1_Sig', 'MAE_Fold1_Sig');

%% Specificity
Behavior = load([ReplicationFolder '/data/Age_Prediction/Energy_Behavior_AllSubjects.mat']);
% Fold 0
Sex_Fold0 = Behavior.Sex(Index_Fold0);
Age_Fold0 = Behavior.Age(Index_Fold0);
HandednessV2_Fold0 = Behavior.HandednessV2(Index_Fold0);
MotionMeanRelRMS_Fold0 = Behavior.MotionMeanRelRMS(Index_Fold0);
TBV_Fold0 = Behavior.TBV(Index_Fold0);
Strength_EigNorm_SubIden_Fold0 = Behavior.Strength_EigNorm_SubIden(Index_Fold0);
partialcorr(Prediction_Fold0.Predict_Score', double(Prediction_Fold0.Test_Score'), [double(Sex_Fold0) double(HandednessV2_Fold0) MotionMeanRelRMS_Fold0 TBV_Fold0 Strength_EigNorm_SubIden_Fold0])
% Fold 1
Sex_Fold1 = Behavior.Sex(Index_Fold1);
Age_Fold1 = Behavior.Age(Index_Fold1);
HandednessV2_Fold1 = Behavior.HandednessV2(Index_Fold1);
MotionMeanRelRMS_Fold1 = Behavior.MotionMeanRelRMS(Index_Fold1);
TBV_Fold1 = Behavior.TBV(Index_Fold1);
Strength_EigNorm_SubIden_Fold1 = Behavior.Strength_EigNorm_SubIden(Index_Fold1);
partialcorr(Prediction_Fold1.Predict_Score', double(Prediction_Fold1.Test_Score'), [double(Sex_Fold1) double(HandednessV2_Fold1) MotionMeanRelRMS_Fold1 TBV_Fold1 Strength_EigNorm_SubIden_Fold1])
