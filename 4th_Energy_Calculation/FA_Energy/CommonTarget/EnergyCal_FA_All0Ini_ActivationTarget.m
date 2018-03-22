
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
xc = ones(n, 1);

% initial state: All 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Path = [Data_Folder '/Activation_803.mat'];
tmp = load(Activation_Path);
xf = mean(tmp.Activation_2b0b)';
xf = zscore(xf);

Type = 'FA';
ResultantFolder = [FA_ResultantFolder '/InitialAll0_TargetMeanActivationZScore'];
EnergyCal_SGE_Function(Lausanne125_FA_Matrix_Cell, T, xc, x0, xf, rho, Type, ResultantFolder);

% Calculating yeo average value
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system_in_Lausanne234.txt']);
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end
EnergyMat_Path = [FA_ResultantFolder '/FA_InitialAll0_TargetMeanActivationZScore.mat'];
tmp = load(EnergyMat_Path);
for j = 1:8
  Energy_YeoAvg(:, j) = mean(tmp.Energy(:, System_Indices{j}), 2);
end
save(EnergyMat_Path, 'Energy_YeoAvg', '-append');

% Calculating distance
Energy_Cell = g_ls([ResultantFolder '/*.mat']);
for i = 1:length(Energy_Cell)
  i
  tmp = load(Energy_Cell{i});
  X_Opt_Trajectory = tmp.X_Opt_Trajectory;
  Square_Sum = sum((repmat(xf', 1001, 1) - X_Opt_Trajectory).^2, 2);
  Norm_Distance = sqrt(Square_Sum);
  Distance(i, :) = Norm_Distance';
  Distance_sum(i) = sum(Norm_Distance);
end
Distance_sum = Distance_sum';
save([FA_ResultantFolder '/FA_InitialAll0_TargetMeanActivationZScore.mat'], 'Distance', 'Distance_sum', '-append');
