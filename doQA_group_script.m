
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


subjects = getMIDSubjects();
%

savePlots = 1; % 1 to save plots, otherwise 0

figDir = fullfile(mainDir,'figures','QA');

task='mid';

%%

mp_file = [dataDir '/%s/func_proc/' task '_vr.1D']; % motion param file where %s is task

en_thresh = .5;
percent_bad_thresh = 3;

run2vol1idx=257;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(figDir,'dir') && savePlots
    mkdir(figDir);
end

% define vectors and matrices to be filled in
max_en = nan(numel(subjects),1); % max movement from 1 vol to the next
max_TR = nan(numel(subjects),1); % TR w/max movement
nBad = nan(numel(subjects),numel(en_thresh)); % # of vols w/movement > en_thresh
omit_idx = nan(numel(subjects),numel(en_thresh)); % 1 to suggest omitting, otherwise 0


for s = 1:numel(subjects)
    
    subject = subjects{s};
    fprintf(['\nworking on subject ' subject '...\n\n']);
    
    mp = []; % this subject's motion params
    
    % get task motion params
    try
        mp = dlmread(sprintf(mp_file,subject));
        mp = mp(:,[6 7 5 2:4]); % rearrange to be in order dx,dy,dz,roll,pitch,yaw
    catch
        warning(['couldnt get motion params for subject ' subject ', so skipping...'])
    end
    
    
    if ~isempty(mp)
        
        % calculate euclidean norm (head motion distance roughly in mm units)
        en = [0;sqrt(sum(diff(mp).^2,2))];
        
        if exist('run2vol1idx','var')
            en(run2vol1idx)=0; % there's no "motion" in the 1st vol of the 2nd run; correctly assign motion to 0
        end
        
        % determine this subject's max movement
        [max_en(s,1),max_TR(s,1)]=max(en);
        
        
        
        for i=1:numel(en_thresh)
            
            % calculate # of bad vols based on en_thresh
            nBad(s,i) = numel(find(en>en_thresh(i)));
            
            fprintf('\n%s has %d vols with motion > %.1f, which is %.2f percent of %s vols\n\n',...
                subject,nBad(s,i),en_thresh(i),100.*nBad(s,i)/numel(en),task);
            
            
            % determine whether to omit subject or not, based on percent_bad_thresh
            if 100.*nBad(s,i)/numel(en)>percent_bad_thresh(i)
                omit_idx(s,i) = 1;
            else
                omit_idx(s,i) = 0;
            end
            
        end
        
    end % isempty(mp)
    
end % subjects



%% plot histogram of bad volume count

for i=1:numel(en_thresh)
    
    fig=setupFig;
    hist(nBad(:,i),numel(subjects));
    
    xlabel(['# of TRs with head movement > euc dist of ' num2str(en_thresh(i))])
    ylabel('# of subjects')
    title(['head movement during ' task ' task'])
    
    hold on
    yl=ylim;
    h2=plot([floor(numel(en).*percent_bad_thresh(i)./100) floor(numel(en).*percent_bad_thresh(i)./100)],[yl(1) yl(2)],'k--');
    
    legend(h2,{['percent bad thresh=' num2str(percent_bad_thresh(i))]})
    legend('boxoff')
    
    if savePlots
        figPath = fullfile(figDir,['subj_hist_en_thresh' num2str(en_thresh(i)) '.png']);
        print(gcf,'-dpng','-r300',figPath)
    end
    
end

%% calculate tSNR

%% show where censored TRs are



%%