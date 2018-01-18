
library(R.matlab);

Energy_SC_125 = "/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/SC_InitialDM1_TargetFP1DMN1.mat";
tmp = readMat(Energy_SC_125);
Scan_ID_SC = tmp$scan.ID;

nback_CSV = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_lausanne125NbackValues_20170427.csv";
tmp = read.csv(nback_CSV);
Scan_ID_nback_CSV = tmp$scanid;
Indice = matrix(1:length(Scan_ID_SC), nrow = length(Scan_ID_SC));
for (i in 1:length(Scan_ID_SC))
{
  for (j in 1:length(Scan_ID_nback_CSV))
  {
    if(Scan_ID_SC[i] == Scan_ID_nback_CSV[j])
    {
      Indice[i] = j;
      break;
    }
  }
}

Activation_2b0b = matrix(1:length(Indice)*233, nrow = length(Indice), ncol = 233);
for (i in 1:233)
{
  cmd_str = paste('ROI_I <- tmp$nback_lausanne125_cope4_2back0back_roi', as.character(i), sep = '');
  eval(parse(text = cmd_str));
  Activation_2b0b[, i] = ROI_I[Indice];
}

nbackQA_CSV = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_NbackQAData_20170427.csv";
tmp = read.csv(nbackQA_CSV);
Scan_ID_nbackQA_CSV = tmp$scanid;
Indice = matrix(1:length(Scan_ID_SC), nrow = length(Scan_ID_SC));
for (i in 1:length(Scan_ID_SC))
{
  for (j in 1:length(Scan_ID_nbackQA_CSV))
  {
    if(Scan_ID_SC[i] == Scan_ID_nbackQA_CSV[j])
    {
      Indice[i] = j;
      break;
    }
  }
}
nbackExclude = tmp$nbackExclude[Indice];

nbackBehavior_CSV = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv";
tmp = read.csv(nbackBehavior_CSV);
Scan_ID_nbackBehavior_CSV = tmp$scanid;
Indice = matrix(1:length(Scan_ID_SC), nrow = length(Scan_ID_SC));
for (i in 1:length(Scan_ID_SC))
{
  for (j in 1:length(Scan_ID_nbackBehavior_CSV))
  {
    if(Scan_ID_SC[i] == Scan_ID_nbackBehavior_CSV[j])
    {
      Indice[i] = j;
      break;
    }
  }
}
nbackZerobackExclude = tmp$nbackZerobackNrExclude[Indice];

Resultant_Mat = "/data/joy/BBL/projects/pncControlEnergy/data/subjectData/nback_2b0b_20170427.mat";
writeMat(Resultant_Mat, Scan_ID_SC = t(Scan_ID_SC), Activation_2b0b = Activation_2b0b, nbackExclude = nbackExclude, nbackZerobackExclude = nbackZerobackExclude);


