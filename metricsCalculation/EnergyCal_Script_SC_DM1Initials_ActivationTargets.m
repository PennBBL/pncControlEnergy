
clear

EnergyData_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
Energy_Cell = g_ls([EnergyData_Folder '/InitialDM1_TargetActivation/*.mat']);
load('/data/jux/BBL/projects/pncControlEnergy/results/Activation/Activation.mat');
xf = Activation_Avg;
for i = 1:length(Energy_Cell)
  i
  tmp = load(Energy_Cell{i});
  U_Opt_Trajectory = tmp.U_Opt_Trajectory;
  Square_Sum = sum(U_Opt_Trajectory.^2, 2);
  Energy_ForEachTime(i, :) = Square_Sum;
end
save([EnergyData_Folder '/SC_InitialDM1_TargetActivation.mat'], 'Energy_ForEachtime', '-append');
