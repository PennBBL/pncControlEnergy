
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];
FA_ResultantFolder = [EnergyFolder '/FA_Energy'];
mkdir(FA_ResultantFolder);

Lausanne125_FA_Matrix_Cell = g_ls([Matrix_Folder '/FA/*.mat']);

T = 1;
rho = 1;
% Control nodes selection
n = 233;
xc = eye(n);

% initial state: all 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Path = [Data_Folder '/Activation_677_Avg.mat'];
tmp = load(Activation_Path);
xf = tmp.Activation_677_Avg;

% Nodes to be constrained
S = eye(n);
Type = 'FA';

% Extract indices of Yeo system
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system_in_Lausanne234.txt']);
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for j = 1:8
  System_Indices{j} = find(Atlas_Yeo_Index == j);
end

for i = 37:100
  RandIndex = randperm(233);
  xf_Random = xf(RandIndex);
  ResultantFolder = [FA_ResultantFolder '/InitialAll0_TargetActivationMeanRandom_' num2str(i)];
  mkdir(ResultantFolder);
  save([ResultantFolder '/xf_Random.mat'], 'xf_Random');
  EnergyCal_SGE_Function(Lausanne125_FA_Matrix_Cell, T, xc, x0, xf_Random, S, rho, Type, ResultantFolder);
end

for i = 1:100
  % Calculating yeo average value; Yeo 7 system + subcortical system
  EnergyMat_Path = [FA_ResultantFolder '/FA_InitialAll0_TargetActivationMeanRandom_' num2str(i) '.mat'];
  tmp = load(EnergyMat_Path);
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(tmp.Energy(:, System_Indices{j}), 2);
  end
  Energy_WholeBrainAvg = mean(tmp.Energy, 2);
  save(EnergyMat_Path, 'Energy_YeoAvg', 'Energy_WholeBrainAvg', '-append');

  % Dividing the energy by the absolute activation before calculating the Yeo system and whole brain average
  % Because regions with high absolute activation tend to have higher energy, when we adding energy of two regions, the sum may mainly reflect the bigger one
  TargetState = load([FA_ResultantFolder '/InitialAll0_TargetActivationMeanRandom_' num2str(i) '/xf_Random.mat']);
  xf_Random = TargetState.xf_Random;
  for j = 1:233
    Energy_New(:, j) = tmp.Energy(:, j) / abs(xf_Random(j));
  end
  for j = 1:8
    Energy_New_YeoAvg(:, j) = mean(Energy_New(:, System_Indices{j}), 2);
  end
  Energy_New_WholeBrainAvg = mean(Energy_New, 2);
  save(EnergyMat_Path, 'Energy_New', 'Energy_New_YeoAvg', 'Energy_New_WholeBrainAvg', '-append')
end
