
Energy_Folder = '/data/joy/BBL/projects/pncControlEnergy/data/energyData';
Atlas_Yeo_Index = load('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system_in_Lausanne234.txt');
Atlas_Yeo_Index = Atlas_Yeo_Index(1:233);
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end

EnergyMat_Cell = g_ls([Energy_Folder '/*/*.mat']);
for i = 1:length(EnergyMat_Cell)
  tmp = load(EnergyMat_Cell{i});
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(tmp.Energy(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Cell{i}, 'Energy_YeoAvg', '-append');
end
