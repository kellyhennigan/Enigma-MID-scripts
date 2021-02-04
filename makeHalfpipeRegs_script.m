
clear all
close all

% save out a file with regressor info to upload to halfpipe:

% A tab-separated table with named columns trial_type (condition), onset
% and duration.

%%

% assume this is being run from the "scripts" directory
scriptsDir=pwd;
cd ..; mainDir = pwd; cd(scriptsDir);
dataDir = [mainDir '/data'];


% add scripts dir to matlab's search path
path(path,genpath(scriptsDir)); % add scripts dir to matlab search path

subjects=getMIDSubjects();

% event names
condlist={'gain0','gain1','gain5','loss0','loss1','loss5',...
    'gainwin','gainmiss','losswin','lossmiss'};

% durations in units seconds
durlist=[4 4 4 4 4 4 2 2 2 2];


TR=2; % TR (in sec)


%% do it

for i=1:numel(subjects)
    
    % go to this subject's regs directory
    regDir=fullfile(dataDir,subjects{i},'regs');
    cd(regDir);
    
    conds=[];
    onsets=[];
    durations=[];
    
    for j=1:numel(condlist)
        
        cond=condlist{j};
        dur=durlist(j);
        
        % get onset times (in TR units)
        theseonsets=find(dlmread([cond '_trial_mid.1D']));
        
        % note that these onset times are for *trial onset*!
        % so for modeling the outcome period (i.e., gainwin/miss or
        % losswin/miss), add 3 TRs to these times
        if any(strcmp(cond,{'gainwin','gainmiss','losswin','lossmiss'}))
            theseonsets=theseonsets+3;
        end
        
        % convert units from TRs to seconds
        theseonsets=(theseonsets.*TR)-TR;
        
        % in case halfpipe doesn't like an onset time of 0 s,
        %     change a 0 onset time to be .1
        idx=find(theseonsets==0);
        if ~isempty(idx)
            theseonsets(idx)=.1;
        end
        
        conds=[conds; repmat({cond},numel(theseonsets),1)];
        onsets=[onsets; theseonsets];
        durations = [durations; repmat(dur,numel(theseonsets),1)];
        
    end % condlist
    
    T=table(conds,onsets,durations);
    
    writetable(T,'regs_halfpipeformat.txt','delimiter','\t')
    
    names=conds;
    save('regs_halfpipeformat.mat','names','onsets','durations');
    
end % subjects


% %% also, save out a regs file that contains baseline and nuisance regressors:
% 
% % linear and quadratic drift
% % 6 rigid-body motion estimates
% % csf and wm time series
% 
% nVolsPerRun=[256 292]; % number of volumes in pre-processed MID data
% 
% 
% % filepaths to csf and wm time series & head motion estimates
% csffile=fullfile(dataDir,'%s','func_proc','mid_csf_ts.1D');
% wmfile=fullfile(dataDir,'%s','func_proc','mid_wm_ts.1D');
% motfile=fullfile(dataDir,'%s','func_proc','mid_vr.1D');
% 
% for i=1:numel(subjects)
%     
%     subject=subjects{i};
%     
%     % go to this subject's regs directory
%     regDir=fullfile(dataDir,subjects{i},'regs');
%     cd(regDir);
%     
%     % load csf and wm time series
%     csf=dlmread(sprintf(csffile,subject));
%     wm=dlmread(sprintf(wmfile,subject));
%     
%     % load head motion estimates
%     mot=dlmread(sprintf(motfile,subject));
%     motion1=mot(:,2); motion2=mot(:,3); motion3=mot(:,4);
%     motion4=mot(:,5); motion5=mot(:,6); motion6=mot(:,7);
%     
%     Xnuisance=table(csf,wm,motion1,motion2,motion3,motion4,motion5,motion6);
%     
%     baseregs=modelBaseline(nVolsPerRun,2);
%     npolybase1_run1=baseregs(:,1);
%     npolybase2_run1=baseregs(:,2);
%     npolybase3_run1=baseregs(:,3);
%     npolybase1_run2=baseregs(:,4);
%     npolybase2_run2=baseregs(:,5);
%     npolybase3_run2=baseregs(:,6);
%     
%     Xbase=table(npolybase1_run1,npolybase2_run1,npolybase3_run1,...
%         npolybase1_run2,npolybase2_run2,npolybase3_run2);
%     
%     % save out baseline and nuisance regressors
%     writetable(Xnuisance,'nuisance_regs_halfpipeformat.txt','delimiter','\t')
%     writetable(Xbase,'baseline_regs_halfpipeformat.txt','delimiter','\t')
%     
%     % combine and save them out into 1 file
%     Xbase_nuisance=[Xbase Xnuisance]; 
%     
%     writetable(Xbase_nuisance,'baseline_nuisance_regs_halfpipeformat.txt','delimiter','\t')
%     
% end % subjects
