
clear

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
AgePrediction_ResFolder = [ReplicationFolder '/results/FA_Energy/Age_Prediction/2Fold_OverallPsycho'];
Prediction_Fold0 = load([AgePrediction_ResFolder '/Fold_0_Score.mat']);
Index_Fold0 = Prediction_Fold0.Index + 1;
Prediction_Fold1 = load([AgePrediction_ResFolder '/Fold_1_Score.mat']);
Index_Fold1 = Prediction_Fold1.Index + 1;
Prediction_Fold2 = load([AgePrediction_ResFolder '/Fold_2_Score.mat']);
Index_Fold2 = Prediction_Fold2.Index + 1;
Behavior = load([ReplicationFolder '/data/AgePrediction/Energy_FA_AllSubjects.mat']);
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
% Fold 2
Sex_Fold2 = Behavior.Sex(Index_Fold2);
Age_Fold2 = Behavior.Age(Index_Fold2);
HandednessV2_Fold2 = Behavior.HandednessV2(Index_Fold2);
MotionMeanRelRMS_Fold2 = Behavior.MotionMeanRelRMS(Index_Fold2);
TBV_Fold2 = Behavior.TBV(Index_Fold2);
Strength_EigNorm_SubIden_Fold2 = Behavior.Strength_EigNorm_SubIden(Index_Fold2);
partialcorr(Prediction_Fold2.Predict_Score', double(Prediction_Fold2.Test_Score'), [double(Sex_Fold2) double(HandednessV2_Fold2) MotionMeanRelRMS_Fold2 TBV_Fold2 Strength_EigNorm_SubIden_Fold2])

