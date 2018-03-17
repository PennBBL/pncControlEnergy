
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];
FA_ResultantFolder = [EnergyFolder '/FA_Energy'];
mkdir(FA_ResultantFolder);

Lausanne125_FA_Matrix_Cell = g_ls([Matrix_Folder '/FA/*.mat']);

T = 1;
rho = [0.1 0.2 0.5 0.8 2 5 8 10];
% Control nodes selection
n = 233;
xc = ones(n, 1);

% initial state: all 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Path = [Data_Folder '/ActivationData/nback_2b0b_20180202.mat'];
tmp = load(Activation_Path);
Activation_677 = tmp.Activation_2b0b;
Include_Index = tmp.Include_Index;
for i = 1:677
  xf_Cell{i} = zscore(Activation_677(i, :)');
end

Type = 'FA';
for i = 1:length(rho)
    rho_Str = strrep(num2str(rho(i)), '.', '');
    ResultantFolder = [FA_ResultantFolder '/InitialAll0_TargetIndividualActivationZScore_rho_' rho_Str];
    EnergyCal_IndividualTarget_SGE_Function(Lausanne125_FA_Matrix_Cell(Include_Index), T, xc, x0, xf_Cell, rho(i), Type, ResultantFolder);
end

% Calculating yeo average value
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system_in_Lausanne234.txt']);
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end
for i = 1:length(rho)
  rho_Str = strrep(num2str(rho(i)), '.', '');
  EnergyMat_Path = [FA_ResultantFolder '/FA_InitialAll0_TargetIndividualActivationZScore_rho_' rho_Str '.mat'];
  tmp = load(EnergyMat_Path);
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(tmp.Energy(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Path, 'Energy_YeoAvg', '-append');
end

% Calculating distance
for i = 1:length(rho)
  rho_Str = strrep(num2str(rho(i)), '.', '');
  ResultantFolder = [FA_ResultantFolder '/InitialAll0_TargetIndividualActivationZScore_rho_' rho_Str];
  Energy_Cell = g_ls([ResultantFolder '/*.mat']);
  for i = 1:length(Energy_Cell)
    i
    tmp = load(Energy_Cell{i});
    X_Opt_Trajectory = tmp.X_Opt_Trajectory;
    Square_Sum = sum((repmat(xf_Cell{i}', 1001, 1) - X_Opt_Trajectory).^2, 2);
    Norm_Distance = sqrt(Square_Sum);
    Distance(i, :) = Norm_Distance';
    Distance_sum(i) = sum(Norm_Distance);
  end
  Distance_sum = Distance_sum';
  save([FA_ResultantFolder '/FA_InitialAll0_TargetIndividualActivationZScore_rho_' rho_Str '.mat'], 'Distance', 'Distance_sum', '-append');
end
