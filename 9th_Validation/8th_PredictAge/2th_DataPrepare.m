
clear
PredictionDataFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/AgePrediction';
tmp = load([PredictionDataFolder '/SampleIndex_SplitHalf.mat']);
Sample1_Index = tmp.Sample1_Index;
Sample2_Index = tmp.Sample2_Index;

Data = load([PredictionDataFolder '/volNormSC_Energy/Energy.mat']);
% Sample 1
Energy_Sample1 = Data.Energy(Sample1_Index, :);
save([PredictionDataFolder '/volNormSC_Energy/Energy_Sample1.mat'], 'Energy_Sample1');
% Sample 2
Energy_Sample2 = Data.Energy(Sample2_Index, :);
save([PredictionDataFolder '/volNormSC_Energy/Energy_Sample2.mat'], 'Energy_Sample2');

