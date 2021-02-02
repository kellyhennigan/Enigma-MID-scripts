
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
    
end % subjects


