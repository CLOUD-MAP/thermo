function [matFileName, dataDir, status] = iMet2mat(procYear, ...
    procMonth, procDay, baseDir)
<<<<<<< HEAD
% =====================================================================
% iMet2mat
% [matFileName, dataDir, status] = iMet2mat(procYear, ...
%    procMonth, procDay, baseDir)
% =====================================================================
% Create mat files from iMet XQ files
% Inputs:
% procYear    = year to process
% procMonth   = month to process
% procDat     = day to process
% procStation = mesonet station to process, e.g., 'nrmn', 'wash'
% baseDir     = local directory where your 'thermo' folder lives
% Outputs
% matFileName = name of the mat file generated
% dataDir     = directory used to read and write data
% status      = flag indiating status of read
% Created 2015-12-07 Phil Chilson
% Revision history

% =====================================================================
% Set up the inputs
% =====================================================================
sensorType = 'iMet';

% =====================================================================
% Create the directory using the file separators appropriate for your OS
% =====================================================================
dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

% =====================================================================
% Find all iMet files in the directory
% =====================================================================
d = dir([ dataDir '*.csv']);
nFiles = length(d);

% =====================================================================
% Step through all the iMet files in the directory, read them, and create
% a corresponding mat file
% =====================================================================
for iFile = 1: nFiles
    % Read in the data file and create a matlab structured array
    iMetFileName = d(iFile).name;
    [iMetXQ, readStatus] = readiMetXQ(dataDir, iMetFileName);
    if readStatus
        % we're good here
    else
        fprintf('*** iMet2mat: problem reading iMet data ... exiting!\n')
=======
% Comments coming

% Set up the inputs
sensorType = 'iMet';

% Create the directory using the file separators appropriate for your OS
dataDir = sprintf('%sthermo%sdata%s%s%s%4.4d%s%2.2d%s%2.2d%s', ...
    baseDir, filesep, filesep, sensorType, filesep, ...
    procYear, filesep, procMonth, filesep, procDay, filesep);

% Find all iMet files in the directory
d = dir([ dataDir '*.csv']);
nFiles = length(d);

% Step through all the iMet files in the directory
for iFile = 1: nFiles
    % Read in the data file and create a matlab structured array
    iMetFileName = d(iFile).name;
    [dataXQ, readStatus] = readiMetXQ(dataDir, iMetFileName);
    if readStatus
        % were good here
    else
        fprintf('*** Problem reading iMet data ... exiting!\n')
>>>>>>> origin/master
        matFileName = [];
        status = 0;
        return
    end
<<<<<<< HEAD
    % Create the mat file name and save the structured array
    matFileName{iFile} = strrep(iMetFileName, '.csv', '.mat');
    fprintf('Creating file: %s\n', [ dataDir matFileName{iFile} ])
    save([ dataDir matFileName{iFile} ], 'iMetXQ')
=======
    matFileName{iFile} = strrep(iMetFileName, '.csv', '.mat');
    save([ dataDir matFileName{iFile} ], 'dataXQ')
>>>>>>> origin/master
end
status = 1;