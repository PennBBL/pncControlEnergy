
# Extracting the biofactors, demographics and dti head motion information according to the order controllability measurements 

require('R.matlab')

Energy_SC_125 = "/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/SC_InitialDM1_TargetFP1DMN1.mat";
tmp = readMat(Energy_SC_125);
Scan_ID_SC = tmp$scan.ID;

print('.');
Cognition_CSV = "/data/joy/BBL/studies/pnc/n1601_dataFreeze/cnb/n1601_cnb_factor_scores_tymoore_20151006.csv";
tmp = read.csv(Cognition_CSV);
Scan_ID_Cognition_CSV = tmp$scanid;
Indice = matrix(1:length(Scan_ID_SC), nrow = length(Scan_ID_SC));
for (i in 1:length(Scan_ID_SC)){
  for (j in 1:length(Scan_ID_Cognition_CSV)){
    if(Scan_ID_SC[i] == Scan_ID_Cognition_CSV[j]){
      Indice[i] = j;
      break;
    }
  }
}
OverallEfficiency = tmp$Overall_Efficiency[Indice];
OverallAccuracy = tmp$Overall_Accuracy[Indice];
OverallSpeed = tmp$Overall_Speed[Indice];
F1ExecCompResAccuracy = tmp$F1_Exec_Comp_Res_Accuracy[Indice];
F2SocialCogAccuracy = tmp$F2_Social_Cog_Accuracy[Indice];
F3MemoryAccuracy = tmp$F3_Memory_Accuracy[Indice];
F1ComplexReasoningEfficiency = tmp$F1_Complex_Reasoning_Efficiency[Indice];
F2MemoryEfficiency = tmp$F2_Memory.Efficiency[Indice];
F3ExecutiveEfficiency = tmp$F3_Executive_Efficiency[Indice];
F4SocialCognitionEfficiency = tmp$F4_Social_Cognition_Efficiency[Indice];
F1SlowSpeed = tmp$F1_Slow_Speed[Indice];
F2FastSpeed = tmp$F2_Fast_Speed[Indice];
F3MemorySpeed = tmp$F3_Memory_Speed[Indice];
OverallEfficiencyAr = tmp$Overall_Efficiency_Ar[Indice];
OverallAccuracyAr = tmp$Overall_Accuracy_Ar[Indice];  
OverallSpeedAr = tmp$Overall_Speed_Ar[Indice];
F1ExecCompCogAccuracyAr = tmp$F1_Exec_Comp_Cog_Accuracy_Ar[Indice];
F2SocialCogAccuracyAr = tmp$F2_Social_Cog_Accuracy_Ar[Indice];
F3MemoryAccuracyAr = tmp$F3_Memory_Accuracy_Ar[Indice];
F1SocialCognitionEfficiencyAr = tmp$F1_Social_Cognition_Efficiency_Ar[Indice];
F2ComplexReasoningEfficiencyAr = tmp$F2_Complex_Reasoning_Efficiency_Ar[Indice];
F3MemoryEfficiencyAr = tmp$F3_Memory_Efficiency_Ar[Indice];
F4ExecutiveEfficiencyAr = tmp$F4_Executive_Efficiency_Ar[Indice];
F1SlowSpeedAr = tmp$F1_Slow_Speed_Ar[Indice];
F2MemorySpeedAr = tmp$F2_Memory_Speed_Ar[Indice];
F3FastSpeedAr = tmp$F3_Fast_Speed_Ar[Indice];

Resultant_Mat = "/data/joy/BBL/projects/pncControlEnergy/data/subjectData/n949_cnb_factor_scores_tymoore_20151006.mat";
writeMat(Resultant_Mat, Scan_ID_SC = t(Scan_ID_SC), OverallEfficiency = OverallEfficiency, OverallAccuracy = OverallAccuracy, OverallSpeed = OverallSpeed, F1ExecCompResAccuracy = F1ExecCompResAccuracy, F2SocialCogAccuracy = F2SocialCogAccuracy, F3MemoryAccuracy = F3MemoryAccuracy, F1ComplexReasoningEfficiency = F1ComplexReasoningEfficiency, F2MemoryEfficiency = F2MemoryEfficiency, F3ExecutiveEfficiency = F3ExecutiveEfficiency, F4SocialCognitionEfficiency = F4SocialCognitionEfficiency, F1SlowSpeed = F1SlowSpeed, F2FastSpeed = F2FastSpeed, F3MemorySpeed = F3MemorySpeed, OverallEfficiencyAr = OverallEfficiencyAr, OverallAccuracyAr = OverallAccuracyAr, OverallSpeedAr = OverallSpeedAr, F1ExecCompCogAccuracyAr = F1ExecCompCogAccuracyAr, F2SocialCogAccuracyAr = F2SocialCogAccuracyAr, F3MemoryAccuracyAr = F3MemoryAccuracyAr, F1SocialCognitionEfficiencyAr = F1SocialCognitionEfficiencyAr, F2ComplexReasoningEfficiencyAr = F2ComplexReasoningEfficiencyAr, F3MemoryEfficiencyAr = F3MemoryEfficiencyAr, F4ExecutiveEfficiencyAr = F4ExecutiveEfficiencyAr, F1SlowSpeedAr = F1SlowSpeedAr, F2MemorySpeedAr = F2MemorySpeedAr, F3FastSpeedAr = F3FastSpeedAr);
