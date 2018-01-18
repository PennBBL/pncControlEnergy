
clear
Data_Folder = '/Users/zaixucui/Documents/Projects/pncControlEnergy/data/energyData/SC_Energy';

Mat_Cell = g_ls([Data_Folder '/InitialDM1_TargetFP1DMN1/*.mat']);
for i = 1:length(Mat_Cell)
    i
    tmp = load(Mat_Cell{i});
    Energy_AcrossTime(i, :) = sum(tmp.U_Opt_Trajectory.^2, 2)';
end
save([Data_Folder '/SC_InitialDM1_TargetFP1DMN1.mat'], 'Energy_AcrossTime', '-append');

Mat_Cell = g_ls([Data_Folder '/InitialDM1_TargetActivation/*.mat']);
for i = 1:length(Mat_Cell)
    i
    tmp = load(Mat_Cell{i});
    Energy_AcrossTime(i, :) = sum(tmp.U_Opt_Trajectory.^2, 2)';
end
save([Data_Folder '/SC_InitialDM1_TargetActivation.mat'], 'Energy_AcrossTime', '-append');

clear Energy_AcrossTime;
Mat_Cell = g_ls([Data_Folder '/InitialDM1_TargetIndividualActivation/*.mat']);
for i = 1:length(Mat_Cell)
    i
    tmp = load(Mat_Cell{i});
    Energy_AcrossTime(i, :) = sum(tmp.U_Opt_Trajectory.^2, 2)';
end
save([Data_Folder '/SC_InitialDM1_TargetIndividualActivation.mat'], 'Energy_AcrossTime', '-append');
