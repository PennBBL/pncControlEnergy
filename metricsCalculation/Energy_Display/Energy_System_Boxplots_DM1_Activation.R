
library('R.matlab');
library('ggplot2');

Yeo_atlas <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Energy_SC_Path <- '/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

SC_InitialDM1_TargetActivation <- readMat(file.path(Energy_SC_Path, 'SC_InitialDM1_TargetActivation.mat'));
tmp <- data.frame(Energy_data = SC_InitialDM1_TargetActivation$Energy.SubjectsAvg, Yeo = Yeo_atlas$Yeo.7system);
tmp$Yeo <- factor(tmp$Yeo, levels = c(1:8), labels = c("Visual","SM", "DA", "VA", "limbic","FP","DM","SC"));
tiff(file.path(ResultantFolder, 'Scatter_SC_InitialDM1_TargetActivation.tiff'), height = 4, width = 6, units = 'in', res = 300);
qplot(Yeo, Energy_data, data = tmp, geom=c("boxplot","jitter"), fill=Yeo, xlab="Yeo systems", ylab="Energy") + ggtitle("Initial DM 1; Target activation") + theme(plot.title = element_text(hjust = 0.5));
dev.off();


