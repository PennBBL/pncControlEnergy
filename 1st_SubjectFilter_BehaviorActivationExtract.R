##########################################################################################################
### This script will construct a subject sample for PNC-ControlEnergy-Development analyses, retaining  ###
###     subjects who passed quality assurance protocols for Freesurfer, DTI, and healthExcludev2.      ###
###                                 Finally, 949 subjects remained.                                    ###
##########################################################################################################

library(R.matlab)

#########################################################
### 1. Filter subjects, finally 949 subjects remained ###
#########################################################
## LTN and Health Status
health <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/health/n1601_health_20170421.csv")
## T1
t1_qa <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv")
## DTI 
dti_qa <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv")
## B0 Acquisition
protVal <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/n1601_pnc_protocol_validation_params_status_20161220.csv")
ControlEnergy_df <- health
## Merge QA data 
ControlEnergy_df <- merge(ControlEnergy_df, t1_qa, by=c("scanid","bblid"))
ControlEnergy_df <- merge(ControlEnergy_df, dti_qa, by=c("scanid","bblid"))
ControlEnergy_df <- merge(ControlEnergy_df, protVal, by=c("scanid","bblid"))
### Define study sample using exclusion criteria
## Health Exclude
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$healthExcludev2 == 0 & ControlEnergy_df$ltnExcludev2 == 0), ]
dim(ControlEnergy_df)
## FreeSurfer QA
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$fsFinalExclude == 0), ] 
## Valid and complete 64-direction DTI sequence
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$dti64ProtocolValidationStatus == 1), ]
## B0 acquisition and distortion correction
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$b0ProtocolValidationStatus==1), ]
## Roalf's DTI QA
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$dti64Exclude == 0), ]
dim(ControlEnergy_df)
## Specify columns to retain
attach(ControlEnergy_df)
keeps <- c("bblid", "scanid")
## Define new dataframe with specified columns 
subjid_df <- ControlEnergy_df[keeps]
dim(subjid_df)
detach(ControlEnergy_df)
## Write out subject identifiers to CSV
## Finally, we get 949 subjects
dir.create("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data");
write.csv(subjid_df, "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/pncControlEnergy_n949_SubjectsIDs.csv", row.names=FALSE)

#########################################################################
### 2 Averaging activation for these 949 subjects                     ###
###   Only 677 subjects have activation data in all regions           ###
###   So, average these 677 subjects                                  ###
#########################################################################
subjid_df <- read.csv("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/pncControlEnergy_n949_SubjectsIDs.csv");
# Extract average activation of 677 subjects 
nback_All_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_lausanne125NbackValues_20170427.csv");
nbackQA_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_NbackQAData_20170427.csv");
nbackBehavior_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv");
nback_All_Data <- merge(nback_All_Data, nbackQA_Data, by = c("scanid", "bblid"));
nback_All_Data <- merge(nback_All_Data, nbackBehavior_Data, by = c("scanid", "bblid"));
# Select the activation data of the 949 subjects
Activation_Extract <- merge(subjid_df, nback_All_Data, by = c("scanid", "bblid"));
# Extracting the activation and removing subjects with nbackExclude=1, nbackZerobackNrExclude=1
st <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi1');
nd <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi233');
Include_SubjectIndex <- which(Activation_Extract$nbackExclude == 0 & Activation_Extract$nbackZerobackNrExclude == 0);
Activation_2b0b <- as.matrix(Activation_Extract[Include_SubjectIndex, st:nd]);
scan_ID_Activation <- subjid_df$scanid[Include_SubjectIndex]
# Mean activation
Activation_2b0b_MeanAcrossNodes <- rowMeans(Activation_2b0b);
# Remove subjects with NAN, finally only 677 subjects have activation
# Average the 677 subjects' activation, resulting in average activation
NonNANIndex <- which(!is.na(Activation_2b0b_MeanAcrossNodes));
Activation_2b0b_Extract <- Activation_2b0b[NonNANIndex,]
scan_ID_Activation <- scan_ID_Activation[NonNANIndex]
Activation_677_Avg <- colMeans(Activation_2b0b_Extract);
# One sample t-test
P <- matrix(0, 233, 1);
for (i in 1:233)
{
  tmp <- t.test(Activation_2b0b_Extract[,i], mu = 0);
  P[i] <- tmp$p.value;
}
P_FDR <- p.adjust(P, method = 'fdr');
OneSampleSig_005_Index <- which(P_FDR < 0.05);
OneSampleSig_001_Index <- which(P_FDR < 0.01);
writeMat("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/Activation_677_Avg.mat", Activation_677_Avg = Activation_677_Avg, Activation_677 = Activation_2b0b_Extract, OneSampleSig_005_Index = OneSampleSig_005_Index, OneSampleSig_001_Index = OneSampleSig_001_Index, scan_ID_Activation = scan_ID_Activation);

#########################################
### 3. Extrating behavior information ###
#########################################
demo <- subjid_df;
# in-scanner n-back task performance, which was imported in the 2nd step
demo$nbackBehAllDprime <- Activation_Extract$nbackBehAllDprime;
# TBV
BrainTissue_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_ctVol20170412.csv");
# Demographics 
Demographics_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv");
# Motion
Motion_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv");
# Cognition
Cognition_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/cnb/n1601_cnb_factor_scores_tymoore_20151006.csv");
# Merge all data
demo <- merge(demo, BrainTissue_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Demographics_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Motion_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Cognition_Data, by = c("scanid", "bblid"));
# Output the subjects' behavior data
write.csv(demo, "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/n949_Behavior_20180522.csv", row.names = FALSE);
