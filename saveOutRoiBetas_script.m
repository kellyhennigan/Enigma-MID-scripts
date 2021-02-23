% script for saving out roi betas

% this is basically to define the files, etc. to feed to the function,
% saveOutRoiBetas()


%% define variables:

clear all
close all

% assume this is being run from the "script" directory
scriptsDir=pwd;
cd ..; mainDir = pwd; cd(scriptsDir);
dataDir = [mainDir '/data']; 
figDir = [mainDir '/figures']; 


% add scripts to matlab's search path
path(path,genpath(scriptsDir)); % add scripts dir to matlab search path


subjects = getMIDSubjects('mid');


% ROIs
% roiNames = {'VTA','ins_desai','mpfc','vstriatumR_clust','vstriatumL_clust','VTA_clust'};
roiDir = fullfile(mainDir,'templates');
roiNames = {'nacc_desai_func','mpfc_func','ins_desai_func','v1_func','motorcortexL_func','acing_func','caudate_func'}; 


% directory that contains glm results of interest
resultsDir = fullfile(dataDir,['results_mid_afni']);
% resultsDir = fullfile(dataDir,['results_' task '_afni_reltest']);

     
%%% MAKE SURE THESE ARE THE CORRECT VOLUME INDICES!!!
fileStr = 'glm_B+tlrc.HEAD'; % string identifying files w/single subject beta maps
volIdx = [13,14,15,16]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
bNames = {'gvnant','lvnant','gvnout','nvlout'}; % bNames should correspond to volumes in index volIdx


% out file path
outStrPath = fullfile(resultsDir,'roi_betas','%s','%s.csv'); %s is roiNames and bNames


%% do it

for j = 1:numel(roiNames)
    
    roiFilePath = fullfile(roiDir,[roiNames{j} '_func.nii']);
    
    for k = 1:numel(bNames)
        
        outFilePath = sprintf(outStrPath,roiNames{j},bNames{k});
        
        B = saveOutRoiBetas(roiFilePath,subjects,resultsDir,fileStr,volIdx(k),outFilePath);
        
    end % beta names
    
end % roiNames



