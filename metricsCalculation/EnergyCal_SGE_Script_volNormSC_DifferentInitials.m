
clear

Data_Folder = '/data/joy/BBL/projects/pncClinDtiControl/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

Yeo_Index = load([Data_Folder '/atlas/Yeo_7system_in_Lausanne234.txt']);
Yeo_Index = Yeo_Index(1:233);
Yeo_Index(find(Yeo_Index ~= 6 & Yeo_Index ~= 7)) = 0;

EnergyFolder = [Data_Folder '/energyData'];
volNormSC_ResultantFolder = [EnergyFolder '/volNormSC_Energy'];
mkdir(volNormSC_ResultantFolder);

Lausanne125_volNormSC_Matrix_Cell = g_ls([Matrix_Folder '/Lausanne125/volNormSC/*.mat']);

scale_factor = 3;
T = 1;
rho = 1;
% Control nodes selection
n = 233;
xc = ones(n, 1);
% Target state, FP=1, DM=-1, others=0
xf = Yeo_Index;
xf(find(xf == 6)) = 1;
xf(find(xf == 7)) = -1;
Type = 'volNormSC';

% 1st initial state: all zeros
x0 = zeros(n, 1);
ResultantFolder_1 = [volNormSC_ResultantFolder '/Initial_AllZeros'];
EnergyCal_SGE_Function(Lausanne125_volNormSC_Matrix_Cell, scale_factor, T, xc, x0, xf, rho, Type, ResultantFolder_1);

% 2st initial state: DM 1, others 0
x0 = Yeo_Index;
x0(find(x0 == 7)) = 1;
x0(find(x0 == 6)) = 0;
ResultantFolder_2 = [volNormSC_ResultantFolder '/Initial_DM'];
EnergyCal_SGE_Function(Lausanne125_volNormSC_Matrix_Cell, scale_factor, T, xc, x0, xf, rho, Type, ResultantFolder_2);

% 3rd initial state: DM 1, FP -1, others 0
x0 = Yeo_Index;
x0(find(x0 == 7)) = 1;
x0(find(x0 == 6)) = -1;
ResultantFolder_3 = [volNormSC_ResultantFolder '/Initial_DM1FPSuppress'];
EnergyCal_SGE_Function(Lausanne125_volNormSC_Matrix_Cell, scale_factor, T, xc, x0, xf, rho, Type, ResultantFolder_3);

