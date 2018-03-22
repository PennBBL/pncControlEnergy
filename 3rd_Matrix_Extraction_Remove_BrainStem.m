
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  1) Removing brain stem from the FA and volume corrected SC matrices                    %%%
%%%  2) Creating a .mat file 'ScanID_MatrixOrder.mat', containing the order of the matrices %%%
%%%  3) Re-ordering the activation data to follow the order of matrices                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
Original_Folder = [ReplicationFolder '/data/matrices'];
Resultant_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem/'];
mkdir(Resultant_Folder);

% Removing the brain stem from the FA matrices
mkdir([Resultant_Folder '/FA']);
Lausanne125_FA_Matrix_Cell = g_ls([Original_Folder '/FA/*.mat']);
for i = 1:length(Lausanne125_FA_Matrix_Cell)
   load(Lausanne125_FA_Matrix_Cell{i});
   connectivity = connectivity(1:233, 1:233);
   [~, FileName, Suffix] = fileparts(Lausanne125_FA_Matrix_Cell{i});
   save([Resultant_Folder '/FA/' FileName Suffix], 'connectivity');

   scanid(i) = str2num(FileName(1:4));
end
% Storing the scan ID order of the matrices
scanid = scanid';
save([ReplicationFolder '/data/ScanID_MatrixOrder.mat'], 'scanid');
% Checking if the order of activation data is same with the order of matrices
Activation_Mat_Path = [ReplicationFolder '/data/Activation_803.mat'];
Activation_Mat = load(Activation_Mat_Path);
scanid - double(Activation_Mat.scanID) % should be all 0, so the activation data and matrix are in the subjects' order

% Removing the brain stem from the volume corrected SC matrices
mkdir([Resultant_Folder '/volNormSC']);
Lausanne125_volNormSC_Matrix_Cell = g_ls([Original_Folder '/volNormSC/*.mat']);
for i = 1:length(Lausanne125_volNormSC_Matrix_Cell)
    load(Lausanne125_volNormSC_Matrix_Cell{i});
    connectivity = volNorm_connectivity(1:233, 1:233);
    [~, FileName, Suffix] = fileparts(Lausanne125_volNormSC_Matrix_Cell{i});
    save([Resultant_Folder '/volNormSC/' FileName Suffix], 'connectivity');
end