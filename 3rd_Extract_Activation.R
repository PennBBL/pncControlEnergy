
#################################################################################################################
###  Extracting activation data (677 subjects in all)                                                         ###
###  First, merge activation data, activation QA data, .etc according to the order of matrices (important)    ###
###  Second, remove subjects with nbackExclude=1, nbackZerobackNrExclude=1 or NA values in activation data    ###
###          Finally, 677 subjects remain                                                                     ###
###  Third, save the 2back-0back activation and index of 677 subjects, average activation                     ###
#################################################################################################################

library(R.matlab);
ScanIDMat = "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/ScanID_MatrixOrder.mat";
tmp = readMat(ScanIDMat);
ScanID_MatrixOrder = data.frame(scanid = tmp$scanid);

#1. Extract activation 
SubjectsIDs <- read.csv("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/pncControlEnergy_n949_subjectIDs.csv");
nback_All_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_lausanne125NbackValues_20170427.csv");
nbackQA_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_NbackQAData_20170427.csv");
nbackBehavior_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv");
nback_All_Data <- merge(nback_All_Data, nbackQA_Data, by = c("bblid", "scanid"));
nback_All_Data <- merge(nback_All_Data, nbackBehavior_Data, by = c("bblid", "scanid"));

Activation_Extract <- merge(ScanID_MatrixOrder, nback_All_Data, by = "scanid"); # Sort data according to the order of matrices

st <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi1');
nd <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi233');
Activation_2b0b = as.matrix(Activation_Extract[, st:nd]);
# Remove subjects with activation value of NA or excludeIndex=1
Include_Index = which(Activation_Extract$nbackExclude == 0 & Activation_Extract$nbackZerobackNrExclude == 0 & !is.na(rowMeans(Activation_2b0b)));
# Extract 2b-0b data finally, 677 subjects in all
Activation_2b0b = as.matrix(Activation_2b0b[Include_Index, ]);
Activation_2b0b_Avg = colMeans(Activation_2b0b);
scanid = Activation_Extract$scanid[Include_Index];
dir.create('/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/ActivationData');
writeMat('/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/ActivationData/nback_2b0b_20180202.mat', ScanID_MatrixOrder = scanid, Activation_2b0b = Activation_2b0b, Activation_2b0b_Avg = Activation_2b0b_Avg, Include_Index = Include_Index);


