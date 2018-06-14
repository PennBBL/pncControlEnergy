
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];

Lausanne125_FA_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);

T = 1;
rho = [0.1 0.2 0.5 0.8 2 5 8 10];
% Control nodes selection
n = 233;
xc = eye(n);

% initial state: all 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Mat = load([Data_Folder '/Activation_677_Avg.mat']);
xf = Activation_Mat.Activation_677_Avg;

% Nodes to be constrained
S = eye(n);

for i = 1:length(rho)
  rho_Str = strrep(num2str(rho(i)), '.', '');
  ResultantFolder = [EnergyFolder '/InitialAll0_TargetActivationMean_rho_' rho_Str];
  EnergyCal_SGE_Function(Lausanne125_FA_Matrix_Cell, T, xc, x0, xf, S, rho(i), ResultantFolder);
end

% Calculating yeo average value; Yeo 7 system + subcortical system
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system_in_Lausanne234.txt']);
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end
for i = 1:length(rho)
  rho_Str = strrep(num2str(rho(i)), '.', '');
  EnergyMat_Path = [EnergyFolder '/InitialAll0_TargetActivationMean_rho_' rho_Str '.mat'];
  Energy_Mat = load(EnergyMat_Path);
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(Energy_Mat.Energy(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Path, 'Energy_YeoAvg', '-append');
  % Dividing the energy by the absolute activation before calculating the Yeo system level effects
  % Because regions with high absolute activation tend to have higher energy, when we adding energy of two regions, the sum may mainly reflect the bigger one
  for j = 1:233
    Energy_New(:, j) = Energy_Mat.Energy(:, j) / abs(xf(j));
  end
  for j = 1:8
    Energy_New_YeoAvg(:, j) = mean(Energy_New(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Path, 'Energy_New', 'Energy_New_YeoAvg', '-append');
end
