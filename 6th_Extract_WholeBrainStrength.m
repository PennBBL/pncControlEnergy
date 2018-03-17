
clear
ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
%% FA matrix
% All 949 subjects
FA_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem/FA'];
FA_Cell = g_ls([FA_Folder '/*.mat']);
for i = 1:length(FA_Cell)
  tmp = load(FA_Cell{i});
  [~, n, ~] = fileparts(FA_Cell{i});
  scan_ID(i) = str2num(n(1:4));
  A = tmp.connectivity / svds(tmp.connectivity, 1);
  A = A - eye(size(A));
  A_triu = triu(A);
  Strength_EigNorm_SubIden(i) = sum(sum(A_triu));
end
Strength_EigNorm_SubIden = Strength_EigNorm_SubIden';
mkdir([ReplicationFolder '/data/WholeBrainStrength']);
save([ReplicationFolder '/data/WholeBrainStrength/Strength_FA_949.mat'], 'Strength_EigNorm_SubIden', 'scan_ID');
% 677 subjects whole have intace activation
clear Strength_EigNorm_SubIden;
clear scan_ID;
Strength_Data_949 = load([ReplicationFolder '/data/WholeBrainStrength/Strength_FA_949.mat']);
Energy_Mat = [ReplicationFolder '/data/energyData/FA_Energy/FA_InitialAll0_TargetIndividualActivationZScore.mat'];
Energy_Data = load(Energy_Mat);
for i = 1:length(Energy_Data.scan_ID)
  Index = find(Strength_Data_949.scan_ID == Energy_Data.scan_ID(i));
  scan_ID(i) = Energy_Data.scan_ID(i);
  Strength_EigNorm_SubIden(i) = Strength_Data_949.Strength_EigNorm_SubIden(Index);
end
Strength_EigNorm_SubIden = Strength_EigNorm_SubIden';
save([ReplicationFolder '/data/WholeBrainStrength/Strength_FA_677.mat'], 'scan_ID', 'Strength_EigNorm_SubIden');


%% volNormSC matrix
% All 949 subjects
clear Strength_EigNorm_SubIden;
clear scan_ID;
volNormSC_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem/volNormSC'];
volNormSC_Cell = g_ls([volNormSC_Folder '/*.mat']);
for i = 1:length(volNormSC_Cell)
  tmp = load(volNormSC_Cell{i});
  [~, n, ~] = fileparts(volNormSC_Cell{i});
  scan_ID(i) = str2num(n(1:4));
  A = tmp.connectivity / svds(tmp.connectivity, 1);
  A = A - eye(size(A));
  A_triu = triu(A);
  Strength_EigNorm_SubIden(i) = sum(sum(A_triu));
end
Strength_EigNorm_SubIden = Strength_EigNorm_SubIden';
save([ReplicationFolder '/data/WholeBrainStrength/Strength_volNormSC_949.mat'], 'Strength_EigNorm_SubIden', 'scan_ID');
% 677 subjects whole have intace activation
clear Strength_EigNorm_SubIden;
clear scan_ID;
Strength_Data_949 = load([ReplicationFolder '/data/WholeBrainStrength/Strength_volNormSC_949.mat']);
Energy_Mat = [ReplicationFolder '/data/energyData/volNormSC_Energy/volNormSC_InitialAll0_TargetIndividualActivationZScore.mat'];
Energy_Data = load(Energy_Mat);
for i = 1:length(Energy_Data.scan_ID)
  Index = find(Strength_Data_949.scan_ID == Energy_Data.scan_ID(i));
  scan_ID(i) = Energy_Data.scan_ID(i);
  Strength_EigNorm_SubIden(i) = Strength_Data_949.Strength_EigNorm_SubIden(Index);
end
Strength_EigNorm_SubIden = Strength_EigNorm_SubIden';
save([ReplicationFolder '/data/WholeBrainStrength/Strength_volNormSC_677.mat'], 'scan_ID', 'Strength_EigNorm_SubIden');
