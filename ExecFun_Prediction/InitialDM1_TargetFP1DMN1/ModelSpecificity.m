
ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_3FCV';
Fold_0_Res = load([ResultantFolder '/Fold_0_Score.mat']);
Fold_1_Res = load([ResultantFolder '/Fold_1_Score.mat']);
Fold_2_Res = load([ResultantFolder '/Fold_2_Score.mat']);

Behavior_Mat = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction/Behavior.mat';
Behavior = load(Behavior_Mat);
OverallAccuracy = Behavior.OverallAccuracy;
Age_years = Behavior.Age_years;
MotionMeanRelRMS = Behavior.MotionMeanRelRMS;
TBV = Behavior.TBV;

Fold_0_Index = Fold_0_Res.Index + 1;
Fold_0_Predict = Fold_0_Res.Predict_Score';
corr(Fold_0_Predict, OverallAccuracy(Fold_0_Index))
partialcorr([Fold_0_Predict OverallAccuracy(Fold_0_Index)], [Age_years(Fold_0_Index) MotionMeanRelRMS(Fold_0_Index) TBV(Fold_0_Index)])
partialcorr([Fold_0_Predict OverallAccuracy(Fold_0_Index)], [Age_years(Fold_0_Index) TBV(Fold_0_Index)])
corr(Fold_0_Predict, Age_years(Fold_0_Index))
corr(Fold_0_Predict, MotionMeanRelRMS(Fold_0_Index))
corr(Fold_0_Predict, TBV(Fold_0_Index))

Fold_1_Index = Fold_1_Res.Index + 1;
Fold_1_Predict = Fold_1_Res.Predict_Score';
corr(Fold_1_Predict, OverallAccuracy(Fold_1_Index))
partialcorr([Fold_1_Predict OverallAccuracy(Fold_1_Index)], [Age_years(Fold_1_Index) MotionMeanRelRMS(Fold_1_Index) TBV(Fold_1_Index)])
partialcorr([Fold_1_Predict OverallAccuracy(Fold_1_Index)], [Age_years(Fold_1_Index) TBV(Fold_1_Index)])
corr(Fold_1_Predict, Age_years(Fold_1_Index))
corr(Fold_1_Predict, MotionMeanRelRMS(Fold_1_Index))
corr(Fold_1_Predict, TBV(Fold_1_Index))

Fold_2_Index = Fold_2_Res.Index + 1;
Fold_2_Predict = Fold_2_Res.Predict_Score';
corr(Fold_2_Predict, OverallAccuracy(Fold_2_Index))
partialcorr([Fold_2_Predict OverallAccuracy(Fold_2_Index)], [Age_years(Fold_2_Index) MotionMeanRelRMS(Fold_2_Index) TBV(Fold_2_Index)])
partialcorr([Fold_2_Predict OverallAccuracy(Fold_2_Index)], [Age_years(Fold_2_Index) TBV(Fold_2_Index)])
corr(Fold_2_Predict, Age_years(Fold_2_Index))
corr(Fold_2_Predict, MotionMeanRelRMS(Fold_2_Index))
corr(Fold_2_Predict, TBV(Fold_2_Index))
