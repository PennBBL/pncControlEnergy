
# Extracting the biofactors, demographics and dti head motion information according to the order controllability measurements 

require('R.matlab')

Energy_SC_125 = "/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/SC_InitialDM1_TargetIndividualActivation.mat";
tmp = readMat(Energy_SC_125);
Scan_ID_SC = tmp$scan.ID;

print('..');
Demographics_CSV = "/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n1601_demographics_go1_20161212.csv";
tmp = read.csv(Demographics_CSV);
Scan_ID_Demogra_CSV = tmp$scanid;
Indice = matrix(1:length(Scan_ID_SC), nrow = length(Scan_ID_SC));
for (i in 1:length(Scan_ID_SC)){
  for (j in 1:length(Scan_ID_Demogra_CSV)){
    if(Scan_ID_SC[i] == Scan_ID_Demogra_CSV[j]){
      Indice[i] = j;
      break;
    }
  }
}
Sex = tmp$sex[Indice];
Age = tmp$ageAtScan1[Indice];
Race = tmp$race[Indice];
Race2 = tmp$race2[Indice];
HandednessV2 = tmp$handednessv2[Indice];

print('...');
Motion_CSV = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv";
tmp = read.csv(Motion_CSV);
Scan_ID_Motion_CSV = tmp$scanid;
Indice = matrix(1:length(Scan_ID_SC), nrow = length(Scan_ID_SC));
for (i in 1:length(Scan_ID_SC)){
  for (j in 1:length(Scan_ID_Motion_CSV)){
    if(Scan_ID_SC[i] == Scan_ID_Motion_CSV[j]){
      Indice[i] = j;
      break;
    }
  }
}
MotionMeanRelRMS = tmp$dti64MeanRelRMS[Indice];

Resultant_Mat = "/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n677_Demogra_DtiMotion.mat";
writeMat(Resultant_Mat, Scan_ID_SC = Scan_ID_SC, Sex = Sex, Age = Age, Race = Race, Race2 = Race2, HandednessV2 = HandednessV2, MotionMeanRelRMS = MotionMeanRelRMS);
Resultant_CSV = "/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n677_Demogra_DtiMotion.csv";
All_Info_CSV = data.frame(Scan_ID_SC = Scan_ID_SC, Sex = Sex, Age = Age, Race = Race, Race2 = Race2, HandednessV2 = HandednessV2, MotionMeanRelRMS = MotionMeanRelRMS);
write.csv(All_Info_CSV, file = Resultant_CSV);
