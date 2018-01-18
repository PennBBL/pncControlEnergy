
Atlas_Path = '/data/joy/BBL/projects/pncControlEnergy/data/atlas/ROIv_scale125_MNI.nii';
hdr = spm_vol(Atlas_Path);
Atlas_data = spm_read_vols(hdr);
Atlas_data(find(Atlas_data == 234)) = 0;

% First, save activation as NIFTI file
ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/Activation_SubAvg';
Activation_Mat = load('/data/joy/BBL/projects/pncControlEnergy/data/subjectData/nback_2b0b_20170427.mat');
Include_Index = find(Activation_Mat.nbackExclude == 0 & Activation_Mat.nbackZerobackExclude == 0 & ~isnan(sum(Activation_Mat.Activation_2b0b, 2)));
Activation_Avg = mean(Activation_Mat.Activation_2b0b(Include_Index, :));
Activation_AvgMap = Atlas_data;
for i = 1:233
  Activation_AvgMap(find(Activation_AvgMap == i)) = Activation_Avg(i);
end
hdr.fname = [ResultantFolder '/Activation_Avg.nii'];
hdr.dt = [16 0];
spm_write_vol(hdr, Activation_AvgMap);

% Energy map (Initial: DM 1; Target: Activation)
EnergyFolder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData';
ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';
SC_InitialDM1_TargetActivation = load([EnergyFolder '/SC_Energy/SC_InitialDM1_TargetActivation.mat']);
Energy_SubjectsAvg = mean(SC_InitialDM1_TargetActivation.Energy)';
Energy_SC_InitialDM1_TargetActivation = Atlas_data;
for i = 1:233
  Energy_SC_InitialDM1_TargetActivation(find(Energy_SC_InitialDM1_TargetActivation == i)) = Energy_SubjectsAvg(i);
end
hdr.fname = [ResultantFolder '/SC_InitialDM1_TargetActivation.nii'];
hdr.dt = [16 0];
spm_write_vol(hdr, Energy_SC_InitialDM1_TargetActivation);
Energy_YeoAvg_SubjectsAvg = mean(SC_InitialDM1_TargetActivation.Energy_YeoAvg)';
save([EnergyFolder '/SC_Energy/SC_InitialDM1_TargetActivation.mat'], 'Energy_SubjectsAvg', 'Energy_YeoAvg_SubjectsAvg', '-append');

