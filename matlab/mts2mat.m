function [matFileName, dataDir, status] = mts2mat(procYear, ...
    procMonth, procDay, procStation, fetchFlag, baseDir)
% =====================================================================
% mts2mat
% [matFileName, dataDir, status] = mts2mat(procYear, ...
%    procMonth, procDay, procStation, fetchFlag, baseDir)
% =====================================================================
% Create mat files from mesonet mts files
% Inputs:
% procYear    = year to process
% procMonth   = month to process
% procDat     = day to process
% procStation = mesonet station to process, e.g., 'nrmn', 'wash'
% fetchflag   = flag indicating whether to retrieve data file automatically
%               from the mesonet site (Mac only)
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
sensorType = 'Mesonet';

% =====================================================================
% Create the directory using the file separators appropriate for your OS
% =====================================================================
dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

% =====================================================================
% This allows you to grab the data automatically from the mesonet site, but
% it requires the CURL library. If you are using a PC then you will need to
% download the file by hand and place it in the appropriate directory.
% =====================================================================
if fetchFlag
    fprintf('Fetching data from mesonet for %s on %4.4d-%2.2d-%2.2d\n', ...
        procStation, procYear, procMonth, procDay)
    getStatus = getMesoFileCURL(procYear, procMonth, ...
        procDay, procStation, dataDir);
    if getStatus ~= 1
        fprintf('*** mst2mat: problem getting mesonet data ... exiting!\n')
        status = 0;
        return
    end
end

% =====================================================================
% Read in the data file and create a matlab structured array
% =====================================================================
mesoFileName = sprintf('%4.4d%2.2d%2.2d%s.mts', procYear, procMonth, procDay, procStation);
if exist([ dataDir mesoFileName ], 'file')
    [mts, readStatus] = readMTSData(mesoFileName, dataDir);
    if ~readStatus
        status = 0;
    end
else
    fprintf('mts2mat: searching for %s\n', [ dataDir fileName ])
    fprintf('*** Data file not found ... exiting!\n')
    status = 0;
    return
end

% =====================================================================
% Create the mat file name and save the structured array
% =====================================================================
matFileName = strrep(mesoFileName, '.mts', '.mat');
fprintf('Creating file: %s\n', [ dataDir matFileName ])
save([ dataDir matFileName ], 'mts')

status = 1;