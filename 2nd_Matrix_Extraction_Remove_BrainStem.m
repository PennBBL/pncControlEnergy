
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  1) Copying FA matrices and Removing brain stem  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
SubjectsIDs = csvread([ReplicationFolder '/data/pncControlEnergy_n949_SubjectsIDs.csv'], 1);
scanID = SubjectsIDs(:, 2);

Original_Folder = '/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/deterministic_dec2016';
Resultant_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem/'];
mkdir(Resultant_Folder);

% Copying and Removing the brain stem from the FA matrices
for i = 1:length(scanID)
   i
   tmp_path = [Original_Folder '/FA/LausanneScale125/' num2str(scanID(i)) '_FA_LausanneScale125.mat'];
   load(tmp_path);
   connectivity = connectivity(1:233, 1:233);
   save([Resultant_Folder '/' num2str(scanID(i)) '_FA_LausanneScale125.mat'], 'connectivity');
end

