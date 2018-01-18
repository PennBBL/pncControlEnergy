
library('R.matlab');
library('ggplot2');

Yeo_atlas <- readMat('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
Energy_SC_Path <- '/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
ResultantFolder <- '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

SC_AllZeros <- readMat(file.path(Energy_SC_Path, 'SC_InitialAll0_TargetFP1DMN1.mat'));
SC_DM <- readMat(file.path(Energy_SC_Path, 'SC_InitialDM1_TargetFP1DMN1.mat'));
SC_DM1FPSuppress <- readMat(file.path(Energy_SC_Path, 'SC_InitialDM1FPN1_TargetFP1DMN1.mat'));

AllZeros_Energy=SC_AllZeros$Energy.SubjectsAvg;
DM_Energy=SC_DM$Energy.SubjectsAvg;
DM1FPSuppress_Energy=SC_DM1FPSuppress$Energy.SubjectsAvg;

data<-data.frame(x=c(1:233),y=AllZeros_Energy, DM_Energy, DM1FPSuppress_Energy);
tiff(file.path(ResultantFolder, 'DotLine_ThreeInitialStates.tif'), height = 4, width = 6, units = 'in', res = 300);
ggplot(data, aes(x=x, y=AllZeros_Energy)) + labs(x = 'Nodes ID', y = 'Energy') + geom_line(color='steelblue') + geom_line(data=data, aes(x=x, y=DM_Energy), color='coral2') + geom_line(data=data, aes(x=x, y=DM1FPSuppress_Energy), color='darkgoldenrod3') + geom_line(data=data, aes(x=x, y=AllZeros_Energy + 25000), color = 'steelblue') + geom_line(data=data, aes(x=x, y=DM_Energy+50000), color='steelblue') + geom_line(data=data, aes(x=x, y=DM1FPSuppress_Energy+75000), color='steelblue') + geom_point(color='darkgoldenrod3');
dev.off();


