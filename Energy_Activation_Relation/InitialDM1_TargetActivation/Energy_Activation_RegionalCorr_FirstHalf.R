
library(R.matlab);
WorkingFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetActivation/Energy_Activation_Relationship';
tmp <- readMat(file.path(WorkingFolder, '/Energy_Activation.mat'));
Activation_abs <- tmp$Activation.abs;
Energy_New <- tmp$Energy.New;

for (i in c(1:233))
{
  tmp <- cor.test(Activation_abs[,i], Energy_New[,i]);
  P_ActivationAbs_Energy[i] <- tmp$p.value;
}

Activation_abs_SubMean <- colMeans(Activation_abs);
Energy_New_SubMean <- colMeans(Energy_New);

Index_Activation <- which(Activation_abs_SubMean > mean(Activation_abs_SubMean));
Index_Energy <- which(Energy_New_SubMean > mean(Energy_New_SubMean));
Index_Activation_Energy <- intersect(Index_Activation, Index_Energy);
P_ActivationAbs_Energy_fdr <- p.adjust(P_ActivationAbs_Energy[Index_Activation_Energy], "fdr");

Index_Activation <- which(Activation_abs_SubMean > median(Activation_abs_SubMean));
Index_Energy <- which(Energy_New_SubMean > median(Energy_New_SubMean));
Index_Activation_Energy <- intersect(Index_Activation, Index_Energy);
P_ActivationAbs_Energy_fdr <- p.adjust(P_ActivationAbs_Energy[Index_Activation_Energy], "fdr");

Activation_abs_SubSd <- matrix(0, 233, 1);
Energy_New_SubSd <- matrix(0, 233, 1);
for (i in c(1:233))
{
  Activation_abs_SubSd[i] <- sd(Activation_abs[,i]);
  Energy_New_SubSd[i] <- sd(Energy_New[,i]);
}


