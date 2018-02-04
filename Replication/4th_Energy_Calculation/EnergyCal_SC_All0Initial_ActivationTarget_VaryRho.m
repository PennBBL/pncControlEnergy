
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
% rho = [0.1 0.2 0.5 0.8 2 5 8 10];
rho = [0.2 0.5 0.8 2 5 8 10];
% Control nodes selection
n = 233;
xc = ones(n, 1);

% initial state: DM 1, others 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Path = '/data/jux/BBL/projects/pncControlEnergy/results/Activation/Activation.mat';
tmp = load(Activation_Path);
xf = tmp.Activation_Avg';
Type = 'SC';

for i = 1:length(rho)
    rho_Str = strrep(num2str(rho(i)), '.', '');
    ResultantFolder = [SC_ResultantFolder '/InitialAll0_TargetActivation_rho_' rho_Str];
    EnergyCal_SGE_Function(Lausanne125_SC_Matrix_Cell, T, xc, x0, xf, rho(i), Type, ResultantFolder);
end
