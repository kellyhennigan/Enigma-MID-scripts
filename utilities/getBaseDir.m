function baseDir = getBaseDir()
% -------------------------------------------------------------------------
% usage: function to get path to experiment base directory, which is
% different depending on which computer this function is running on
% 
% OUTPUT:
%   baseDir - string specifiying data directory path
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName;

if strcmp(cName,'uncus')               % uncus server
    baseDir = '/Volumes/pegasus/enigma_mid';
elseif strcmp(cName,'vta')               % vta server
    baseDir = '/home/span/lvta/cueexp';
else                                   % assume its my laptop
    baseDir = '/Users/kelly/enigma_mid';
end
