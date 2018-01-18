
library('R.matlab')
library('ggplot2')

Energy_Folder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
x = readMat(file.path(Energy_Folder, 'SC_InitialDM1_TargetFP1DMN1.mat'));
Distance = x$Distance;
Energy = x$Energy;

Energy_NodeAvg = rowMeans(Energy);

cor.test(as.vector(Distance), as.vector(Energy_NodeAvg));

NodeAvg = data.frame(Distance = as.vector(Distance));
NodeAvg$Energy = as.vector(Energy_NodeAvg);
ggplot(NodeAvg, aes(x = Energy, y = Distance)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20));

