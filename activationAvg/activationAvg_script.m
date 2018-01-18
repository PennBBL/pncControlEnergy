
Activation_Mat = load('/data/jux/BBL/projects/pncControlEnergy/data/subjectData/nback_2b0b_20170427.mat');
Include_Index = find(Activation_Mat.nbackExclude == 0 & Activation_Mat.nbackZerobackExclude == 0 & ~isnan(sum(Activation_Mat.Activation_2b0b, 2)));
Activation_2b0b = Activation_Mat.Activation_2b0b(Include_Index, :);
Scan_ID_SC = Activation_Mat.Scan_ID_SC(Include_Index, :);
Activation_Avg = mean(Activation_Mat.Activation_2b0b(Include_Index, :));
ResultantFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Activation';

Activation_OneSampleSig = ttest(Activation_2b0b);
Activation_OneSampleSig_Index = find(Activation_OneSampleSig);
Activation_OneSampleSig_Avg = zeros(size(Activation_Avg));
Activation_OneSampleSig_Avg(Activation_OneSampleSig_Index) = Activation_Avg(Activation_OneSampleSig_Index);
save([ResultantFolder '/Activation.mat'], 'Scan_ID_SC', 'Activation_2b0b', 'Activation_Avg', 'Include_Index', 'Activation_OneSampleSig_Index', 'Activation_OneSampleSig_Avg');
