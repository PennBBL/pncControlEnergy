
Original_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/matrices/';
Resultant_Folder = '/data/jux/BBL/projects/pncControlEnergy/data/matrices_withoutBrainStem/';

Lausanne125_SC_Matrix_Cell = g_ls([Original_Folder '/Lausanne125/streamlineCount/*.mat']);
for i = 1:length(Lausanne125_SC_Matrix_Cell)
   load(Lausanne125_SC_Matrix_Cell{i});
   connectivity = connectivity(1:233, 1:233);
   [~, FileName, Suffix] = fileparts(Lausanne125_SC_Matrix_Cell{i});
   save([Resultant_Folder '/Lausanne125/SC/' FileName Suffix], 'connectivity');
end


