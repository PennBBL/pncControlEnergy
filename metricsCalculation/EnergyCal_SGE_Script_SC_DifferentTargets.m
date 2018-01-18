
clear

Data_Folder = '/data/joy/BBL/projects/pncControlEnergy/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

Yeo_Index = load([Data_Folder '/atlas/Yeo_7system_in_Lausanne234.txt']);
Yeo_Index = Yeo_Index(1:233);
Yeo_Index(find(Yeo_Index ~= 6 & Yeo_Index ~= 7)) = 0;

EnergyFolder = [Data_Folder '/energyData'];
SC_ResultantFolder = [EnergyFolder '/SC_Energy'];
mkdir(SC_ResultantFolder);

Lausanne125_SC_Matrix_Cell = g_ls([Matrix_Folder '/Lausanne125/SC/*.mat']);

scale_factor = 1200;
T = 1;
rho = 1;
% Control nodes selection
n = 233;
xc = ones(n, 1);
% Initial state: all zeros
x0 = zeros(n, 1);
% 1st target state, DM=1, others=0
xf = Yeo_Index;
xf(find(xf == 6)) = 0;
xf(find(xf == 7)) = 1;
Type = 'SC';
ResultantFolder_1 = [SC_ResultantFolder '/InitialAll0_TargetDM1'];
EnergyCal_SGE_Function(Lausanne125_SC_Matrix_Cell, scale_factor, T, xc, x0, xf, rho, Type, ResultantFolder_1);
% 2st target state, FP=1, others=0
xf = Yeo_Index;
xf(find(xf == 6)) = 1;
xf(find(xf == 7)) = 0;
ResultantFolder_2 = [SC_ResultantFolder '/InitialAll0_TargetFP1'];
EnergyCal_SGE_Function(Lausanne125_SC_Matrix_Cell, scale_factor, T, xc, x0, xf, rho, Type, ResultantFolder_2);
