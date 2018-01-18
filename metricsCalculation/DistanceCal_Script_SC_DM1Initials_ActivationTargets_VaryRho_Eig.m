
clear

EnergyData_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';

rho = [0.001 0.01 0.1 1 2 10 100 1000];
for i = 1:4 %5:length(rho)
  rho_Str = strrep(num2str(rho(i)), '.', '');
  Energy_Cell = g_ls([EnergyData_Folder '/InitialDM1_TargetActivation_ScaleEig_rho_' rho_Str '/*.mat']);
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
  save([EnergyData_Folder '/SC_InitialDM1_TargetActivation_ScaleEig_rho_' rho_Str '.mat'], 'Distance', 'Distance_sum', '-append');
end
