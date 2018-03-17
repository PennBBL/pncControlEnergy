
library(R.matlab)

#3. Extract Behavioral data according to order of Energy data
##### For all 949 subjects, will be used when mean activation and FP1/Visual1 as target state
ScanIDMat = "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/ScanID_MatrixOrder.mat";
tmp = readMat(ScanIDMat);
demo = data.frame(scanid = tmp$scanid);
# TBV
BrainTissue_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_ctVol20170412.csv");
# Demographics
Demographics_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv");
# Motion
Motion_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv");
# Cognition
Cognition_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/cnb/n1601_cnb_factor_scores_tymoore_20151006.csv");
# Psychopathology corrtraite
Psychopathology_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/clinical/n1601_goassess_itemwise_fscores_self_regressed_20170131.csv");
# Merge all data
demo <- merge(demo, BrainTissue_Data, by = "scanid");
demo <- merge(demo, Demographics_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Motion_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Cognition_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Psychopathology_Data, by = c("scanid", "bblid"));
# Output the subjects' data
dir.create("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/BehaviorData/");
write.csv(demo, "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/BehaviorData/n949_Behavior_20180316.csv", row.names = FALSE);



##### For all 677 subjects who have intact activation data, will be used when individualized activation as target state
Activation_677_Mat = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/ActivationData/nback_2b0b_20180202.mat';
tmp = readMat(Activation_677_Mat);
demo = data.frame(scanid = tmp$ScanID.MatrixOrder);
# Merge all data
demo <- merge(demo, BrainTissue_Data, by = "scanid");
demo <- merge(demo, Demographics_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Motion_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Cognition_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Psychopathology_Data, by = c("scanid", "bblid"));
# Output the subjects' data
write.csv(demo, "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/BehaviorData/n677_Behavior_20180316.csv", row.names = FALSE);
