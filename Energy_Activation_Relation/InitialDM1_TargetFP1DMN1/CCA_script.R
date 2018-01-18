
library('R.matlab')

WorkFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetFP1DMN1/Energy_Activation_Relationship/';
Mat <- readMat(file.path(WorkFolder,'Energy_Activation.mat'))
Activation <- Mat$Activation.zscore;
Energy <- Mat$Energy.New.zscore;
Activation_abs <- Mat$Activation.abs.zscore;
Energy_log2 <- Mat$Energy.New.log2.zscore;
source('/data/jux/BBL/projects/pncControlEnergy/scripts/Energy_Activation_Relation/InitialDM1_TargetActivation/ZC_CCA.R');

ResultantFile <- file.path(WorkFolder, 'CCA_Energy_Activation.mat');
#CCA_function(Energy, Activation, ResultantFile);
ResultantFile <- file.path(WorkFolder, 'CCA_Energy_ActivationAbs.mat');
#CCA_function(Energy, Activation_abs, ResultantFile);
ResultantFile <- file.path(WorkFolder, 'CCA_EnergyLog2_Activation.mat');
#CCA_function(Energy_log2, Activation, ResultantFile);
ResultantFile <- file.path(WorkFolder, 'CCA_EnergyLog2_ActivationAbs.mat');
#CCA_function(Energy_log2, Activation_abs, ResultantFile);

#ResultantFile <- file.path(WorkFolder, 'CCA_Energy_Activation_Permutation.mat');
#CCA_Permutation_Function(Energy, Activation, 1000, ResultantFile);
#ResultantFile <- file.path(WorkFolder, 'CCA_Energy_ActivationAbs_Permutation.mat');
#CCA_Permutation_Function(Energy, Activation_abs, 1000, ResultantFile);
#ResultantFile <- file.path(WorkFolder, 'CCA_EnergyLog2_Activation_Permutation.mat');
#CCA_Permutation_Function(Energy_log2, Activation, 1000, ResultantFile);
#ResultantFile <- file.path(WorkFolder, 'CCA_EnergyLog2_ActivationAbs_Permutation.mat');
#CCA_Permutation_Function(Energy_log2, Activation_abs, 1000, ResultantFile);

Activation_Path <- file.path(WorkFolder, '/Activation_zscore.mat');
ActivationAbs_Path <- file.path(WorkFolder, '/Activation_abs_zscore.mat');
Energy_Path <- file.path(WorkFolder, 'Energy_New_zscore.mat');
EnergyLog2_Path <- file.path(WorkFolder, 'Energy_New_log2_zscore.mat');

Max_Queued <- 1000;
Queue_Options <- '-q all.q';
ResultantFolder <- file.path(WorkFolder, 'CCA_Energy_Activation_Permutation');
CCA_Permutation_SGE_function(Energy_Path, Activation_Path, c(1:1000), ResultantFolder, Max_Queued, Queue_Options);
ResultantFolder <- file.path(WorkFolder, 'CCA_Energy_ActivationAbs_Permutation');
CCA_Permutation_SGE_function(Energy_Path, ActivationAbs_Path, c(1:1000), ResultantFolder, Max_Queued, Queue_Options);
ResultantFolder <- file.path(WorkFolder, 'CCA_EnergyLog2_Activation_Permutation');
CCA_Permutation_SGE_function(EnergyLog2_Path, Activation_Path, c(1:1000), ResultantFolder, Max_Queued, Queue_Options);
ResultantFolder <- file.path(WorkFolder, 'CCA_EnergyLog2_ActivationAbs_Permutation');
CCA_Permutation_SGE_function(EnergyLog2_Path, ActivationAbs_Path, c(1:1000), ResultantFolder, Max_Queued, Queue_Options);
