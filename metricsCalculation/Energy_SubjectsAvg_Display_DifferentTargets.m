
Atlas_Path = '/data/joy/BBL/projects/pncControlEnergy/data/atlas/ROIv_scale125_MNI.nii';
hdr = spm_vol(Atlas_Path);
Atlas_data = spm_read_vols(hdr);
Atlas_data(find(Atlas_data == 234)) = 0;

EnergyFolder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData';
ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

% Initial: AllZeros; Target: DM 1
SC_TargetDM1 = load([EnergyFolder '/SC_Energy/SC_InitialAll0_TargetDM1.mat']);
Energy_SubjectsAvg = mean(SC_TargetDM1.Energy)';
Energy_SC_TargetDM1 = Atlas_data;
for i = 1:233
  Energy_SC_TargetDM1(find(Energy_SC_TargetDM1 == i)) = Energy_SubjectsAvg(i); 
end
hdr.fname = [ResultantFolder '/SC_InitialAll0_TargetDM1.nii'];
spm_write_vol(hdr, Energy_SC_TargetDM1);
Energy_YeoAvg_SubjectsAvg = mean(SC_TargetDM1.Energy_YeoAvg)';
save([EnergyFolder '/SC_Energy/SC_InitialAll0_TargetDM1.mat'], 'Energy_SubjectsAvg', 'Energy_YeoAvg_SubjectsAvg', '-append');

% Initial: AllZeros; Target: FP 1
SC_TargetFP1 = load([EnergyFolder '/SC_Energy/SC_InitialAll0_TargetFP1.mat']);
Energy_SubjectsAvg = mean(SC_TargetFP1.Energy)';
Energy_SC_TargetFP1 = Atlas_data;
for i = 1:233
  Energy_SC_TargetFP1(find(Energy_SC_TargetFP1 == i)) = Energy_SubjectsAvg(i);
end
hdr.fname = [ResultantFolder '/SC_InitialAll0_TargetFP1.nii'];
spm_write_vol(hdr, Energy_SC_TargetFP1);
Energy_YeoAvg_SubjectsAvg = mean(SC_TargetFP1.Energy_YeoAvg)';
save([EnergyFolder '/SC_Energy/SC_InitialAll0_TargetFP1.mat'], 'Energy_SubjectsAvg', 'Energy_YeoAvg_SubjectsAvg', '-append');

