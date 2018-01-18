
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

Yeo_Index = load([Data_Folder '/atlas/Yeo_7system_in_Lausanne234.txt']);
Yeo_Index = Yeo_Index(1:233);

EnergyFolder = [Data_Folder '/energyData'];
SC_ResultantFolder = [EnergyFolder '/SC_Energy'];
mkdir(SC_ResultantFolder);

Lausanne125_SC_Matrix_Cell = g_ls([Matrix_Folder '/Lausanne125/SC/*.mat']);

T = 1;
rho = 1;
% Control nodes selection
n = 233;
%xc = ones(n, 1);
xc = Yeo_Index;
xc(find(xc == 1 | xc == 2 | xc == 5 | xc == 7 | xc == 8)) = 0;
xc(find(xc)) = 1;

% initial state: DM 1, others 0
x0 = Yeo_Index;
x0(find(x0 ~= 7)) = 0;
x0(find(x0 == 7)) = 1;

% Target state: average activation data 
Activation_Path = '/data/jux/BBL/projects/pncControlEnergy/results/Activation/Activation.mat';
tmp = load(Activation_Path);
xf = tmp.Activation_Avg';

ResultantFolder_2 = [SC_ResultantFolder '/InitialDM1_TargetActi_Con346'];
Type = 'SC';
EnergyCal_SGE_Function(Lausanne125_SC_Matrix_Cell, 1400, T, xc, x0, xf, rho, Type, ResultantFolder_2);
