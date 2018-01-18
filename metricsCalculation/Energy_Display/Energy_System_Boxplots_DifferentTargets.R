
library('R.matlab');
library('ggplot2');

Yeo_atlas <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Energy_SC_Path <- '/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

SC_AllZeros_TargetDM1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetDM1.mat'));
tmp <- data.frame(Energy_data = SC_AllZeros_TargetDM1$Energy.SubjectsAvg, Yeo = Yeo_atlas$Yeo.7system);
tmp$Yeo <- factor(tmp$Yeo, levels = c(1:8), labels = c("Visual","SM", "DA", "VA", "limbic","FP","DM","SC"));
tiff(file.path(ResultantFolder, 'Scatter_SC_InitialAll0_TargetDM1.tiff'), height = 4, width = 6, units = 'in', res = 300);
qplot(Yeo, Energy_data, data = tmp, geom=c("boxplot","jitter"), fill=Yeo, xlab="Yeo systems", ylab="Energy") + ggtitle("Initial all 0; Target DM 1") + theme(plot.title = element_text(hjust = 0.5));
dev.off();

SC_AllZeros_TargetFP1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetFP1.mat'));
tmp <- data.frame(Energy_data = SC_AllZeros_TargetFP1$Energy.SubjectsAvg, Yeo = Yeo_atlas$Yeo.7system);
tmp$Yeo <- factor(tmp$Yeo, levels = c(1:8), labels = c("Visual","SM", "DA", "VA", "limbic","FP","DM","SC"));
tiff(file.path(ResultantFolder, 'Scatter_SC_InitialAll0_TargetFP1.tiff'), height = 4, width = 6, units = 'in', res = 300);
qplot(Yeo, Energy_data, data = tmp, geom=c("boxplot","jitter"), fill=Yeo, xlab="Yeo systems", ylab="Energy") + ggtitle("Initial all 0; Target FP 1") + theme(plot.title = element_text(hjust = 0.5));
dev.off();

