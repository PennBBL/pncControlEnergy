
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

Yeo_Index = load([Data_Folder '/atlas/Yeo_7system_in_Lausanne234.txt']);
Yeo_Index = Yeo_Index(1:233);
Yeo_Index(find(Yeo_Index ~= 6 & Yeo_Index ~= 7)) = 0;

EnergyFolder = [Data_Folder '/energyData'];
SC_ResultantFolder = [EnergyFolder '/SC_Energy'];
mkdir(SC_ResultantFolder);

Lausanne125_SC_Matrix_Cell = g_ls([Matrix_Folder '/Lausanne125/SC/*.mat']);

T = 1;
rho = 1;
% Control nodes selection
n = 233;
xc = ones(n, 1);

% initial state: All 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Path = '/data/jux/BBL/projects/pncControlEnergy/data/subjectData/nback_2b0b_20180202.mat';
tmp = load(Activation_Path);
xf = tmp.Activation_2b0b_Avg;

ResultantFolder = [SC_ResultantFolder '/Replication/InitialAll0_TargetActivation'];
Type = 'SC';
EnergyCal_SGE_Function(Lausanne125_SC_Matrix_Cell, T, xc, x0, xf, rho, Type, ResultantFolder);

pause(20);

% Calculating yeo average value
Atlas_Yeo_Index = load('/data/jux/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system_in_Lausanne234.txt');
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end      
EnergyMat_Path = [SC_ResultantFolder '/Replication/SC_InitialAll0_TargetActivation.mat'];
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
save([SC_ResultantFolder '/Replication/SC_InitialAll0_TargetActivation.mat'], 'Distance', 'Distance_sum', '-append');
