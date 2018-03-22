#!/bin/sh

#####################################################################################################
### Copy FA and volume corrected SC matrices according to IDs created by 1_compile_subject_data.R ### 
#####################################################################################################

## Define subject list
scanid_list=$(cut -d',' -f2 < /data/jux/BBL/projects/pncControlEnergy/results/Replication/data/pncControlEnergy_n803_subjectIDs.csv) 

FA_outdir=/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/matrices/FA
mkdir -p ${FA_outdir}

volNorm_outdir=/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/matrices/volNormSC
mkdir -p ${volNorm_outdir}

for name in ${scanid_list}; do
	scanid=$name
	echo $scanid
	
	FA_path=/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/deterministic_dec2016/FA/LausanneScale125/"${scanid}"_FA_LausanneScale125.mat

	volNorm_path=/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/deterministic_dec2016/volNormStreamline/LausanneScale125/"${scanid}"_volNormStreamline_LausanneScale125.mat

	cp ${FA_path} ${FA_outdir}
	cp ${volNorm_path} ${volNorm_outdir}
done

