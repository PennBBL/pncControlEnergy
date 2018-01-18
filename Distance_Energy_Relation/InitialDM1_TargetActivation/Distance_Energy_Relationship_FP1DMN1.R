
library('R.matlab')
library('ggplot2')

Energy_Folder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/energyData/SC_Energy';
x = readMat(file.path(Energy_Folder, 'SC_InitialDM1_TargetFP1DMN1.mat'));
#Distance_sum = x$Distance.sum;
Distance_sum = rowMeans(x$Distance);
Energy = x$Energy;

Energy_NodeAvg = as.vector(rowMeans(Energy));

cor.test(as.vector(Distance_sum), Energy_NodeAvg);

NodeAvg = data.frame(Distance_sum = as.vector(Distance_sum));
NodeAvg$Energy = as.vector(Energy_NodeAvg);
ggplot(NodeAvg, aes(x = Energy, y = Distance_sum)) + geom_point() + geom_smooth(method = lm) + theme(text = element_text(size=20));

Corr_All = matrix(0, 1001, 1);
Distance = x$Distance;
for (i in c(1:1001))
{
  tmp = cor.test(as.vector(Distance[,i]), as.vector(Energy_NodeAvg));
  Corr_All[i] = tmp$estimate;
}
data <- data.frame(x = c(1:1001), y = Corr_All);
ggplot(data, aes(x = x, y = Corr_All)) + labs(x = 'Time points', y = 'Corr between distance and mean energy') + geom_point(color='darkgoldenrod3') + geom_line(color='steelblue') + geom_line(data=data, aes(x = x, y = Corr_All), color='coral2')
