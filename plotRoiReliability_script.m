%% define variables and filepaths 

% clear workspace
clear all
close all


%%%%%%%%%%%%%%%%%%%  define experiment directories %%%%%%%%%%%%%%%%%%%%%%%%

% assume this is being run from the "script" directory
scriptsDir=pwd;
cd ..; mainDir = pwd; cd(scriptsDir);
dataDir = [mainDir '/data']; 
figDir=[mainDir '/figures']; 


% add scripts to matlab's search path
path(genpath(scriptsDir),path); % add scripts dir to matlab search path


subjects = getMIDSubjects('mid');


% timecourse directory
tcDir='timecourses_mid_splithalf';
tcPath = fullfile(dataDir,tcDir);


% which rois to process?
% roiNames = {'nacc','mpfc','ins','v1','motorcortexL','acing','caudate'}; 
roiNames = {'mpfc','nacc','ins'}

nTRs = 9; % # of TRs to plot
TR = 2; % TR (in units of seconds)
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

% each row determines what will be plotted in a single figure
% stim names should be separated by a space and must correspond to the
% names of the csv files with saved timecourses. 
% this script will recognize '-' and perform a subtract of those stims. 

% e.g. plotStims = {'gain0 gain1 gain5'} will plot a figure with 3
% lines: one line for gain0, one line for gain1, etc. 

% e.g. plotStims = {'gain5-gain0'} will plot a figure with 1 line: gain5
% trial timecourses minus gain0 trial timecourses

plotStims = {'gain0 gain1 gain5';
    'gainwin gainmiss';
    'loss0 loss1 loss5';
    'losswin lossmiss'};

% must have the same # of rows as plotStims; this will be used for the
% outfile names. It should be a desription of what is being plotted as
% determined by plotStims entries.
plotStimStrs = {'gain trials';
    'gain trials by outcome';
    'loss trials';
    'loss trials by outcome'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% run it - you shouldnt have to edit past this line 


if ~isequal(numel(plotStims),numel(plotStimStrs))
    error('plotStims and plotStimStrs need to have the same # of entries')
end
    
nFigs=size(plotStims,1);


% get ROI time courses
j=1;
for j = 1:numel(roiNames)
    
    roiName = roiNames{j};
    
    inDir = fullfile(tcPath,roiName); % time courses dir for this ROI
    
    
    %% define time courses to plot
    
    f=1;
    for f = 1:nFigs
        
        clear r rvals
        
        % get the name & stims to plot for this figure
        stims = splitstring(plotStims{f});
        stimStr = plotStimStrs{f};
        
        c=1;
        for c = 1:numel(stims)
            
            % load timecourses
                stimFile1 = fullfile(inDir,[stims{c} '_half1.csv']);
                tc1=loadRoiTimeCourses(stimFile1,subjects,1:nTRs);
                stimFile2 = fullfile(inDir,[stims{c} '_half2.csv']);
                tc2=loadRoiTimeCourses(stimFile2,subjects,1:nTRs);
              
                % remove any subjects if they have nan values 
                % (for example, if a subject had no missed loss trials in
                % run 1, they would have nan values for that condition. NaN
                % values mess up the correlation calculation, so take them
                % out. 
                if any(isnan(tc1)) || any(isnan(tc2))
                    [nanidx1,~]=find(isnan(tc1)); [nanidx2,~]=find(isnan(tc2));
                    nanidx=[unique(nanidx1) unique(nanidx2)];
                    tc1(nanidx,:)=[]; tc2(nanidx,:)=[];
                end
                    
                % calculate the correlation btwn the 2 runs for each TR
                r{c}=diag(corr(tc1,tc2));
                rvals{c}= sprintf(['%s trials, TRs 1-%d: ' repmat('%.2f  ',1,nTRs)],stims{c},r{c});
                
            
        end % stims
        

          %% set up all plotting params
        
        % fig title
        figtitle = [strrep(roiName,'_',' ') ' reliability for ' stimStr ];
        
        % x and y labels
        xlab = 'time (TRs)';
        ylab = 'split-half reliablity metric';
      
        % line colors & line specs
        [cols,lspec] = getTCPlotColLineSpec(stims);
        
      
        % filepath, if saving
        outDir = fullfile(figDir,'timecourses_reliablity',roiName);
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
        outName = [roiName '_' stimStr];
        savePath = fullfile(outDir,outName);
        
        
        
        %% finally, plot the thing!
        
        fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);
        
        % you could add code here to do statistical testing at each time
        % point and get p-values. If you give p-values to the plot function
        % below, it will plot asterisks on the figure.
        se = []; pvals = []; 
        plotToScreen=0; % dont plot to screen
        [fig,leg]=plotNiceLines(1:nTRs,r,se,cols,lspec,pvals,stims,xlab,ylab,figtitle,[],plotToScreen);

        set(gca,'XTick',1:nTRs)
        ylim([-.6 .7])
        print(gcf,'-dpng','-r300',savePath);
           
        fprintf('done.\n\n');
        
        
    end % figures
    
    close all
    
end %roiNames

       