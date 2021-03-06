#!/bin/bash

##############################################

# usage: coregister subject's t1 and functional data to group space.

# written by Kelly MacNiven, Nov 12, 2019

# assumes raw data are stored within the following directory structure:

	# mainDir/data/subjid/raw

# assumes raw files are called: 
	# t1_raw.nii.gz 				# subject's raw t1-weighted volume
	# mid1.nii.gz & mid2.nii.gz 	# subject's raw fMRI data from 2 MID runs

# Processed data will be saved out to: 
	
	# mainDir/data/subjid/func_proc

# output files are: 

	# t1_ns.nii.gz - subject's skullstripped anatomical data in native space
	# t1_tlrc.nii.gz - subject's anatomical data in tlrc space
	# vol1_mid_ns.nii.gz - 1st volume of 1st MID run, skull-stripped
	# vol1_mid_ns_al.nii.gz - " ", aligned to t1 in native space (can be useful for checking anat-func coreg)
	# vol1_mid_tlrc.nii.gz - " ", aligned in tlrc space
	# xfs - subdirectory within func_proc folder that contains coregistration transforms

###########################################

###### IMPORTANT: VISUALLY CHECK CO-REGISTRATION BEFORE MOVING ON!! 

# once this script finishes for a subject, check to make sure the subject's
# functional data looks good in group space. To do this, temporarily copy the file
# TT_N27.nii into the subject's func_proc directory. Then in the afni viewer, load:
# 	- TT_N27.nii as underlay & t1_tlrc.nii.gz as overlay, then
#   - t1_tlrc.nii.gz as underlay & mid_vol1_tlrc.nii.gz as overlay

# If these don't look good, it's likely because the alignment between 
# a subject's anatomy & functional data messed up. You'll have to 
# "nudge" the subject's anatomical data to make it closer in space 
# to the functional data, save out the "nudged" anatomical volume, and 
# re-run this script using the nudged anatomy instead of the raw anatomy. 

# to do that: 
# open afni from subject's raw dir, 
# > plugins> NUDGE
# > nudge t1 file to match raw functional data (you can use the file, "mid_vol1.nii.gz" in the subject's raw dir )
# > say "print" to print out nudge command and apply it to t1 data, eg: 
# 3drotate -quintic -clipit -rotate 0.00I 0.00R 0.00A -ashift 0.00S 0.00L 0.00P -prefix t1w_nudge.nii.gz raw_t1w.nii.gz
# then, delete all files previously created by this script for the subject, 
# and re-run the script using the nudged anatomical nii for the "rawt1files" variable


########################## DEFINE VARIABLES #############################



# define main directory (this should )
#mainDir=path/to/maindirectory
cd ..
mainDir=$(pwd)
dataDir=$mainDir/data


# anatomical template in tlrc space
t1_template=$mainDir/templates/TT_N27.nii # %s is data_dir


# subject ids to process (assumes directory structure is dataDir/subjid)
# subjects=('subj001 subj002 subj003')
msg='enter subject ID(s) e.g., ab180123 va190114:' 
echo $msg
read subjects
echo you entered: $subjects



############################# RUN IT ###################################


for subject in $subjects
do
	
	echo WORKING ON SUBJECT $subject

	# subject input & output directories
	inDir=$dataDir/$subject/raw
	outDir=$dataDir/$subject/func_proc


	# make outDir if it doesn't exist & cd to it: 
	if [ ! -d "$outDir" ]; then
		mkdir $outDir
	fi 	
	cd $outDir


	# also make a "xfs" directory within outDir to house all xform files
	if [ ! -d xfs ]; then
		mkdir xfs
	fi 	


	# remove skull from t1 anatomical data
	3dSkullStrip -prefix t1_ns.nii.gz -input $inDir/t1_raw.nii.gz


	# estimate transform to put t1 in tlrc space
	@auto_tlrc -no_ss -base $t1_template -suffix _tlrc -input t1_ns.nii.gz


	# clean files
	gzip t1_ns_tlrc.nii; 
	mv t1_ns_tlrc.nii.gz t1_tlrc.nii.gz; 
	mv t1_ns_tlrc.Xat.1D xfs/t12tlrc_xform; 
	mv t1_ns_tlrc.nii_WarpDrive.log xfs/t12tlrc_xform.log; 
	rm t1_ns_tlrc.nii.Xaff12.1D


	# take first volume of raw functional data:
	3dTcat -output $inDir/vol1_mid.nii.gz $inDir/mid1.nii.gz[0]

	
	# skull-strip functional vol
	3dSkullStrip -prefix vol1_mid_ns.nii.gz -input $inDir/vol1_mid.nii.gz


	# estimate xform between anatomy and functional data
	align_epi_anat.py -epi2anat -epi vol1_mid_ns.nii.gz -anat t1_ns.nii.gz -epi_base 0 -tlrc_apar t1_tlrc.nii.gz -epi_strip None -anat_has_skull no

	
	# put in nifti format 
	3dAFNItoNIFTI -prefix vol1_mid_tlrc.nii.gz vol1_mid_ns_tlrc_al+tlrc
	3dAFNItoNIFTI -prefix vol1_mid_ns_al.nii.gz vol1_mid_ns_al+orig

	# clean files
	rm vol1_mid_ns_tlrc_al+tlrc*
	rm vol1_mid_ns_al+orig*
	mv t1_ns_al_mat.aff12.1D xfs/t12mid_xform; 
	mv vol1_mid_ns_al_mat.aff12.1D xfs/mid2t1_xform; 
	mv vol1_mid_ns_al_tlrc_mat.aff12.1D xfs/mid2tlrc_xform; 
	rm vol1_mid_ns_al_reg_mat.aff12.1D; 
	rm t1_ns_tlrc.maskwarp.Xat.1D;
	


done # subject loop


