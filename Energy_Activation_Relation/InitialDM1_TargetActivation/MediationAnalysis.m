
Energy_Activation = load('/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetActivation/Energy_Activation_Relationship/Energy_Activation.mat');
Activation_abs = Energy_Activation.Activation_abs;
Energy_New = Energy_Activation.Energy_New;
corr(Activation_abs(:, 184), Energy_New(:, 184));


