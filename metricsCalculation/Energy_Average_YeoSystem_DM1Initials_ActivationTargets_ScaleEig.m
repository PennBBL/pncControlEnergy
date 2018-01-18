
Energy_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/energyData';
Atlas_Yeo_Index = load('/data/jux/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system_in_Lausanne234.txt');
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end

EnergyMat_Path = [Energy_Folder '/SC_Energy/SC_InitialDM1_TargetActivation_ScaleEig.mat'];
tmp = load(EnergyMat_Path);
for j = 1:8
  Energy_YeoAvg(:, j) = mean(tmp.Energy(:, System_Indices{j}), 2);
end
save(EnergyMat_Path, 'Energy_YeoAvg', '-append');
