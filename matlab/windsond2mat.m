function [matFileName, dataDir, status] = windsond2mat(procYear, ...
    procMonth, procDay, baseDir)
<<<<<<< HEAD
% =====================================================================
% windsond2mat
% [matFileName, dataDir, status] = windsond2mat(procYear, ...
%    procMonth, procDay, baseDir)
% =====================================================================
% Create mat files from windsond files
% Inputs:
% procYear    = year to process
% procMonth   = month to process
% procDat     = day to process
% baseDir     = local directory where your 'thermo' folder lives
% Outputs
% matFileName = name of the mat file generated
% dataDir     = directory used to read and write data
% status      = flag indiating status of read
% Created 2015-12-09 Phil Chilson
% Revision history

% =====================================================================
% Set up the inputs
% =====================================================================
sensorType = 'Windsond';

% =====================================================================
% Create the directory using the file separators appropriate for your OS
% =====================================================================
dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

% =====================================================================
% Find all iMet files in the directory
% =====================================================================
d = dir([ dataDir '*.sounding']);
nFiles = length(d);

% =====================================================================
% Step through all the iMet files in the directory, read them, and create
% a corresponding mat file
% =====================================================================
=======
% Comments coming

% Set up the inputs
sensorType = 'Windsond';

% Create the directory using the file separators appropriate for your OS
dataDir = sprintf('%sthermo%sdata%s%s%s%4.4d%s%2.2d%s%2.2d%s', ...
    baseDir, filesep, filesep, sensorType, filesep, ...
    procYear, filesep, procMonth, filesep, procDay, filesep);

% Find all iMet files in the directory
d = dir([ dataDir '*.sounding']);
nFiles = length(d);

% Step through all the iMet files in the directory
>>>>>>> origin/master
for iFile = 1: nFiles
    % Read in the data file and create a matlab structured array
    windsondFileName = d(iFile).name;
    [windsond, readStatus] = readWindsond(dataDir, windsondFileName);
    if readStatus
        % were good here
    else
<<<<<<< HEAD
        fprintf('*** windsond2mat: problem reading windsond data ... exiting!\n')
=======
        fprintf('*** Problem reading windsond data ... exiting!\n')
>>>>>>> origin/master
        matFileName = [];
        status = 0;
        return
    end
<<<<<<< HEAD
    % Create the mat file name and save the structured array
    matFileName{iFile} = strrep(windsondFileName, '.sounding', '.mat');
    fprintf('Creating file: %s\n', [ dataDir matFileName{iFile} ])
=======
    matFileName{iFile} = strrep(windsondFileName, '.sounding', '.mat');
>>>>>>> origin/master
    save([ dataDir matFileName{iFile} ], 'windsond')
end
status = 1;