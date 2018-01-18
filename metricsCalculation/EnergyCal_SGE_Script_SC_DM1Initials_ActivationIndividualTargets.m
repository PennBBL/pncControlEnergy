
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

% initial state: DM 1, others 0
x0 = Yeo_Index;
x0(find(x0 == 7)) = 1;
x0(find(x0 == 6)) = 0;

% Target state: average activation data 
Activation_Path = '/data/joy/BBL/projects/pncControlEnergy/results/Activation/Activation.mat';
tmp = load(Activation_Path);
Activation_677 = tmp.Activation_2b0b;
Include_Index = tmp.Include_Index;
for i = 1:677
  xf_Cell{i} = Activation_677(i, :)';
end

Type = 'SC';
ResultantFolder_2 = [SC_ResultantFolder '/InitialDM1_TargetIndividualActivation'];
EnergyCal_IndividualTarget_SGE_Function(Lausanne125_SC_Matrix_Cell(Include_Index), scale_factor, T, xc, x0, xf_Cell, rho, Type, ResultantFolder_2);
