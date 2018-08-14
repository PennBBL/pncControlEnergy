
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];

Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);

T = 1;
rho = 1;
% Control nodes selection
n = 232;
xc = eye(n);

% initial state: all 0
x0 = zeros(n, 1);

Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system.mat']);
Atlas_Yeo_Index = Atlas_Yeo_Index.Yeo_7system([1:191 193:233]); % Remove the 192th region
% Target state: average activation data 
xf = Atlas_Yeo_Index;
xf(find(xf ~= 6)) = 0;
xf(find(xf == 6)) = 1;

% Nodes to be constrained
S = eye(n);

% Extract indices of Yeo system
for j = 1:8
  System_Indices{j} = find(Atlas_Yeo_Index == j);
end

for i = 65:100
  RandIndex = randperm(232);
  xf_Shuffle = xf(RandIndex);
  ResultantFolder = [EnergyFolder '/ShuffledTargets/InitialAll0_TargetFPShuffle_' num2str(i)];
  mkdir(ResultantFolder);
  save([ResultantFolder '/xf_Shuffle.mat'], 'xf_Shuffle');
  EnergyCal_SGE_Function(Lausanne125_Matrix_Cell, T, xc, x0, xf_Shuffle, S, rho, ResultantFolder);
end

for i = 1:100
  % Calculating yeo average value; Yeo 7 system + subcortical system
  EnergyMat_Path = [EnergyFolder '/ShuffledTargets/InitialAll0_TargetFPShuffle_' num2str(i) '.mat'];
  Energy_Mat = load(EnergyMat_Path);
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(Energy_Mat.Energy(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Path, 'Energy_YeoAvg', '-append');
end
