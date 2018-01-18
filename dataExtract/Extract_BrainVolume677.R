
require('R.matlab')

Energy_SC_125 = "/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/SC_InitialDM1_TargetIndividualActivation.mat";
tmp = readMat(Energy_SC_125);
Scan_ID_SC = tmp$scan.ID;

BrainTissue_CSV = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_ctVol20170412.csv";
tmp = read.csv(BrainTissue_CSV);
Scan_ID_BrainTissue_CSV = tmp$scanid;
Indice = matrix(1:length(Scan_ID_SC), nrow = length(Scan_ID_SC));
for (i in 1:length(Scan_ID_SC)){
  for (j in 1:length(Scan_ID_BrainTissue_CSV)){
    if(Scan_ID_SC[i] == Scan_ID_BrainTissue_CSV[j]){
      Indice[i] = j;
      break;
    }
  }
}
CSF = tmp$mprage_antsCT_vol_CSF[Indice];
GM = tmp$mprage_antsCT_vol_GrayMatter[Indice];
WM = tmp$mprage_antsCT_vol_WhiteMatter[Indice];
DeepGM = tmp$mprage_antsCT_vol_DeepGrayMatter[Indice];
BrainStem = tmp$mprage_antsCT_vol_BrainStem[Indice];
Cerebellum = tmp$mprage_antsCT_vol_Cerebellum[Indice];
TBV = tmp$mprage_antsCT_vol_TBV[Indice];

Resultant_Mat = "/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n677_ctVol20170412.mat";
writeMat(Resultant_Mat, Scan_ID_SC = t(Scan_ID_SC), CSF = CSF, GM = GM, WM = WM, DeepGM = DeepGM, BrainStem = BrainStem, Cerebellum = Cerebellum, TBV = TBV);
