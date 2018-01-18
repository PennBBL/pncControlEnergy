
clear

EnergyData_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData/SC_Energy';
Energy_Cell = g_ls([EnergyData_Folder '/InitialDM1_TargetFP1DMN1/*.mat']);
Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/data';
Yeo_Index = load([Data_Folder '/atlas/Yeo_7system_in_Lausanne234.txt']);
Yeo_Index = Yeo_Index(1:233);
Yeo_Index(find(Yeo_Index ~= 6 & Yeo_Index ~= 7)) = 0;
% Target: FP=1, DM: -1
xf = Yeo_Index;
xf(find(xf == 6)) = 1;
xf(find(xf == 7)) = -1;
for i = 1:length(Energy_Cell)
  i
  tmp = load(Energy_Cell{i});
  X_Opt_Trajectory = tmp.X_Opt_Trajectory;
  Square_Sum = sum((repmat(xf(find(xf))', 1001, 1) - X_Opt_Trajectory).^2, 2);
  Norm_Distance = sqrt(Square_Sum);
  Distance(i, :) = Norm_Distance';
  Distance_sum(i) = sum(Norm_Distance);
end
save([EnergyData_Folder '/SC_InitialDM1_TargetFP1DMN1.mat'], 'Distance', 'Distance_sum', '-append');
