
clear

% Shuffle all edges, only preserving the degree distribution 
Original_Nework_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/matrices_withoutBrainStem';
Null_Network_Folder = [Original_Nework_Folder '_NullNetworks_PreservingDegree'];

mkdir(Null_Network_Folder);
Matrix_Cell = g_ls([Original_Nework_Folder '/*.mat']);
N = 233;
for k = 1:100
  k
  ResultantFolder_K = [Null_Network_Folder '/NullNetwork_' num2str(k, '%03d')];
  mkdir(ResultantFolder_K);
  for i = 1:length(Matrix_Cell)
    tmp = load(Matrix_Cell{i});
    [u, v, w] = find(triu(tmp.connectivity, 1));
    index = (v - 1) * N + u;
    m = length(index);
    connectivity = zeros(N);
    connectivity(index) = w(randperm(m));
    connectivity = connectivity + connectivity';
    [~, FileName, ~] = fileparts(Matrix_Cell{i});
    save([ResultantFolder_K '/' FileName '.mat'], 'connectivity');
  end
end
