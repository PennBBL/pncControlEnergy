
clear
ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
%% FA matrix
FA_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem/FA'];
FA_Cell = g_ls([FA_Folder '/*.mat']);
for i = 1:length(FA_Cell)
  tmp = load(FA_Cell{i});
  [~, n, ~] = fileparts(FA_Cell{i});
  scan_ID(i) = str2num(n(1:4));
  % We scaled the matrix by the maximum eigenvalue and then subtract the identity matrix, which was did when calculating the energy 
  A = tmp.connectivity / svds(tmp.connectivity, 1);
  A = A - eye(size(A));
  % Extract upper triangular part 
  A_triu = triu(A);
  Strength_EigNorm_SubIden(i) = sum(sum(A_triu));
end
Strength_EigNorm_SubIden = Strength_EigNorm_SubIden';
mkdir([ReplicationFolder '/data/WholeBrainStrength']);
save([ReplicationFolder '/data/WholeBrainStrength/Strength_FA_803.mat'], 'Strength_EigNorm_SubIden', 'scan_ID');

%% volNormSC matrix
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
save([ReplicationFolder '/data/WholeBrainStrength/Strength_volNormSC_803.mat'], 'Strength_EigNorm_SubIden', 'scan_ID');
