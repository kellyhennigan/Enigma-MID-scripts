% clear workspace
clear all
close all


%%%%%%%%%%%%%%%%%%%  define experiment directories %%%%%%%%%%%%%%%%%%%%%%%%

% assume this is being run from the "script" directory
scriptsDir=pwd;
cd ..; mainDir = pwd; cd(scriptsDir);
dataDir = [mainDir '/data'];


% add scripts to matlab's search path
path(path,genpath(scriptsDir)); % add scripts dir to matlab search path


subjects = getMIDSubjects('mid');


if ~isempty(strfind(dataDir,'agebias'))
    runvols=[264 283];  % # of volumes for split half in agebias dataset
else
    runvols=[256 292];  % # of volumes in each run
end


task='mid';

% relative to subject dir; %s is task
fnames = {'func_proc/%s_censor.1D',...
    'func_proc/%s_csf_ts.1D',...
    'func_proc/%s_wm_ts.1D',...
    'func_proc/%s_nacc_ts.1D',...
    'func_proc/%s_vr.1D',...
    'regs/ant_%sc.1D',...
    'regs/out_%sc.1D',...
    'regs/gvn_ant_%sc.1D',...
    'regs/lvn_ant_%sc.1D',...
    'regs/gvn_out_%sc.1D',...
    'regs/nvl_out_%sc.1D',...
    'regs/gain0_trial_%s.1D',...
    'regs/gain1_trial_%s.1D',...
    'regs/gain5_trial_%s.1D',...
    'regs/gainwin_trial_%s.1D',...
    'regs/gainmiss_trial_%s.1D',...
    'regs/loss0_trial_%s.1D',...
    'regs/loss1_trial_%s.1D',...
    'regs/loss5_trial_%s.1D',...
    'regs/losswin_trial_%s.1D',...
    'regs/lossmiss_trial_%s.1D'};

%%

cd(dataDir);

i=1;
for i=1:numel(subjects)

    subject=subjects{i};

    cd(subject);
    
    j=1;
    for j=1:numel(fnames)
        this_fname = sprintf(fnames{j},task);
        
        % out names for runs 1 and 2
        out_fname1 = sprintf(fnames{j},[task '1']);
        out_fname2 = sprintf(fnames{j},[task '2']);
        
        ts=dlmread(this_fname);
        
        if size(ts,1)~=sum(runvols)
            error('in file has an unexpected number of entries');
        end
        
        dlmwrite(out_fname1,ts(1:runvols(1),:));
        dlmwrite(out_fname2,ts(runvols(1)+1:end,:));
        
    end
    
    cd(dataDir);
    
end % subjects



