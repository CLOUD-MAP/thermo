function [fileName, status] = getMtsFile(procYear, procMonth, procDay, ...
    procStation, fetchFlag, baseDir)
% =====================================================================
% getMtsFile
% [status] = getMtsFile(procYear, procMonth, procDay, ...
%    procStation, fetchFlag, baseDir)
% =====================================================================
% If not present, get mts file
% Inputs:
% procYear    = year to process
% procMonth   = month to process
% procDate    = day to process
% procStation = mesonet station to process, e.g., 'nrmn', 'wash'
% fetchflag   = flag indicating whether to retrieve data file automatically
%               from the mesonet site (Mac only)
% baseDir     = local directory where your 'thermo' folder lives
% Outputs
% status      = flag indiating status of read
% Created 2016-1-28 Phil Chilson
% Revision history

% =====================================================================
% Set up the inputs
% =====================================================================
sensorType = 'Mesonet';

% =====================================================================
% Create the directory using the file separators appropriate for your OS
% =====================================================================
dataDir = getDataDir(procYear, procMonth, procDay, sensorType);

% =====================================================================
% Check if the mts file exists
% =====================================================================
fileName = sprintf('%4.4d%2.2d%2.2d%s.mts', procYear, procMonth, procDay, procStation);

if ~exist([ dataDir fileName ], 'file')
    % Try to retrieve the data if possible, if not then exit
    getStatus = getMesoFile(procYear, procMonth, procDay, procStation, dataDir);
    if getStatus ~= 1
        fprintf('*** Problem getting mesonet data ... exiting!\n')
        status = 0;
        return
    end
end

status = 1;