
library('R.matlab');
library('ggplot2');

Yeo_atlas <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Energy_SC_Path <- '/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

SC_AllZeros <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetFP1DMN1.mat'));
SC_DM <- readMat(file.path(Energy_SC_Path, 'SC_InitialDM1_TargetFP1DMN1.mat'));
SC_DM1FPSuppress <- readMat(file.path(Energy_SC_Path, 'SC_InitialDM1FPN1_TargetFP1DMN1.mat'));

AllZeros_DM <- data.frame(Energy_AllZeros = SC_AllZeros$Energy.SubjectsAvg, Energy_DM = SC_DM$Energy.SubjectsAvg);
Title <- paste('Corr = ', as.character(cor(SC_AllZeros$Energy.SubjectsAvg, SC_DM$Energy.SubjectsAvg)), sep = '');
tiff(file.path(ResultantFolder, 'Corr_InitialAll0_InitialDM1.tif'), height = 4, width = 6, units = 'in', res = 300);
qplot(x = Energy_AllZeros, y = Energy_DM, data = AllZeros_DM) + ggtitle(Title) + theme(plot.title = element_text(hjust = 0.5));
dev.off();

AllZeros_DM1FPSuppress <- data.frame(Energy_AllZeros = SC_AllZeros$Energy.SubjectsAvg, Energy_DM1FPSuppress = SC_DM1FPSuppress$Energy.SubjectsAvg);
Title <- paste('Corr = ', as.character(cor(SC_AllZeros$Energy.SubjectsAvg, SC_DM1FPSuppress$Energy.SubjectsAvg)), sep = '');
tiff(file.path(ResultantFolder, 'Corr_InitialAll0_InitialDM1FPN1.tiff'), height = 4, width = 6, units = 'in', res = 300);
qplot(x = Energy_AllZeros, y = Energy_DM1FPSuppress, data = AllZeros_DM1FPSuppress) + ggtitle(Title) + theme(plot.title = element_text(hjust = 0.5));
dev.off();

DM_DM1FPSuppress <- data.frame(Energy_DM = SC_DM$Energy.SubjectsAvg, Energy_DM1FPSuppress = SC_DM1FPSuppress$Energy.SubjectsAvg);
Title <- paste('Corr = ', as.character(cor(SC_DM$Energy.SubjectsAvg, SC_DM1FPSuppress$Energy.SubjectsAvg)), sep = '');
tiff(file.path(ResultantFolder, 'Corr_InitialDM1_InitialDM1FPN1.tiff'), height = 4, width = 6, units = 'in', res = 300);
qplot(x = Energy_DM, y = Energy_DM1FPSuppress, data = DM_DM1FPSuppress) + ggtitle(Title) + theme(plot.title = element_text(hjust = 0.5));
dev.off();
