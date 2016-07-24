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
            fprintf('*** Problem getting mesonet data ... exiting!\n')
            status = 0;
            return
        end
    else
        fprintf('Searching for %s\n', [ dataDir fileName ])
        fprintf('*** Data file not found ... exiting!\n')
        status = 0;
        return
    end
end

status = 1;