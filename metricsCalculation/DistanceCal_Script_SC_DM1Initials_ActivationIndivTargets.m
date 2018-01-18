
clear

EnergyData_Folder = '/Users/zaixucui/Documents/projects/pncControlEnergy/data/energyData/SC_Energy';
Energy_Cell = g_ls([EnergyData_Folder '/InitialDM1_TargetIndividualActivation/*.mat']);
load('/Users/zaixucui/Documents/projects/pncControlEnergy/results/Activation/Activation.mat');
xf = Activation_2b0b;
for i = 1:length(Energy_Cell)
  i
  tmp = load(Energy_Cell{i});
  X_Opt_Trajectory = tmp.X_Opt_Trajectory;
  Square_Sum = sum((repmat(xf(i, :), 1001, 1) - X_Opt_Trajectory).^2, 2);
  Norm_Distance = sqrt(Square_Sum);
  Distance(i, :) = Norm_Distance';
  Distance_sum(i) = sum(Norm_Distance);
end
save([EnergyData_Folder '/SC_InitialDM1_TargetIndividualActivation.mat'], 'Distance', 'Distance_sum', '-append');
