
#3. Extract Behavioral data according to order of Energy data
Energy_SC_125 = "/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/SC_InitialAll0_TargetActivation.mat";
tmp = readMat(Energy_SC_125);
demo = data.frame(scanid = t(tmp$scan.ID));

# TBV
BrainTissue_Data <- read.csv("/data/jux/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_ctVol20170412.csv");
# Demographics
Demographics_Data <- read.csv("/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n1601_demographics_go1_20161212.csv");
# Motion
Motion_Data <- read.csv("/data/jux/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv");
# Cognition
Cognition_Data <- read.csv("/data/jux/BBL/studies/pnc/n1601_dataFreeze/cnb/n1601_cnb_factor_scores_tymoore_20151006.csv");

demo <- merge(demo, BrainTissue_Data, by = ("scanid"));
demo <- merge(demo, Demographics_Data, by = ("scanid"));
demo <- merge(demo, Motion_Data, by = ("scanid"));
demo <- merge(demo, Cognition_Data, by = ("scanid"));

write.csv(demo, "/data/jux/BBL/projects/pncControlEnergy/data/subjectData/n949_Behavior_20180202.csv", row.names = FALSE);

