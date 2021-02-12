
%%%%%%%% do QA on motion on data from cue fmri experiment

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


% subjects = getMIDSubjects();
subjects={'ab071412','bk032113','dp092612','na060213','pw061113','tr101312'};

savePlots = 1; % 1 to save plots, otherwise 0

figDir = fullfile(mainDir,'figures','QA');

task='mid';

%%

mp_file = [dataDir '/%s/func_proc/' task '_vr.1D']; % motion param file where %s is task

en_thresh = .5;
percent_bad_thresh = 3;

roi_str = 'nacc';
roits_file = [dataDir '/%s/func_proc/' task '_' roi_str '_ts.1D']; % roi time series file to plot where %s is task




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(figDir,'dir') && savePlots
    mkdir(figDir);
end

nBad = []; % vector noting the # of bad volumes for each subject
omit_idx = []; % 1 if receommended to omit a subject, otherwise 0

for s = 1:numel(subjects)
    
    subject = subjects{s};
    fprintf(['\nworking on subject ' subject '...\n\n']);
    
    mp = []; % this subject's motion params
    
    try
        mp = dlmread(sprintf(mp_file,subject));
        mp = mp(:,[6 7 5 2:4]); % rearrange to be in order dx,dy,dz,roll,pitch,yaw
    catch
        warning(['couldnt get motion params for subject ' subject ', so skipping...'])
    end
    
    
    if isempty(mp)
        max_en(s,1)=nan; max_TR(s,1)=nan; nBad(s,1)=nan; omit_idx(s,1)=nan;
    else
        
        % plot motion params & save if desired
        fig = plotMotionParams(mp);
        if savePlots
            outName = [subject '_mp'];
            print(gcf,'-dpng','-r300',fullfile(figDir,outName));
        end
        
        
        % calculate euclidean norm (head motion distance roughly in mm units)
        en = [0;sqrt(sum(diff(mp).^2,2))];
        
        
        % determine this subject's max movement
        [max_en(s,1),max_TR(s,1)]=max(en);
        
        
        % calculate # of bad images based on en_thresh
        nBad(s,1) = numel(find(en>en_thresh));
        fprintf('\n%s has %d bad image, which is %.2f percent of %s vols\n\n',...
            subject,nBad(s),100.*nBad(s,1)/numel(en),task);
        
        
        % determine whether to omit subject or not, based on percent_bad_thresh
        if 100.*nBad(s)/numel(en)>percent_bad_thresh
            omit_idx(s,1) = 1;
        else
            omit_idx(s,1) = 0;
        end
        
        
        % plot, if desired
        if ~isempty(roits_file) && exist(sprintf(roits_file,subject),'file')
            try
                ts = dlmread(sprintf(roits_file,subject));
            catch me
            end
            
        else
            ts = zeros(numel(en),1); roi_str = '';
        end
        
        fig = plotEnMotionThresh(en,en_thresh,ts,roi_str);
        
        % if a time series is plotted for diffusion data, ignore the b0 volumes
        % (it messes up the plot scale)
        if strcmp(task,'dti')
            subplot(2,1,2)
            ylim([min(ts)-1 max(ts(10:end))+1])
        end
        
        if savePlots
            outName = [subject '_mp2'];
            print(gcf,'-dpng','-r300',fullfile(figDir,outName));
        end
        
    end % isempty(mp)
    
end % subjects



%% calculate tSNR

%% show where censored TRs are



%%