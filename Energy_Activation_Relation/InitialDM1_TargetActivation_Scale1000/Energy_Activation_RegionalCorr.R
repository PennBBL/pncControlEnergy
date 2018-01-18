
library(R.matlab);
WorkingFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetActivation_Scale1000/Energy_Activation_Relationship';
tmp <- readMat(file.path(WorkingFolder, '/Energy_Activation.mat'));
Activation <- tmp$Activation;
Activation_abs <- tmp$Activation.abs;
Energy_New <- tmp$Energy.New;
Energy_New_log2 <- tmp$Energy.New.log2;

# Mean Correlation
Activation_Mean <- rowMeans(Activation);
Acitvation_abs_Mean <- rowMeans(Activation_abs);
Energy_New_Mean <- rowMeans(Energy_New);
Energy_New_log2_Mean <- rowMeans(Energy_New_log2);
tmp <- cor.test(Activation_Mean, Energy_New_Mean);
P_Activation_Energy_MeanCorr <- tmp$p.value;
tmp <- cor.test(Activation_Mean, Energy_New_log2_Mean);
P_Activation_EnergyLog2_MeanCorr <- tmp$p.value;
tmp <- cor.test(Acitvation_abs_Mean, Energy_New_Mean);
P_ActivationAbs_Energy_MeanCorr <- tmp$p.value;
tmp <- cor.test(Acitvation_abs_Mean, Energy_New_log2_Mean);
P_ActivationAbs_EnergyLog2_MeanCorr <- tmp$p.value;
writeMat(file.path(WorkingFolder, 'Energy_Activation_MeanCorr.mat'), P_Activation_Energy_MeanCorr = P_Activation_Energy_MeanCorr, P_Activation_EnergyLog2_MeanCorr = P_Activation_EnergyLog2_MeanCorr, P_ActivationAbs_Energy_MeanCorr = P_ActivationAbs_Energy_MeanCorr, P_ActivationAbs_EnergyLog2_MeanCorr = P_ActivationAbs_EnergyLog2_MeanCorr);

# Nodal results
P_Activation_Energy = matrix(0, 233, 1);
P_Activation_EnergyLog2 = matrix(0, 233, 1);
P_ActivationAbs_Energy = matrix(0, 233, 1);
P_ActivationAbs_EnergyLog2 = matrix(0, 233, 1);
for (i in c(1:233))
{
  tmp <- cor.test(Activation[,i], Energy_New[,i]);
  P_Activation_Energy[i] <- tmp$p.value;

  tmp <- cor.test(Activation[,i], Energy_New_log2[,i]);
  P_Activation_EnergyLog2[i] <- tmp$p.value;

  tmp <- cor.test(Activation_abs[,i], Energy_New[,i]);
  P_ActivationAbs_Energy[i] <- tmp$p.value;

  tmp <- cor.test(Activation_abs[,i], Energy_New_log2[,i]);
  P_ActivationAbs_EnergyLog2[i] <- tmp$p.value;
}
P_Activation_Energy_fdr = p.adjust(P_Activation_Energy, "fdr");
P_Activation_EnergyLog2_fdr = p.adjust(P_Activation_EnergyLog2, "fdr");
P_ActivationAbs_Energy_fdr = p.adjust(P_ActivationAbs_Energy, "fdr");
P_ActivationAbs_EnergyLog2_fdr = p.adjust(P_ActivationAbs_EnergyLog2, "fdr");
writeMat(file.path(WorkingFolder, 'Energy_Activation_RegionalCorr_Univariate_Results.mat'), P_Activation_Energy = P_Activation_Energy, P_Activation_EnergyLog2 = P_Activation_EnergyLog2, 
         P_ActivationAbs_Energy = P_ActivationAbs_Energy, P_ActivationAbs_EnergyLog2 = P_ActivationAbs_EnergyLog2, P_Activation_Energy_fdr = P_Activation_Energy_fdr, 
         P_Activation_EnergyLog2_fdr = P_Activation_EnergyLog2_fdr, P_ActivationAbs_Energy_fdr = P_ActivationAbs_Energy_fdr, P_ActivationAbs_EnergyLog2_fdr = P_ActivationAbs_EnergyLog2_fdr)

Yeo_Atlas_Mat = readMat('/data/jux/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
FP_Index = which(Yeo_Atlas_Mat$Yeo.7system == 6);
P_Activation_Energy_fdr_FP = p.adjust(P_Activation_Energy[FP_Index], "fdr");
P_Activation_EnergyLog2_fdr_FP = p.adjust(P_Activation_EnergyLog2[FP_Index], "fdr");
P_ActivationAbs_Energy_fdr_FP = p.adjust(P_ActivationAbs_Energy[FP_Index], "fdr");
P_ActivationAbs_EnergyLog2_fdr_FP = p.adjust(P_ActivationAbs_EnergyLog2[FP_Index], "fdr");
writeMat(file.path(WorkingFolder, 'Energy_Activation_RegionalCorr_Univariate_Results_FP.mat'), P_Activation_Energy_fdr_FP = P_Activation_Energy_fdr_FP, P_Activation_EnergyLog2_fdr_FP = P_Activation_EnergyLog2_fdr_FP, P_ActivationAbs_Energy_fdr_FP = P_ActivationAbs_Energy_fdr_FP, P_ActivationAbs_EnergyLog2_fdr_FP = P_ActivationAbs_EnergyLog2_fdr_FP, FP_Index = FP_Index);



