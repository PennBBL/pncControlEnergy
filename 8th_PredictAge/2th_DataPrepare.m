
clear
PredictionDataFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/AgePrediction';
Behavior = load([PredictionDataFolder '/Behavior.mat']);

[~, Sorted_Indice] = sort(Behavior.Age);
Sample2_Index = Sorted_Indice([1:2:end]);
Sample1_Index = setdiff(Sorted_Indice, Sample2_Index);
Sample2_Index = sort(Sample2_Index);
save([PredictionDataFolder '/SampleIndex_SplitHalf.mat'], 'Sample1_Index', 'Sample2_Index');
% All Sample, age
Age_AllSubjects = Behavior.Age;
save([PredictionDataFolder '/Age_AllSubjects.mat'], 'Age_AllSubjects');

Data = load([PredictionDataFolder '/FA_Energy/Energy.mat']);
% Sample 1
Energy_Sample1 = Data.Energy(Sample1_Index, :);
Age_Sample1 = double(Behavior.Age(Sample1_Index));
save([PredictionDataFolder '/FA_Energy/Energy_Sample1.mat'], 'Energy_Sample1');
save([PredictionDataFolder '/Age_Sample1.mat'], 'Age_Sample1');
% Sample 2
Energy_Sample2 = Data.Energy(Sample2_Index, :);
Age_Sample2 = double(Behavior.Age(Sample2_Index));
save([PredictionDataFolder '/FA_Energy/Energy_Sample2.mat'], 'Energy_Sample2');
save([PredictionDataFolder '/Age_Sample2.mat'], 'Age_Sample2');

