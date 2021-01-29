function subjects = getMIDSubjects()
% -------------------------------------------------------------------------
% subjects = getMIDSubjects(task)

% usage: returns cell array with subject id strings for this experiment.
% NOTE: this assumes that there is a file named 'subjects' within the exp
% data folder that has a list of the subject ids and a group index (0 for
% controls, 1 for patients).


% OUTPUT:
%   subjects - cell array of subject id strings for this experiment

% notes:
%

% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('task','var')
    task='';
end

% get subjects_list directory
% subjListFileName = fullfile(getBaseDir,'subjects_list.csv');

% read in subjects list
% T=readtable(subjListFileName);

% get subjects_list directory
subjListFileName = fullfile(getBaseDir,'subjects.txt');

% read in subjects list
T=readtable(subjListFileName,'ReadVariableNames',0);

% define subject id cell array & vector of corresponding group indices
subjects = table2array(T(:,1));


% % if task is defined, return only good subjects for that task
% if ~isempty(task)
%     taskindex = find(strcmpi(task,T.Properties.VariableNames));
%     if isempty(taskindex)
%         fprintf(['\ntask name ' task ' not recognized;\n returning all subjects...\n'])
%     else
%         subjects(table2array(T(:,taskindex))==0)=[];
%     end
% end


end % function





