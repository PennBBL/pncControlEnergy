
clear
ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
FA_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem'];
FA_Cell = g_ls([FA_Folder '/*.mat']);
for i = 1:length(FA_Cell)
  tmp = load(FA_Cell{i});
  [~, n, ~] = fileparts(FA_Cell{i});
  scan_ID(i) = str2num(n(1:4));
  % We scaled the matrix by the maximum eigenvalue and then subtract the identity matrix, which was did when calculating the energy 
  A = tmp.connectivity ./ svds(tmp.connectivity, 1);
  A = A - eye(size(A));
  % Extract upper triangular part and calculate total strength
  A_triu = triu(A);
  WholeBrainStrength_EigNorm_SubIden(i) = sum(sum(A_triu));
end
WholeBrainStrength_EigNorm_SubIden = WholeBrainStrength_EigNorm_SubIden';
save([ReplicationFolder '/data/WholeBrainStrength_FA_949.mat'], 'WholeBrainStrength_EigNorm_SubIden', 'scan_ID');

