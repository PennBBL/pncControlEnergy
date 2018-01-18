
Atlas_Path = '/data/joy/BBL/projects/pncControlEnergy/data/atlas/ROIv_scale125_MNI.nii';
hdr = spm_vol(Atlas_Path);
Atlas_data = spm_read_vols(hdr);
Atlas_data(find(Atlas_data == 234)) = 0;

EnergyFolder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData';
ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/NodalEnergy_SubAvgMaps';

% AllZeros
SC_AllZeros = load([EnergyFolder '/SC_Energy/SC_InitialAll0_TargetFP1DMN1.mat']);
Energy_SubjectsAvg = mean(SC_AllZeros.Energy)';
Energy_SC_AllZeros = Atlas_data;
for i = 1:233
  Energy_SC_AllZeros(find(Energy_SC_AllZeros == i)) = Energy_SubjectsAvg(i); 
end
hdr.fname = [ResultantFolder '/SC_InitialAll0_TargetFP1DMN1.nii'];
spm_write_vol(hdr, Energy_SC_AllZeros);
Energy_YeoAvg_SubjectsAvg = mean(SC_AllZeros.Energy_YeoAvg)';
save([EnergyFolder '/SC_Energy/SC_InitialAll0_TargetFP1DMN1.mat'], 'Energy_SubjectsAvg', 'Energy_YeoAvg_SubjectsAvg', '-append');

% DM 1
SC_DM = load([EnergyFolder '/SC_Energy/SC_InitialDM1_TargetFP1DMN1.mat']);
Energy_SubjectsAvg = mean(SC_DM.Energy)';
Energy_SC_DM = Atlas_data;
for i = 1:233
  Energy_SC_DM(find(Energy_SC_DM == i)) = Energy_SubjectsAvg(i);
end
hdr.fname = [ResultantFolder '/SC_InitialDM1_TargetFP1DMN1.nii'];
spm_write_vol(hdr, Energy_SC_DM);
Energy_YeoAvg_SubjectsAvg = mean(SC_DM.Energy_YeoAvg)';
save([EnergyFolder '/SC_Energy/SC_InitialDM1_TargetFP1DMN1.mat'], 'Energy_SubjectsAvg', 'Energy_YeoAvg_SubjectsAvg', '-append');

% DM 1, FP -1
SC_DM1FPSuppress = load([EnergyFolder '/SC_Energy/SC_InitialDM1FPN1_TargetFP1DMN1.mat']);
Energy_SubjectsAvg = mean(SC_DM1FPSuppress.Energy)';
Energy_SC_DM1FPSuppress = Atlas_data;
for i = 1:233
  Energy_SC_DM1FPSuppress(find(Energy_SC_DM1FPSuppress == i)) = Energy_SubjectsAvg(i);
end
hdr.fname = [ResultantFolder '/SC_InitialDM1FPN1_TargetFP1DMN1.nii'];
spm_write_vol(hdr, Energy_SC_DM1FPSuppress);
Energy_YeoAvg_SubjectsAvg = mean(SC_DM1FPSuppress.Energy_YeoAvg)';
save([EnergyFolder '/SC_Energy/SC_InitialDM1FPN1_TargetFP1DMN1.mat'], 'Energy_SubjectsAvg', 'Energy_YeoAvg_SubjectsAvg', '-append');





