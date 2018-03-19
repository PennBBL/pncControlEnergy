
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Removing brain stem from the FA and volume corrected SC matrices                           %%%
%%%  Also, creating a .mat file 'ScanID_MatrixOrder.mat', containing the order of the matrices  %%%
%%%  Then, when extracting behavior or activation data, they should be consistent with this     %%%
%%%        order for facilitate the statistical analysis.                                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Original_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/matrices';
Resultant_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/matrices_withoutBrainStem/';
mkdir(Resultant_Folder);

mkdir([Resultant_Folder '/FA']);
Lausanne125_FA_Matrix_Cell = g_ls([Original_Folder '/FA/*.mat']);
for i = 1:length(Lausanne125_FA_Matrix_Cell)
   load(Lausanne125_FA_Matrix_Cell{i});
   connectivity = connectivity(1:233, 1:233);
   [~, FileName, Suffix] = fileparts(Lausanne125_FA_Matrix_Cell{i});
   save([Resultant_Folder '/FA/' FileName Suffix], 'connectivity');

   scanid(i) = str2num(FileName(1:4));
end
scanid = scanid';
save('/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/ScanID_MatrixOrder.mat', 'scanid');

mkdir([Resultant_Folder '/volNormSC']);
Lausanne125_volNormSC_Matrix_Cell = g_ls([Original_Folder '/volNormSC/*.mat']);
for i = 1:length(Lausanne125_volNormSC_Matrix_Cell)
    load(Lausanne125_volNormSC_Matrix_Cell{i});
    connectivity = volNorm_connectivity(1:233, 1:233);
    [~, FileName, Suffix] = fileparts(Lausanne125_volNormSC_Matrix_Cell{i});
    save([Resultant_Folder '/volNormSC/' FileName Suffix], 'connectivity');
end
