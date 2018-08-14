
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

