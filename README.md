# MID processing pipeline 

This repository has code for pre-processing and analyzing functional mri (fmri) data during the Monetary Incentive Delay (MID) task. The dataset has data from 42 control subjects. Each subject performed the MID task over 2 scan runs with the following info: 

- 6 conditions (0,1,5 gain/loss trials)
- 15 trials per condition, so 90 trials total
- trial timing: 
	* 0-2 s: cue presentation (+/- $0, $1, or $5 cue)
	* 4.25-5 s: target window (i.e., target will appear sometime within this interval)
	* 6-8 s: outcome presentation 
	* intertrial interval (ITI) of either 2, 4 or 6 s, averaging 4 s across all trials


## Getting started


### Software requirements 

* [Python 2.7](https://www.python.org/)
* [AFNI version 18.0.XX](https://afni.nimh.nih.gov/)  (NOTE: the version is important, because more recent versions of AFNI apparently don't have the 3dFourier command used in this pipeline)
* [Matlab](https://www.mathworks.com/products/matlab.html) (currently used for saving & plotting VOI timecourses)



### Permissions

make sure the user has permission to execute scripts. From a terminal command line, cd to the directory containing these scripts. Then type:
```
chmod 777 *sh
chmod 777 *py
```
to be able to execute them. This only needs to be run once. 


## fMRI pipeline

- [Check raw data](#check-raw-data)
- [Estimate transforms from subject's native to standard space](#estimate-transforms-from-subject's-native-to-standard-space)
- [Quality Assurance (QA) check the coregistation](#QA-coreg)
- [Pre-process fmri data](#pre-process-fmri-data)
- [QA check head motion](#QA-motion)
- [Get stimulus onset times and make regressors](#get-stimulus-onset-times-and-make-regressors)
- [Subject-level GLMs](#subject-level-glms)
- [Generate VOI timecourses](#generate-voi-timecourses)
- [Group level brain maps](#group-level-brain-maps)


### Check raw data 
Raw fMRI and anatomical data should be here, relative to your main project directory: 
* data/[subjid]/raw/mid1.nii.gz 		# 1st MID scan
* data/[subjid]/raw/mid2.nii.gz 		# 2nd MID scan
* data/[subjid]/raw/t1_raw.nii.gz 		# t1-weighted anatomical volume

Within the directory containing the raw MRI data, try running this afni command: 
```
3dinfo mid1.nii.gz
```
Use that command to confirm that the mid1 nifti file contains 262 volumes and that mid2 contains 298 volumes. 


Behavioral data should be here: 
* data/[subjid]/behavior/mid_matrix_wEnd.csv 	# stim timing file

There should be 549 rows, inclusive of the header row. Because we use a "TR-locked" design, meaning that our trial timing is locked to the timing of fmri data acquisition, each row in the stim file will correspond to a volume of fmri data after we omit the first 6 volumes from each scan and concatenate the scans together (i.e., there will be 548 volumes of pre-processed fmri data). 



### Estimate transforms from subject's native to standard space
from a terminal command line, cd to your scripts directory and run: 
```
./preprocess_mid1.sh
```
this script does the following using AFNI commands:
* skull strips t1 data using afni command "3dSkullStrip"
* aligns skull-stripped t1 data to t1 template in tlrc space using afni command @auto_tlrc, which allows for a 12 parameter affine transform
* pulls out the first volume of functional data to be co-registered to anatomy and skullstrips this volume using "3dSkullStrip"
* coregisters anatomy to functional data, and then calculates the transform from native functional space to standard group space (tlrc space)

#### output 
this should create the directory, **data/[subjid]/func_proc**, which should contain: 		
* t1_ns.nii.gz 				# subject's t1 with no skull in native space
* t1_tlrc.nii.gz			# " " in standard (tlrc) space
* vol1_mid_ns.nii.gz 		# 1st vol of fmri data with no skull in native space
* vol1_mid_ns_al.nii.gz		# " " aligned to t1 in native space
* vol1_mid_tlrc.nii.gz		# " " in standard (tlrc) space
* xfs 						# sub-directory containing all coregistration transforms



### Quality Assurance (QA) check the coregistation 
Visually check to make sure the coregistration looks alright. In afni viewer, load subject's anatomy and functional volume in tlrc space (files "t1_tlrc.nii.gz" and "vol1_mid_tlrc.nii.gz"). These should be reasonably aligned. If they aren't, that means 1) the anatomical <-> functional alignment in native space messed up (most likely), 2) the subject's anatomical <-> tlrc template alignment messed up, or 3) both messed up. 

Here's an example of decent coregistration: 
<p align="center">
  <img width="161" height="151" src="https://github.com/kellyhennigan/fmrieat/blob/master/coreg_examples/decent_coreg_y.jpg">
</p>

And here's an example of bad coregistration (where something went terribly wrong!)
<p align="center">
  <img width="161" height="151" src="https://github.com/kellyhennigan/fmrieat/blob/master/coreg_examples/bad_coreg_y.jpg">
</p>

**To correct bad coregistration:**

- if the problem appears to be bad alignment between a subject's anatomical and functional data (to check this, load files "t1_ns.nii.gz" and "vol1_mid_ns_al.nii.gz" in afni viewer), you may need to first manually "nudge" the subject's raw t1-weighted volume to be in better alignment with their functional data. To do that: 
* open afni in subject's raw directory, 
* > plugins> NUDGE
* > nudge t1 file to match functional volume 1 of mid1.nii.gz
* > say "print" to print out the nudge command and then apply it to t1 data, eg: 
```
3drotate -quintic -clipit -rotate 0.00I 0.00R 0.00A -ashift 0.00S 0.00L 0.00P -prefix t1_nudged.nii.gz t1_raw.nii.gz
```
* then re-run preprocess_mid1.sh script, only change the "rawt1_file" variable to the newly nudged t1 nifti file 

- if the problem appears to be bad alignment between a subject's anatomy & the anatomical template (to check this, load files "t1_tlrc.nii.gz" and "TT_N27.nii" in afni viewer; note you'll have to place a copy the TT_N27.nii file in the subject's func_proc directory), try using different options for the "@auto_tlrc" command (see documentation here: https://afni.nimh.nih.gov/pub/dist/doc/program_help/@auto_tlrc.html). 



### Pre-process fmri data
from a terminal command line, cd to your scripts directory and run:
```
./preprocess_mid2.sh
```
this script does the following using AFNI commands:
* removes first 6 volumes from functional scan (to allow t1 to reach steady state)
* slice time correction
* motion correction (6-parameter rigid body)
* saves out a vector of which volumes have lots of motion (will use this to censor volumes in glm estimation step)
* spatially smooths data 
* converts data to be in units of percent change (mean=100; so a value of 101 means 1% signal change above that voxel's mean signal)
* highpass filters the data to remove low frequency fluctuations
* transforms pre-processed functional data into standard group (tlrc) space using transforms estimated in "preprocess_mid1.sh" script
* saves out white matter, csf, and nacc VOI time series as single vector text files (e.g., 'mid_csf_ts.1D') 

#### output 
files saved out to directory **data/subjid/func_proc** are: 
* pp_mid.nii.gz				# pre-processed fmri data in native space
* pp_mid_tlrc_afni.nii.gz	# " " in standard space
* mid_vr.1D					# volume-to-volume motion estimates (located in columns 2-7 of the file)
* mid_censor.1D 			# vector denoting which volumes to censor from glm estimation due to bad motion
* mid_enorm.1D 				# euclidean norm of volume-to-volume motion (combines x,y,z displacement and rotation)
* mid _ [VOI] _ afni.1D		# VOI time series files for a few relevant VOIs. 



### QA check head motion & spikes 

Now that we've estimated a subject's head motion, lets determine who (if any) from the sample should be excluded for bad motion. You can use these 2 matlab scripts to save out motion figures and to generate a list of which (if any) subjects to exclude based on a given threshold:
```
doQA_subj_script # saves out motion plots for each subject
doQA_group_script # plots group-level motion stats
```

You can also use afni's 1dplot command from the terminal to check out subjects' motion on-the-fly, e.g:  
```
1dplot mid_vr.1D[1..6] # plots all 6 displacement & rotation motion parameters 
```
or try: 
```
1dplot mid_enorm.1D # to plot a summary measure (euclidean norm) of volume-to-volume motion 
```
In general, we consider "bad" motion to be anything greater than a euclidean norm value of 0.5-1, and we censor timepoints with bad motion from our analyses. We also then decide on a threshold of how many "bad" timepoints a subject can have before they are excluded from analysis for bad motion. A typical value for this would be, say, 3% of the data (i.e., subject's that have bad motion in 3% or more of their volumes for a given task would be excluded from analysis). 

You might also want to plot some VOI timeseries to make sure they look okay (e.g., no strange spikes that can't be explained by head motion):
```
1dplot mid_nacc_ts.1D # plot NAcc VOI timeseries
```



### Get stimulus onset times and make regressors
From terminal, cd to your scripts directory, enter desired subject IDs, and run: 
```
./regs_mid.csh
```
this script loads behavioral data to get stimulus onset times and saves out regressors of interest. Saved out files each contain a single vector of length equal to the number of TRs in the task with mostly 0 entries, and than 1 to indicate when an event of interest occurs. These vectors are then convolved with an hrf using AFNI's waver command to model the hemodynamic response. 

Note that the output files from this script are used for estimating single-subject GLMs as well as for plotting VOI timecourses. 

#### output 
this should create directory **data/subjid/regs** which should contain all the regressor and stimulus timing files. The nomenclature for file naming is generally: [condition or contrast] _ [trial period] _ [task].1D. 

For example, the file, "gvn_ant_mid.1D" means that the regressor is for the contrast of gain versus no gain trials ("gvn"), modeling the anticipation period ("ant"), for the mid task. Regressors that have been convolved with a hemdynamic response function (hrf) have a "c" before the ".1D" file suffix, e.g., gvn_ant_midc.1D. 

To see what the regressors look like, you can plot them using AFNI's 1dplot command, e.g.,

```
1dplot gvn_ant_midc.1D
```


### Subject-level GLMs
From terminal command line, cd to your scripts directory and run: 
```
python glm_mid.py
```
to specify GLM and fit that model to data using afni's 3dDeconvolve. There's excellent documentation on this command [here](https://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf). 

#### output 
saves out the following files to directory **data/results_mid**:
* subjid_glm_B+tlrc 	# file containing only beta coefficients for each regressor in GLM
* subjid_glm+tlrc 		# file containing a bunch of stats (beta coefficients and corresponding t statistics, Rsquared, etc)
* subjid_glm.xmat.1D 	# file containing the 
To check out glm results, open these files in afni as an overlay (with, e.g., TT_N27.nii as underlay). You can also get info about these files using afni's 3dinfo command, e.g., from the terminal command line, `3dinfo -verb subjid_glm_B+tlrc`.

Once you have those files, cd to the **results_mid** directory, and open the afni viewer (type "afni") in the terminal; load the anatomical template, TT_N27.nii as the underlay (you may need to add a copy of that nifti file into the results_mid directory), and load a "subjid_glm+tlrc" file as the overlay. You can change which stat map you are viewing as the overlay by clicking on the "Olay" dropdown menu within Afni's viewer window. Poke around. Here's what a single subject's gain vs no-gain anticipation t-statistic map looks like: 

<p align="center">
  <img width="332" height="302" src="https://github.com/kellyhennigan/MID_processing_example/blob/master/subj002_gvn_y12.jpg">
</p>



### Generate VOI timecourses
In matlab, cd to your scripts directory and run: 
```
saveRoiTimeCourses_script
```
and then: 
```
plotRoiTimeCourses_script
```
to save out and plot VOI timecourses for events of interest. 

#### output 
Saves out VOI timecourses (as csv files) to directory **data/timecourses_mid/** and saves out figures to **figures/timecourses_mid/**.

Here are some example timecourse plots for this sample of 42 controls; note that error bars show standard error of the mean (SEM): 

NAcc is parametrically modulated by gain amount (i.e., activation for $5 > $1 > $0) during the anticipation phase (i.e., t=4-6 seconds after trial onset):
![](repo_figs/nacc_gain_trials.png)


...but is less sensitive to gain vs nongain outcomes (i.e., t=12 seconds after trial onset): 
![](repo_figs/nacc_gain_trials_by_outcome.png)


On the other hand, MPFC cares less about gain anticipation amount: 
![](repo_figs/mpfc_gain_trials.png)


But MPFC differentiates by outcomes (e.g., gain vs nongain outcome):
![](repo_figs/mpfc_gain_trials_by_outcome.png)


You can also plot an VOI timecourse for a given condition by subject with this script: 
```
plotRoiTimeCourses_subject_script
```
which is mainly for troubleshooting purposes; it helps to see if the timecourses look funky for a particular subject. 


### Group level brain maps
Once you have GLM estimates for every subject, generate group brain maps with afni's 3dttest++ command using this bash script:
```
./ttest.sh
```



#### output 
Saves out group maps to the directory, 'results_mid'. 

If you cd to the results_mid directory and open afni, you can then view the group maps as an overlay on an anatomical underlay. 

This can show, for example, that the striatum (including NAcc) is activated for gain vs nongain anticpation (i.e., "Zgvnant"): 
![](repo_figs/gvnant_y10.png)

![](repo_figs/gvnant_z0.png)

And mpfc is activated for gain vs nogain outcomes (i.e., "Zgvnout"):
![](repo_figs/gvnout_x1.png)

![](repo_figs/gvnout_z0.png)


### TO DO: 
- add motion plot QC script
- convert regs script from c-shell to bash
- convert glm script from python to bash? 
