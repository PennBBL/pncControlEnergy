
clear

EnergyData_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
Energy_Cell = g_ls([EnergyData_Folder '/InitialDM1_TargetActivation/*.mat']);
load('/data/jux/BBL/projects/pncControlEnergy/results/Activation/Activation.mat');
xf = Activation_Avg;
for i = 1:length(Energy_Cell)
  i
  tmp = load(Energy_Cell{i});
  X_Opt_Trajectory = tmp.X_Opt_Trajectory;
  Square_Sum = sum((repmat(xf, 1001, 1) - X_Opt_Trajectory).^2, 2);
  Norm_Distance = sqrt(Square_Sum);
  Distance(i, :) = Norm_Distance';
  Distance_sum(i) = sum(Norm_Distance);
 
end
save([EnergyData_Folder '/SC_InitialDM1_TargetActivation_2.mat'], 'Distance', 'Distance_sum', '-append');
