
library(R.matlab)
library(mgcv)
library(visreg);
library(ggplot2);

ReplicationFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
AgePrediction_ResFolder <- paste(ReplicationFolder, '/results/volNormSC_Energy/Age_Prediction', sep = '');
Prediction_Sample2 <- readMat(paste(AgePrediction_ResFolder, '/Sample1_Predict_Sample2/APredictB.mat', sep = ''));
Prediction_Sample1 <- readMat(paste(AgePrediction_ResFolder, '/Sample2_Predict_Sample1/APredictB.mat', sep = ''));
PredictionError_Sample2 <- Prediction_Sample2$Predict.Score - Prediction_Sample2$Test.Score;
PredictionError_Sample1 <- Prediction_Sample1$Predict.Score - Prediction_Sample1$Test.Score;
PredictionError <- cbind(PredictionError_Sample2, PredictionError_Sample1);
PredictionError <- as.numeric(PredictionError);

AgePrediction_DataFolder <- paste(ReplicationFolder, '/data/AgePrediction', sep = '');
Behavior <- readMat(paste(AgePrediction_DataFolder, '/Behavior.mat', sep = ''));
SampleIndex <- readMat(paste(AgePrediction_DataFolder, '/SampleIndex_SplitHalf.mat', sep = ''));
SampleIndex_All <- cbind(t(SampleIndex$Sample2.Index), t(SampleIndex$Sample1.Index));

F1ExecCompResAccuracy <- Behavior$F1ExecCompResAccuracy[SampleIndex_All];
Sex <- Behavior$Sex[SampleIndex_All];
Age <- Behavior$Age[SampleIndex_All];
HandednessV2 <- Behavior$HandednessV2[SampleIndex_All];
MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[SampleIndex_All];
TBV <- Behavior$TBV[SampleIndex_All];
Activation_Mean <- Behavior$Activation.Mean[SampleIndex_All];
StrengthData <- readMat(paste(AgePrediction_DataFolder, '/volNormSC_Energy/Strength_EigNorm_SubIden.mat', sep = ''));
Strength_EigNorm_SubIden <- StrengthData$Strength.EigNorm.SubIden[SampleIndex_All];

NonNAN_Index <- which(!is.na(F1ExecCompResAccuracy));
PredictionError <- PredictionError[NonNAN_Index];
Behavior_New <- data.frame(F1ExecCompResAccuracy_New = as.numeric(F1ExecCompResAccuracy[NonNAN_Index]));
Behavior_New$Sex_New <- as.factor(Sex[NonNAN_Index]);
Behavior_New$Age_New <- as.numeric(Age[NonNAN_Index]);
Behavior_New$HandednessV2_New <- as.factor(HandednessV2[NonNAN_Index]);
Behavior_New$MotionMeanRelRMS_New <- as.numeric(MotionMeanRelRMS[NonNAN_Index]);
Behavior_New$TBV_New <- as.numeric(TBV[NonNAN_Index]);
Behavior_New$Strength_EigNorm_SubIden_New <- as.numeric(Strength_EigNorm_SubIden[NonNAN_Index]);
Behavior_New$Activation_Mean_New <- as.numeric(Activation_Mean[NonNAN_Index]);

Gam_Model <- gam(PredictionError ~ F1ExecCompResAccuracy_New + s(Age_New, k=4) + Sex_New + HandednessV2_New + MotionMeanRelRMS_New + TBV_New + Strength_EigNorm_SubIden_New, method = "REML", data = Behavior_New)
Fig <- visreg(Gam_Model, 'F1ExecCompResAccuracy_New', xlab = 'Executive Function', ylab = 'Prediction Error', line.par = list(col = "#000000"), gg = TRUE);
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=27, color='black'), axis.title=element_text(size=30));
Fig + geom_point(size = 1.5);
ggsave('/data/jux/BBL/projects/pncControlEnergy/scripts/PlotResults/volNormSC_Network/AgePrediction_Error_Cognition.pdf', width = 15, height = 15, dpi = 300, units = "cm");
ggsave('/data/jux/BBL/projects/pncControlEnergy/scripts/PlotResults/volNormSC_Network/AgePrediction_Error_Cognition.tiff', width = 15, height = 15, dpi = 300, units = "cm");
