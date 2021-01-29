#!/bin/bash

##############################################

# usage: do t-tests on single subject GLMs

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

cd ..
mainDir=$(pwd)
dataDir=$mainDir/data

# get list of subject IDs that should be included in the group maps
# note: if a subject id in this list doesn't have a glm file (output of glm_mid.py), 
# then this script will error. 
subjects=$(cat ${mainDir}/subjects.txt)
echo -e "here's the list of subjects to be included in group maps:\n $subjects"

# to do: print out the number of subjects (nice for the experimenter to see)

# all single-subject glm results should be here
resultsDir=$dataDir/results_mid

# mask file - voxels outside the brain mask will be set to 0
maskfile=$mainDir/templates/brainmask_func.nii

# labels of sub-bricks to test
labels=('Full_R^2' 'ant#0_Coef' 'gvnant#0_Coef' 'lvnant#0_Coef' 'out#0_Coef' 'gvnout#0_Coef' 'nvlout#0_Coef')

# names for saving out files; should correspond to input labels
outlabels=('ZR2' 'Zant' 'Zgvnant' 'Zlvnant' 'Zout' 'Zgvnout' 'Znvlout')

# suffix to add to outfiles; e.g., to denote something about the test version 
outsuffix=''

##########################################################################################


cd $resultsDir

for i in ${!labels[@]};
do 

	label=${labels[$i]}; # this func run 
	outlabel=${outlabels[$i]}; # string for anatomy file corresponding to func run

	echo label: $label
	echo outlabel: $outlabel

	echo -e "\n\nWORKING ON $label\n"

	# get volume index
	# note: THIS ASSUMES ITS THE SAME VOL INDEX FOR ALL SUBJECTS - MAKE SURE THIS ASSUMPTION IS TRUE!!
	volnum=$(3dinfo -label2index ${label} zl150930_glm+tlrc.)

	# define what the group map file should be called for this particular stat
	outname=$outlabel$outsuffix
	
	# construct 3dttest command
	cmd="3dttest++ -prefix ${outname} -mask ${maskfile} -toz -setA "
	for subj in ${subjects};
	do
		subjid=$(echo $subj | tr -d '\r')
		#echo ${subjid}
		subjline="${subjid}_glm+tlrc.[${volnum}] "
		#echo ${subjline}
		cmd=${cmd}${subjline}
	done

	# add -Clustsim to this command to determine correction for multiple comparisons 
	# note: the clustsim option takes a long time, so use only when necessary

	echo $cmd	# print it out in terminal 
	eval $cmd	# execute the command

	echo -e "\ndone with ttest file: $outname\n"

done # labels


