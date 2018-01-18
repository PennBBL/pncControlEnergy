
library('R.matlab');
library('ggplot2');

Yeo_atlas <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Energy_SC_Path <- '/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

SC_TargetFP1DMN1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetFP1DMN1.mat'));
SC_TargetDM1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetDM1.mat'));
SC_TargetFP1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetFP1.mat'));

FP1DMN1_DM1 <- data.frame(Energy_FP1DMN1 = SC_TargetFP1DMN1$Energy.SubjectsAvg, Energy_DM1 = SC_TargetDM1$Energy.SubjectsAvg);
Title <- paste('Corr = ', as.character(cor(SC_TargetFP1DMN1$Energy.SubjectsAvg, SC_TargetDM1$Energy.SubjectsAvg)), sep = '');
tiff(file.path(ResultantFolder, 'Corr_TargetFP1DMN1_TargetDM1.tif'), height = 4, width = 6, units = 'in', res = 300);
qplot(x = Energy_FP1DMN1, y = Energy_DM1, data = FP1DMN1_DM1) + ggtitle(Title) + theme(plot.title = element_text(hjust = 0.5));
dev.off();

FP1DMN1_FP1 <- data.frame(Energy_FP1DMN1 = SC_TargetFP1DMN1$Energy.SubjectsAvg, Energy_FP1 = SC_TargetFP1$Energy.SubjectsAvg);
Title <- paste('Corr = ', as.character(cor(SC_TargetFP1DMN1$Energy.SubjectsAvg, SC_TargetFP1$Energy.SubjectsAvg)), sep = '');
tiff(file.path(ResultantFolder, 'Corr_TargetFP1DMN1_TargetFP1.tiff'), height = 4, width = 6, units = 'in', res = 300);
qplot(x = Energy_FP1DMN1, y = Energy_FP1, data = FP1DMN1_FP1) + ggtitle(Title) + theme(plot.title = element_text(hjust = 0.5));
dev.off();

DM1_FP1 <- data.frame(Energy_DM1 = SC_TargetDM1$Energy.SubjectsAvg, Energy_FP1 = SC_TargetFP1$Energy.SubjectsAvg);
Title <- paste('Corr = ', as.character(cor(SC_TargetDM1$Energy.SubjectsAvg, SC_TargetFP1$Energy.SubjectsAvg)), sep = '');
tiff(file.path(ResultantFolder, 'Corr_TargetDM1_TargetFP1.tiff'), height = 4, width = 6, units = 'in', res = 300);
qplot(x = Energy_DM1, y = Energy_FP1, data = DM1_FP1) + ggtitle(Title) + theme(plot.title = element_text(hjust = 0.5));
dev.off();
