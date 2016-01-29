function status = getMesoFileCURL(procYear, procMonth, procDay, ...
    procStation, outDir)
% =====================================================================
% getMesoFileCurl
% status = getMesoCURL(year, month, day, station, directory)
% =====================================================================
% Used to automatically retrieve mesonet data from the internet
% Only runs on a Mac
% Inputs
% procYear    = year to process
% procMonth   = month to process
% procDat     = day to process
% procStation = mesonet station to process, e.g., 'nrmn', 'wash'
% outDir      = directory to write file to
%   note that the end delimeter should be included, e.g., './data/'
%   if the directory is not provided, then the working directory is used
% Outputs
% status      = status of call
% Created 2015-12-09 Phil Chilson
% Revision history

% =====================================================================
% Check the input arguments and potentially set the output directory
% =====================================================================
switch nargin
    case 4
        % outDir not specified, use pwd
        outDir = pwd;
    case 5
        % we're good here
    otherwise
        fprintf('*** error calling getMesoFileCurl ... exiting!\n')
        status = 0;
        return
end

% =====================================================================
% Construct the file name
% =====================================================================
fileName = sprintf('%4.4d%2.2d%2.2d%s.mts', procYear, procMonth, procDay, procStation);

% =====================================================================
% Check if outDir exists, if not then create it.
% =====================================================================
if ~exist(outDir, 'dir')
    mkdir(outDir)
end

% =====================================================================
% Two different approaches depending on whether file is from the NWC or one
% of the standard stations
% =====================================================================
if strcmp(procStation, 'nwcm')
    baseURL = 'http://www.mesonet.org/data/public/nwc/mts-1m/';
    URL = sprintf('%s%4.4d/%2.2d/%2.2d/%s', ...
        baseURL, procYear, procMonth, procDay, fileName);
    urlwrite(URL, [outDir fileName]);
else
    % =====================================================================
    % Use cURL to fetch the data.  This command can be run from the system
    % level, so first a command string has to be built which contains the
    % command and the exact file which is to be retrieved.
    % =====================================================================
    baseURL = 'https://www.mesonet.org/index.php/dataMdfMts/dataController/getFile/';
    dateLocationString = sprintf('%4.4d%2.2d%2.2d%s/mts/DOWNLOAD/', ...
        procYear, procMonth, procDay, procStation);
    URL = ['"' baseURL dateLocationString '"'];
    
    % =====================================================================
    % Create the command string to pass to CURL
    % =====================================================================
    cmdstr = ['curl -o ' outDir fileName ' ' URL];
    
    % =====================================================================
    % Actually call CURL
    % =====================================================================
    system(['DYLD_LIBRARY_PATH="";' cmdstr]);
end

fprintf('Created %s in %s\n', fileName, outDir)
status = 1;
