
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
xc = ones(n, 1);

% initial state: All 0
x0 = zeros(n, 1);

% Target state: average activation data 
xf = Yeo_Index;
xf(find(xf ~= 2)) = 0;
xf(find(xf == 2)) = 1;

ResultantFolder = [SC_ResultantFolder '/Replication/InitialAll0_TargetMotor1'];
Type = 'SC';
EnergyCal_SGE_Function(Lausanne125_SC_Matrix_Cell, T, xc, x0, xf, rho, Type, ResultantFolder);
