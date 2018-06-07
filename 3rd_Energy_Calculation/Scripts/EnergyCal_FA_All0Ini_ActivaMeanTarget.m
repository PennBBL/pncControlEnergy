
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
ResultantFolder = [FA_ResultantFolder '/InitialAll0_TargetActivationMean'];
EnergyCal_SGE_Function(Lausanne125_FA_Matrix_Cell, T, xc, x0, xf, S, rho, Type, ResultantFolder);

% Calculating yeo average value; Yeo 7 system + subcortical system
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system_in_Lausanne234.txt']);
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end
EnergyMat_Path = [FA_ResultantFolder '/FA_InitialAll0_TargetActivationMean.mat'];
tmp = load(EnergyMat_Path);
for i = 1:8
  Energy_YeoAvg(:, i) = mean(tmp.Energy(:, System_Indices{i}), 2);
end
Energy_WholeBrainAvg = mean(tmp.Energy, 2);
save(EnergyMat_Path, 'Energy_YeoAvg', 'Energy_WholeBrainAvg', '-append');

% Dividing the energy by the absolute activation before calculating the Yeo system and whole brain average
% Because regions with high absolute activation tend to have higher energy, when we adding energy of two regions, the sum may mainly reflect the bigger one
for i = 1:233
  Energy_New(:, i) = tmp.Energy(:, i) / abs(xf(i));
end
for i = 1:8
  Energy_New_YeoAvg(:, i) = mean(Energy_New(:, System_Indices{i}), 2);
end
Energy_New_WholeBrainAvg = mean(Energy_New, 2);
save(EnergyMat_Path, 'Energy_New', 'Energy_New_YeoAvg', 'Energy_New_WholeBrainAvg', '-append')
