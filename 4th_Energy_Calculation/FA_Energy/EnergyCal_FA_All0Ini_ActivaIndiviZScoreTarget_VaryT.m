
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];
FA_ResultantFolder = [EnergyFolder '/FA_Energy'];
mkdir(FA_ResultantFolder);

Lausanne125_FA_Matrix_Cell = g_ls([Matrix_Folder '/FA/*.mat']);

T = [0.1 0.2 0.5 0.8 2 5 8 10];
rho = 1;
% Control nodes selection
n = 233;
xc = eye(n);

% initial state: all 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Path = [Data_Folder '/Activation_803.mat'];
tmp = load(Activation_Path);
Activation_803 = tmp.Activation_2b0b;
for i = 1:803
  xf_Cell{i} = zscore(Activation_803(i, :)');
end

% Nodes to be constrained
S = eye(n);

Type = 'FA';
for i = 1:length(T)
    T_Str = strrep(num2str(T(i)), '.', '');
    ResultantFolder = [FA_ResultantFolder '/InitialAll0_TargetIndividualActivationZScore_T_' T_Str];
    EnergyCal_IndividualTarget_SGE_Function(Lausanne125_FA_Matrix_Cell, T(i), xc, x0, xf_Cell, S, rho, Type, ResultantFolder);
end

% Calculating yeo average value
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system_in_Lausanne234.txt']);
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end
for i = 1:length(T)
  T_Str = strrep(num2str(T(i)), '.', '');
  EnergyMat_Path = [FA_ResultantFolder '/FA_InitialAll0_TargetIndividualActivationZScore_T_' T_Str '.mat'];
  tmp = load(EnergyMat_Path);
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(tmp.Energy(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Path, 'Energy_YeoAvg', '-append');
end

