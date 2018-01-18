
library('R.matlab');
library('ggplot2');

Yeo_atlas <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Energy_SC_Path <- '/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

SC_TargetFP1DMN1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetFP1DMN1.mat'));
SC_TargetDM1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetDM1.mat'));
SC_TargetFP1 <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetFP1.mat'));

FP1DMN1_Energy=SC_TargetFP1DMN1$Energy.SubjectsAvg;
DM1_Energy=SC_TargetDM1$Energy.SubjectsAvg;
FP1_Energy=SC_TargetFP1$Energy.SubjectsAvg;

data<-data.frame(x=c(1:233), y=FP1DMN1_Energy, DM1_Energy, FP1_Energy);
tiff(file.path(ResultantFolder, 'DotLine_ThreeTargetStates.tif'), height = 4, width = 6, units = 'in', res = 300);
ggplot(data, aes(x=x, y=FP1DMN1_Energy)) + labs(x = 'Nodes ID', y = 'Energy') + geom_line(color='steelblue') + geom_line(data=data, aes(x=x, y=DM1_Energy), color='coral2') + geom_line(data=data, aes(x=x, y=FP1_Energy), color='darkgoldenrod3') + geom_line(data=data, aes(x=x, y=FP1DMN1_Energy + 25000), color = 'steelblue') + geom_line(data=data, aes(x=x, y=DM1_Energy+50000), color='steelblue') + geom_line(data=data, aes(x=x, y=FP1_Energy+75000), color='steelblue');
dev.off();


