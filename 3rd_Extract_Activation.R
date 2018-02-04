
library(R.matlab);

#1. Extract activation 
SubjectsIDs <- read.csv("/data/jux/BBL/projects/pncControlEnergy/subjectLists/pncControlEnergy_n949_subjectIDs.csv");
nback_All_Data <- read.csv("/data/jux/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_lausanne125NbackValues_20170427.csv");
nbackQA_Data <- read.csv("/data/jux/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_NbackQAData_20170427.csv");
nbackBehavior_Data <- read.csv("/data/jux/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv");
nback_All_Data <- merge(nback_All_Data, nbackQA_Data, by = c("bblid", "scanid"));
nback_All_Data <- merge(nback_All_Data, nbackBehavior_Data, by = c("bblid", "scanid"));

Activation_Extract <- merge(SubjectsIDs, nback_All_Data, by = c("bblid", "scanid"));
Activation_Extract <- Activation_Extract[which(Activation_Extract$nbackExclude == 0), ];
Activation_Extract <- Activation_Extract[which(Activation_Extract$nbackZerobackNrExclude == 0), ];

# Extract 2 back - 0 back data
st <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi1');
nd <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi233');
Activation_2b0b <- Activation_Extract[, st:nd];
# Remove subjects with activation value of NA
NonNA_Index <- which(!is.na(rowMeans(Activation_2b0b)));
Activation_Extract = Activation_Extract[NonNA_Index, ];
# Extract 2b-0b data finally, 677 subjects in all
Activation_2b0b = as.matrix(Activation_Extract[, st:nd]);
Activation_2b0b_Avg = colMeans(Activation_2b0b);
scanid = Activation_Extract$scanid;
writeMat('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/nback_2b0b_20180202.mat', scanid = scanid, Activation_2b0b = Activation_2b0b, Activation_2b0b_Avg = Activation_2b0b_Avg);


