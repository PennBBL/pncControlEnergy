
library(R.matlab)

#########################################################################
### 1.Averaging activation for these 946 subjects                     ###
###   Only 675 subjects have activation data in all regions           ###
###   So, average these 675 subjects                                  ###
#########################################################################
subjid_df <- read.csv("/data/jux/BBL/projects/pncControlEnergy/results/Replication_Prob/data/pncControlEnergy_n946_SubjectsIDs.csv");
# Extract average activation of 675 subjects 
nback_All_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_lausanne125NbackValues_20170427.csv");
nbackQA_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_NbackQAData_20170427.csv");
nbackBehavior_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv");
nback_All_Data <- merge(nback_All_Data, nbackQA_Data, by = c("scanid", "bblid"));
nback_All_Data <- merge(nback_All_Data, nbackBehavior_Data, by = c("scanid", "bblid"));
# Select the activation data of the 946 subjects
Activation_Extract <- merge(subjid_df, nback_All_Data, by = c("scanid", "bblid"));
# Extracting the activation and removing subjects with nbackExclude=1, nbackZerobackNrExclude=1
st <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi1');
nd <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi233');
Include_SubjectIndex <- which(Activation_Extract$nbackExclude == 0 & Activation_Extract$nbackZerobackNrExclude == 0);
Activation_2b0b <- as.matrix(Activation_Extract[Include_SubjectIndex, st:nd]);
scan_ID_Activation <- subjid_df$scanid[Include_SubjectIndex]
# Mean activation
Activation_2b0b_MeanAcrossNodes <- rowMeans(Activation_2b0b);
# Remove subjects with NAN, finally only 675 subjects have activation
# Average the 675 subjects' activation, resulting in average activation
NonNANIndex <- which(!is.na(Activation_2b0b_MeanAcrossNodes));
Activation_2b0b_Extract <- Activation_2b0b[NonNANIndex,]
# Activation_2b0b_Extract variable is a 675*233 matrix
# Remove the 192th region, because we removed this region in the brain network
Activation_2b0b_Extract <- Activation_2b0b_Extract[, c(1:191, 193:233)]
scan_ID_Activation <- scan_ID_Activation[NonNANIndex]
Activation_675_Avg <- colMeans(Activation_2b0b_Extract);
# One-sample t-test
P <- matrix(0, 232, 1);
for (i in 1:232)
{
  tmp <- t.test(Activation_2b0b_Extract[,i], mu = 0);
  P[i] <- tmp$p.value;
}
P_FDR <- p.adjust(P, method = 'fdr');
OneSampleSig_005_Index <- which(P_FDR < 0.05);
OneSampleSig_001_Index <- which(P_FDR < 0.01);
writeMat("/data/jux/BBL/projects/pncControlEnergy/results/Replication_Prob/data/Activation_675_Avg.mat", Activation_675_Avg = Activation_675_Avg, Activation_675 = Activation_2b0b_Extract, OneSampleSig_005_Index = OneSampleSig_005_Index, OneSampleSig_001_Index = OneSampleSig_001_Index, scan_ID_Activation = scan_ID_Activation);

#########################################
### 2. Extrating behavior information ###
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
# Merge all data
demo <- merge(demo, BrainTissue_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Demographics_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Motion_Data, by = c("scanid", "bblid"));
# Output the subjects' behavior data
write.csv(demo, "/data/jux/BBL/projects/pncControlEnergy/results/Replication_Prob/data/n946_Behavior_20180712.csv", row.names = FALSE);
