
Data_Folder = '/Users/zaixucui/Documents/Projects/pncControlEnergy/data/energyData/SC_Energy/';

Energy_Mat = load([Data_Folder '/SC_InitialDM1_TargetActivation.mat']);
Distance_AcrossTime = Energy_Mat.Distance;
Energy_AcrossTime = Energy_Mat.Energy_AcrossTime;

figure;
for i = 1:949
    plot(Distance_AcrossTime(i, :), '.')
    hold on;
end
title('Distance, Target: mean activation');
figure;
for i = 1:949
    plot(Energy_AcrossTime(i, :), '.');
    hold on;
end
title('Energy, Target: mean activation');

Energy_Mat = load([Data_Folder '/SC_InitialDM1_TargetFP1DMN1.mat']);
Distance_AcrossTime = Energy_Mat.Distance;
Energy_AcrossTime = Energy_Mat.Energy_AcrossTime;
figure;
for i = 1:949
    plot(Distance_AcrossTime(i, :), '.')
    hold on;
end
title('Distance, Target: FP 1, DM -1');
figure;
for i = 1:949
    plot(Energy_AcrossTime(i, :), '.');
    hold on;
end
title('Energy, Target: FP 1, DM -1');

Energy_Mat = load([Data_Folder '/SC_InitialDM1_TargetIndividualActivation.mat']);
Distance_ArossTime = Energy_Mat.Distance;
Energy_AcrossTime = Energy_Mat.Energy_AcrossTime;
figure;
for i = 1:677
    plot(Distance_AcrossTime(i, :), '.')
    hold on;
end
title('Distance, Target: individual activation');
figure;
for i = 1:677
    plot(Energy_AcrossTime(i, :), '.');
    hold on;
end
title('Energy, Target: individual activation');
