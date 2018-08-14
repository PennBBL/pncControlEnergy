
clear

% Total connection strength of the whole brain
% Probabilistic network
ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
Prob_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem'];
Prob_Cell = g_ls([Prob_Folder '/*.mat']);
for i = 1:length(Prob_Cell)
  tmp = load(Prob_Cell{i});
  [~, n, ~] = fileparts(Prob_Cell{i});
  scan_ID(i) = str2num(n(1:4));
  % We scaled the matrix by the maximum eigenvalue and then subtract the identity matrix, which was did when calculating the energy 
  A = tmp.connectivity ./ svds(tmp.connectivity, 1);
  A = A - eye(size(A));
  % Extract upper triangular part and calculate total strength
  A_triu = triu(A);
  WholeBrainStrength_EigNorm_SubIden(i) = sum(sum(A_triu));
end
WholeBrainStrength_EigNorm_SubIden = WholeBrainStrength_EigNorm_SubIden';
save([ReplicationFolder '/data/WholeBrainStrength_Prob_946.mat'], 'WholeBrainStrength_EigNorm_SubIden', 'scan_ID');
