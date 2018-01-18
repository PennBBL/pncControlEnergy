
library(R.matlab);
library(ggplot2);

Ridge_APredictB_Folder <- '/Users/zaixucui/Documents/Projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction/Ridge_Sample1_Predict_Sample2_MeanEnergyAgeTBV';
Prediction_Mat <- readMat(file.path(Ridge_APredictB_Folder, 'APredictB.mat'));
Test_Score <- t(Prediction_Mat$Test.Score);
Predict_Score <- t(Prediction_Mat$Predict.Score);
All_Data = data.frame(Test_Score = Test_Score, Predict_Score = Predict_Score);
ggplot(All_Data, aes(x = Test_Score, y = Predict_Score)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20))

# Specificity of the model (correlation of the predicted scores and other factors
DataFolder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/ExecFun_Prediction/InitialDM1_TargetActivation';
Behavior_Mat = readMat(file.path(DataFolder, '/Behavior.mat'));
SampleIndex_Mat = readMat(file.path(DataFolder, '/SampleIndex.mat'));
Sample2_Index = SampleIndex_Mat$Sample2.Index;

All_Data$MotionMeanRelRMS = as.matrix(Behavior_Mat$MotionMeanRelRMS[Sample2_Index]);
All_Data$TBV = as.matrix(Behavior_Mat$TBV[Sample2_Index]);
All_Data$Age_years = as.matrix(Behavior_Mat$Age.years[Sample2_Index]);
All_Data$OverallAccuracy = as.matrix(Behavior_Mat$OverallAccuracy[Sample2_Index]);

cor.test(Predict_Score, All_Data$OverallAccuracy)

# Motion
ggplot(All_Data, aes(x = MotionMeanRelRMS, y = Predict_Score, color = Fold_Label, shape = Fold_Label)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20))
cor.test(Predict_Score, All_Data$MotionMeanRelRMS)

# TBV
ggplot(All_Data, aes(x = TBV, y = Predict_Score, color = Fold_Label, shape = Fold_Label)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20))
cor.test(Predict_Score, All_Data$TBV)

# Age
ggplot(All_Data, aes(x = Age_years, y = Predict_Score, color = Fold_Label, shape = Fold_Label)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20))
cor.test(Predict_Score, All_Data$Age_years)



