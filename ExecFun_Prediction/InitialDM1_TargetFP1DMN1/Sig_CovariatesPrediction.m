
Prediction_ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_3FCV';
Fold_0_Mat = load([Prediction_ResultantFolder '/Fold_0_Score.mat']);
Fold_0_Index = Fold_0_Mat.Index + 1;
Fold_0_Predict = Fold_0_Mat.Predict_Score';
Fold_1_Mat = load([Prediction_ResultantFolder '/Fold_1_Score.mat']);
Fold_1_Index = Fold_1_Mat.Index + 1;
Fold_1_Predict = Fold_1_Mat.Predict_Score';
Fold_2_Mat = load([Prediction_ResultantFolder '/Fold_2_Score.mat']);
Fold_2_Index = Fold_2_Mat.Index + 1;
Fold_2_Predict = Fold_2_Mat.Predict_Score';
Behavior_Mat_Path = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction/Behavior.mat';
Behavior_Mat = load(Behavior_Mat_Path);
% Age
Age_years = Behavior_Mat.Age_years;
Age_Fold0_Corr = corr(Fold_0_Predict, Age_years(Fold_0_Index));
Age_Fold1_Corr = corr(Fold_1_Predict, Age_years(Fold_1_Index));
Age_Fold2_Corr = corr(Fold_2_Predict, Age_years(Fold_2_Index));
% Motion
Motion = Behavior_Mat.MotionMeanRelRMS;
Motion_Fold0_Corr = corr(Fold_0_Predict, Motion(Fold_0_Index));
Motion_Fold1_Corr = corr(Fold_1_Predict, Motion(Fold_1_Index));
Motion_Fold2_Corr = corr(Fold_2_Predict, Motion(Fold_2_Index));
% TBV
TBV = Behavior_Mat.TBV;
TBV_Fold0_Corr = corr(Fold_0_Predict, TBV(Fold_0_Index));
TBV_Fold1_Corr = corr(Fold_1_Predict, TBV(Fold_1_Index));
TBV_Fold2_Corr = corr(Fold_2_Predict, TBV(Fold_2_Index));

Permutation_Folder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_3FCV_Permutation';
PermuRes_Fold0_Cell = g_ls([Permutation_Folder '/*/Fold_0_Score.mat']);
PermuRes_Fold1_Cell = g_ls([Permutation_Folder '/*/Fold_1_Score.mat']);
PermuRes_Fold2_Cell = g_ls([Permutation_Folder '/*/Fold_2_Score.mat']);
PermutationTimes = length(PermuRes_Fold0_Cell);
for i = 1:PermutationTimes
  disp(i);
  Fold_0_Mat = load(PermuRes_Fold0_Cell{i});
  Fold_0_Index = Fold_0_Mat.Index + 1;
  Fold_0_Predict = Fold_0_Mat.Predict_Score';

  Fold_1_Mat = load(PermuRes_Fold1_Cell{i});
  Fold_1_Index = Fold_1_Mat.Index + 1;
  Fold_1_Predict = Fold_1_Mat.Predict_Score';

  Fold_2_Mat = load(PermuRes_Fold2_Cell{i});
  Fold_2_Index = Fold_2_Mat.Index + 1;
  Fold_2_Predict = Fold_2_Mat.Predict_Score';

  % Age
  Age_Fold0_Corr_Rand(i) = corr(Fold_0_Predict, Age_years(Fold_0_Index));
  Age_Fold1_Corr_Rand(i) = corr(Fold_1_Predict, Age_years(Fold_1_Index));
  Age_Fold2_Corr_Rand(i) = corr(Fold_2_Predict, Age_years(Fold_2_Index));
  % Motion
  Motion_Fold0_Corr_Rand(i) = corr(Fold_0_Predict, Motion(Fold_0_Index));
  Motion_Fold1_Corr_Rand(i) = corr(Fold_1_Predict, Motion(Fold_1_Index));
  Motion_Fold2_Corr_Rand(i) = corr(Fold_2_Predict, Motion(Fold_2_Index));
  % TBV
  TBV_Fold0_Corr_Rand(i) = corr(Fold_0_Predict, TBV(Fold_0_Index));
  TBV_Fold1_Corr_Rand(i) = corr(Fold_1_Predict, TBV(Fold_1_Index));
  TBV_Fold2_Corr_Rand(i) = corr(Fold_2_Predict, TBV(Fold_2_Index));
end
% Age
Age_Fold0_Corr_Sig = length(find(Age_Fold0_Corr_Rand > Age_Fold0_Corr)) / PermutationTimes;
Age_Fold1_Corr_Sig = length(find(Age_Fold1_Corr_Rand > Age_Fold1_Corr)) / PermutationTimes;
Age_Fold2_Corr_Sig = length(find(Age_Fold2_Corr_Rand > Age_Fold2_Corr)) / PermutationTimes;
% Motion
Motion_Fold0_Corr_Sig = length(find(Motion_Fold0_Corr_Rand > Motion_Fold0_Corr)) / PermutationTimes;
Motion_Fold1_Corr_Sig = length(find(Motion_Fold1_Corr_Rand > Motion_Fold1_Corr)) / PermutationTimes;
Motion_Fold2_Corr_Sig = length(find(Motion_Fold2_Corr_Rand > Motion_Fold2_Corr)) / PermutationTimes;
% TBV
TBV_Fold0_Corr_Sig = length(find(TBV_Fold0_Corr_Rand > TBV_Fold0_Corr)) / PermutationTimes;
TBV_Fold1_Corr_Sig = length(find(TBV_Fold1_Corr_Rand > TBV_Fold1_Corr)) / PermutationTimes;
TBV_Fold2_Corr_Sig = length(find(TBV_Fold2_Corr_Rand > TBV_Fold2_Corr)) / PermutationTimes;
save /data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Permutation_Sig_AgeMotionTBV.mat ...
Age_Fold0_Corr Age_Fold1_Corr Age_Fold2_Corr Motion_Fold0_Corr Motion_Fold1_Corr Motion_Fold2_Corr ...
TBV_Fold0_Corr TBV_Fold1_Corr TBV_Fold2_Corr Age_Fold0_Corr_Sig Age_Fold1_Corr_Sig Age_Fold2_Corr_Sig ...
Motion_Fold0_Corr_Sig Motion_Fold1_Corr_Sig Motion_Fold2_Corr_Sig TBV_Fold0_Corr_Sig TBV_Fold1_Corr_Sig TBV_Fold2_Corr_Sig;
