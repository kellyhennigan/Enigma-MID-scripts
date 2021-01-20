#!/bin/bash

##############################################

# usage: do t-tests on single subject GLMs

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories
cd ..
mainDir=$(pwd)
dataDir=$mainDir/data

resultsDir=$dataDir/results_mid

# mask file
maskfile=$dataDir/templates/bmask_func.nii.gz

#subjects='p500010 p500020 p500030 p500040 p500050 p500060 p500070'

# labels of sub-bricks to test
labels=('Full_R^2' 'ant#0_Coef' 'gvnant#0_Coef' 'lvnant#0_Coef' 'out#0_Coef' 'gvnout#0_Coef' 'nvlout#0_Coef')

outlabels=('ZR2' 'Zant' 'Zgvnant' 'Zlvnant' 'Zout' 'Zgvnout' 'Znvlout')


# suffix to add to outfiles to denote something about the test version? 
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

	# get volume index; THIS ASSUMES ITS THE SAME VOL INDEX FOR ALL SUBJECTS
	volnum=$(3dinfo -label2index ${label} p500010_glm+tlrc.)

	########### t-test command
	outname=$outlabel$outsuffix
	cmd="3dttest++ -prefix ${outname} -mask ${maskfile} -toz -setA 
		'p500010_glm+tlrc.[${volnum}]'
		'p500020_glm+tlrc.[${volnum}]'
		'p500030_glm+tlrc.[${volnum}]'
		'p500040_glm+tlrc.[${volnum}]'
		'p500060_glm+tlrc.[${volnum}]'
		'p500070_glm+tlrc.[${volnum}]' "

		# add -Clustsim to this command to determine correction for multiple comparisons 

	echo $cmd	# print it out in terminal 
	eval $cmd	# execute the command

	echo -e "\ndone with ttest file: $outname\n"

done # labels


