
Energy_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy/';
Energy_Mat = load([Energy_Folder '/SC_InitialDM1_TargetFP1DMN1.mat']);
Activation_Mat = load('/data/jux/BBL/projects/pncControlEnergy/results/Activation/Activation.mat');
Activation = Activation_Mat.Activation_2b0b;
for i = 1:length(Activation_Mat.Scan_ID_SC)
    Index = find(Energy_Mat.scan_ID == Activation_Mat.Scan_ID_SC(i));
    Energy_New(i, :) = Energy_Mat.Energy(Index, :);
end
Activation_zscore = zscore(Activation);
Energy_New_zscore = zscore(Energy_New);

Activation_abs = abs(Activation);
Activation_abs_zscore = zscore(Activation_abs);
Energy_New_log2 = log2(Energy_New);
Energy_New_log2_zscore = zscore(Energy_New_log2);

ResultantFolder = '/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetFP1DMN1/Energy_Activation_Relationship';
save([ResultantFolder '/Energy_Activation.mat'], 'Activation', 'Energy_New', 'Activation_abs', 'Energy_New_log2', 'Activation_zscore', 'Energy_New_zscore', 'Activation_abs_zscore', 'Energy_New_log2_zscore');
BrainMatrix = Energy_New_zscore;
save([ResultantFolder '/Energy_New_zscore.mat'], 'BrainMatrix');
BrainMatrix = Energy_New_log2_zscore;
save([ResultantFolder '/Energy_New_log2_zscore.mat'], 'BrainMatrix');
BehaviorMatrix = Activation_zscore;
save([ResultantFolder '/Activation_zscore.mat'], 'BehaviorMatrix');
BehaviorMatrix = Activation_abs_zscore;
save([ResultantFolder '/Activation_abs_zscore.mat'], 'BehaviorMatrix');
