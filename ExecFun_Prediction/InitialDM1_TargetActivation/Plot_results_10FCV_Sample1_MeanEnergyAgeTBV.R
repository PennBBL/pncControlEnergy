
library(R.matlab);
library(ggplot2);

Ridge_10FCV_Folder <- '/Users/zaixucui/Documents/projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_10FCV_MeanEnergyAgeTBV/';
Fold_0_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_0_Score.mat'));
Fold_1_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_1_Score.mat'));
Fold_2_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_2_Score.mat'));
Fold_3_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_3_Score.mat'));
Fold_4_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_4_Score.mat'));
Fold_5_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_5_Score.mat'));
Fold_6_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_6_Score.mat'));
Fold_7_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_7_Score.mat'));
Fold_8_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_8_Score.mat'));
Fold_9_Mat <- readMat(file.path(Ridge_10FCV_Folder, 'Fold_9_Score.mat'));

Test_Score <- rbind(t(Fold_0_Mat$Test.Score), t(Fold_1_Mat$Test.Score), t(Fold_2_Mat$Test.Score), t(Fold_3_Mat$Test.Score), t(Fold_4_Mat$Test.Score), t(Fold_5_Mat$Test.Score), t(Fold_6_Mat$Test.Score), t(Fold_7_Mat$Test.Score), t(Fold_8_Mat$Test.Score), t(Fold_9_Mat$Test.Score));
Predict_Score <- rbind(t(Fold_0_Mat$Predict.Score), t(Fold_1_Mat$Predict.Score), t(Fold_2_Mat$Predict.Score), t(Fold_3_Mat$Predict.Score), t(Fold_4_Mat$Predict.Score), t(Fold_5_Mat$Predict.Score), t(Fold_6_Mat$Predict.Score), t(Fold_7_Mat$Predict.Score), t(Fold_8_Mat$Predict.Score), t(Fold_9_Mat$Predict.Score));
Fold_Label <- rbind(matrix(0, length(Fold_0_Mat$Test.Score), 1), matrix(1, length(Fold_1_Mat$Test.Score), 1), matrix(2, length(Fold_2_Mat$Test.Score), 1), matrix(3, length(Fold_3_Mat$Test.Score), 1), matrix(4, length(Fold_4_Mat$Test.Score), 1), matrix(5, length(Fold_5_Mat$Test.Score), 1), 
   matrix(6, length(Fold_6_Mat$Test.Score), 1), matrix(7, length(Fold_7_Mat$Test.Score), 1), matrix(8, length(Fold_8_Mat$Test.Score), 1), matrix(9, length(Fold_9_Mat$Test.Score), 1));

All_Data = data.frame(Test_Score = Test_Score, Predict_Score = Predict_Score, Fold_Label = Fold_Label);
All_Data$Fold_Label = as.factor(All_Data$Fold_Label);
ggplot(All_Data, aes(x = Test_Score, y = Predict_Score, color = Fold_Label, shape = Fold_Label)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20))
