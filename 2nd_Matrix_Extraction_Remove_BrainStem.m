
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  1) Copying SC matrices and Removing brain stem  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication_Prob';
SubjectsIDs = csvread([ReplicationFolder '/data/pncControlEnergy_n946_SubjectsIDs.csv'], 1);
scanID = SubjectsIDs(:, 2);

% Probabilisitc network
% The main results of the paper were based on probabilistic network
Original_Folder = '/data/jux/BBL/projects/pncBaumDti/probtrackx_2017/Motion_Paper';
Resultant_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem_Prob/'];
mkdir(Resultant_Folder);
%
% Copying and Removing the brain stem from the probabilistic matrices
%
% Note: the 192th region was isolated for 15 subjects in the sample of 946 subjects, remove this region for all subjects
%
for i = 1:length(scanID)
   i
   tmp_path_Cell = g_ls([Original_Folder '/*/*' num2str(scanID(i)) '/wmEdge_p1000_pialTerm/output/*.mat']);
   load(tmp_path_Cell{1});
   connectivity = A_prop_und([1:191 193:end], [1:191 193:end]); % Remove the 192th region
   save([Resultant_Folder '/' num2str(scanID(i)) '_Prob_LausanneScale125.mat'], 'connectivity');
end

% FA network, which was used as validation
Original_Folder = '/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/deterministic_dec2016';
Resultant_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem_FA/'];
mkdir(Resultant_Folder);
for i = 1:length(scanID)
    i
    tmp_path = [Original_Folder '/FA/LausanneScale125/' num2str(scanID(i)) '_FA_LausanneScale125.mat'];
    load(tmp_path);
    connectivity = connectivity([1:191 193:233], [1:191 193:233]); % Remove the 192th region and brain stem
    save([Resultant_Folder '/' num2str(scanID(i)) '_FA_LausanneScale125.mat'], 'connectivity');
end

