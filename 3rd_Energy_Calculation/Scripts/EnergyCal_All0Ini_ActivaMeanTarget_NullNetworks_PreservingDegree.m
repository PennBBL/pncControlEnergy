
clear

% Energy of null networks (only preserving degree distribution)

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];

T = 1;
rho = 1;
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

% Extract indices of Yeo system
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system_in_Lausanne234.txt']);
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for j = 1:8
  System_Indices{j} = find(Atlas_Yeo_Index == j);
end

for i = 1:100
  Lausanne125_FA_Matrix_Cell = g_ls([Matrix_Folder '_NullNetworks_PreservingDegree/NullNetwork_' num2str(i, '%03d') '/*.mat']);
  ResultantFolder = [EnergyFolder '/NullNetworks_PreservingDegree/InitialAll0_TargetActivationMean_NullNetwork_' num2str(i)];
  mkdir(ResultantFolder);
  EnergyCal_SGE_Function(Lausanne125_FA_Matrix_Cell, T, xc, x0, xf, S, rho, ResultantFolder);
end

for i = 1:100
  % Calculating yeo average value; Yeo 7 system + subcortical system
  EnergyMat_Path = [EnergyFolder '/NullNetworks_PreservingDegree/InitialAll0_TargetActivationMean_NullNetwork_' num2str(i) '.mat'];
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
  save(EnergyMat_Path, 'Energy_New', 'Energy_New_YeoAvg', '-append')
end
