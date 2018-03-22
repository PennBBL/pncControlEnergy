##########################################################################################################
### This script will construct a subject sample for PNC-ControlEnergy-Development analyses, retaining  ###
###     subjects who passed quality assurance protocols for Freesurfer, DTI, and healthExcludev2.      ###
###      Also, revmoing subjects according to the activation data, finally 803 subjects remained.      ###
###    Finally, create an excel containing IDs of subjects we used and extract the activation data.    ###
##########################################################################################################

library(R.matlab)

## LTN and Health Status
health <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/health/n1601_health_20170421.csv")
## T1
t1_qa <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv")
## DTI 
dti_qa <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv")
## B0 Acquisition
protVal <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/n1601_pnc_protocol_validation_params_status_20161220.csv")
ControlEnergy_df <- health
##############################
### Merge QA data ###
##############################
ControlEnergy_df <- merge(ControlEnergy_df, t1_qa, by=c("scanid","bblid"))
ControlEnergy_df <- merge(ControlEnergy_df, dti_qa, by=c("scanid","bblid"))
ControlEnergy_df <- merge(ControlEnergy_df, protVal, by=c("scanid","bblid"))

####################################################
### Define study sample using exclusion criteria ###
####################################################
## FreeSurfer QA
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$fsFinalExclude == 0), ] 

## Valid and complete 64-direction DTI sequence
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$dti64ProtocolValidationStatus == 1), ]

## B0 acquisition and distortion correction
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$b0ProtocolValidationStatus==1), ]

## Roalf's DTI QA
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$dti64Exclude == 0), ]
dim(ControlEnergy_df)

## Health Exclude
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$healthExcludev2 == 0 & ControlEnergy_df$ltnExcludev2 == 0), ]
dim(ControlEnergy_df)
####################################################

## Specify columns to retain
attach(ControlEnergy_df)
keeps <- c("bblid", "scanid")
  
## Define new dataframe with specified columns 
subjid_df <- ControlEnergy_df[keeps]
dim(subjid_df)
detach(ControlEnergy_df)

## Write out subject identifiers to CSV
## Finally, we get 949 subjects

###############################################################################
### Further, select subjects according to activation                        ###
### Remove subjects with nbackExclude=1, nbackZerobackNrExclude=1           ###
### Remove regions with missing data in more than 9 subjects (10% subjects) ###
### Remove subjects still with missing data                                 ###
###############################################################################
nback_All_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_lausanne125NbackValues_20170427.csv");
nbackQA_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_NbackQAData_20170427.csv");
nbackBehavior_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv");
nback_All_Data <- merge(nback_All_Data, nbackQA_Data, by = c("scanid", "bblid"));
nback_All_Data <- merge(nback_All_Data, nbackBehavior_Data, by = c("scanid", "bblid"));

# Select the activation data of the 949 subjects
Activation_Extract <- merge(subjid_df, nback_All_Data, by = c("scanid", "bblid"));
scanID <- Activation_Extract$scanid;
# Extracting the activation and removing subjects with nbackExclude=1, nbackZerobackNrExclude=1
st <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi1');
nd <- which(colnames(Activation_Extract) == 'nback_lausanne125_cope4_2back0back_roi233');
Include_SubjectIndex <- which(Activation_Extract$nbackExclude == 0 & Activation_Extract$nbackZerobackNrExclude == 0);
Activation_2b0b <- as.matrix(Activation_Extract[Include_SubjectIndex, st:nd]);
scanID <- scanID[Include_SubjectIndex];
# Removing 3 subjects with activation value of NA in all regions
NANQuantity_ForSubject = matrix(0, length(subjid_df$scanid), 1);
for (i in c(1:length(scanID)))
{
  NANQuantity_ForSubject[i] <- length(which(is.na(Activation_2b0b[i,])));
}
AllNAN_Subjects_Index <- which(NANQuantity_ForSubject == 233);
Activation_2b0b <- Activation_2b0b[-AllNAN_Subjects_Index,];
scanID <- scanID[-AllNAN_Subjects_Index];
# Further, removing regions with missing values in 1% subjects (9 subjects)
NANQuantity_ForRegion = matrix(0, 233, 1);
for (i in c(1:233))
{
  NANQuantity_ForRegion[i] = length(which(is.na(Activation_2b0b[,i])));
}
Exclude_RegionIndex <- which(NANQuantity_ForRegion >= 9);
Activation_2b0b[, Exclude_RegionIndex] = 0;
# Removing subjects who still have NAN values
NAN_SubjectIndex <- which(is.na(rowSums(Activation_2b0b)));
Activation_2b0b <- Activation_2b0b[-NAN_SubjectIndex,];
scanID <- scanID[-NAN_SubjectIndex];

# Finally, we have 803 subjects, which will be used in this study
dir.create("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data");
write.csv(scanID, "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/pncControlEnergy_n803_subjectIDs.csv", row.names=FALSE)
writeMat("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/Activation_803.mat", Activation_2b0b = Activation_2b0b, Exclude_RegionIndex = Exclude_RegionIndex, scanID = scanID);
