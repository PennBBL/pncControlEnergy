
library(R.matlab);
library(ggplot2);

Ridge_3FCV_Folder <- '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_3FCV_AgeTBVMeanEnergy_FPDM';
Fold_0_Mat <- readMat(file.path(Ridge_3FCV_Folder, 'Fold_0_Score.mat'));
Fold_1_Mat <- readMat(file.path(Ridge_3FCV_Folder, 'Fold_1_Score.mat'));
Fold_2_Mat <- readMat(file.path(Ridge_3FCV_Folder, 'Fold_2_Score.mat'));

Test_Score <- rbind(t(Fold_0_Mat$Test.Score), t(Fold_1_Mat$Test.Score), t(Fold_2_Mat$Test.Score));
Predict_Score <- rbind(t(Fold_0_Mat$Predict.Score), t(Fold_1_Mat$Predict.Score), t(Fold_2_Mat$Predict.Score));
Fold_Label <- rbind(matrix(0, length(Fold_0_Mat$Test.Score), 1), matrix(1, length(Fold_1_Mat$Test.Score), 1), matrix(2, length(Fold_2_Mat$Test.Score), 1));

All_Data = data.frame(Test_Score = Test_Score, Predict_Score = Predict_Score, Fold_Label = Fold_Label);
All_Data$Fold_Label = as.factor(All_Data$Fold_Label);
ggplot(All_Data, aes(x = Test_Score, y = Predict_Score, color = Fold_Label, shape = Fold_Label)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20))

# Specificity of the model (correlation of the predicted scores and other factors
Fold_0_Index = Fold_0_Mat$Index + 1;
Fold_1_Index = Fold_1_Mat$Index + 1;
Fold_2_Index = Fold_2_Mat$Index + 1;
DataFolder = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction';
Behavior_Mat = readMat(file.path(DataFolder, '/Behavior.mat'));
Motion = as.matrix(Behavior_Mat$MotionMeanRelRMS);
TBV = as.matrix(Behavior_Mat$TBV);
Age_years = as.matrix(Behavior_Mat$Age.years);
OverallAccuracy = as.matrix(Behavior_Mat$OverallAccuracy);
All_Data$MotionMeanRelRMS = rbind(as.matrix(Motion[Fold_0_Index]), as.matrix(Motion[Fold_1_Index]), as.matrix(Motion[Fold_2_Index]));
All_Data$TBV = rbind(as.matrix(TBV[Fold_0_Index]), as.matrix(TBV[Fold_1_Index]), as.matrix(TBV[Fold_2_Index]));
All_Data$Age_years = rbind(as.matrix(Age_years[Fold_0_Index]), as.matrix(Age_years[Fold_1_Index]), as.matrix(Age_years[Fold_2_Index]));
All_Data$OverallAccuracy = rbind(as.matrix(OverallAccuracy[Fold_0_Index]), as.matrix(OverallAccuracy[Fold_1_Index]), as.matrix(OverallAccuracy[Fold_2_Index]));

cor.test(Fold_0_Mat$Predict.Score, t(OverallAccuracy[Fold_0_Index]))
cor.test(Fold_1_Mat$Predict.Score, t(OverallAccuracy[Fold_1_Index]))
cor.test(Fold_2_Mat$Predict.Score, t(OverallAccuracy[Fold_2_Index]))

