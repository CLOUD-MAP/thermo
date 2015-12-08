function status = getMesoFileCURL(procYear, procMonth, procDay, ...
    procStation, outDir)
% getMesoFileCurl
% Created by Phil Chilson
% status = getMesoCURL(year, month, day, station, directory)
% Function used to automatically fetch an MTS mesonet data file based on
% the input parameters
% year      = year of the observation
% month     = month of the observation
% day       = day of the observation
% station   = station name, e.g., 'wash' for Washtington
% directory = directory where data file should be placed
%   note that the end delimeter should be included, e.g., './data/'
%   if the directory is not provided, then the working directory is used
% If the call is successful then status == 1, otherwise status = 0
% Created 2015 12 07 Phil Chilson
% Revision history

% Check the input arguments and potentially set the output directory
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

% Use cURL to fetch the data.  This command can be run from the system
% level, so first a command string has to be built which contains the
% command and the exact file which is to be retrieved.
baseURL = 'https://www.mesonet.org/index.php/dataMdfMts/dataController/getFile/';
dateLocationString = sprintf('%4.4d%2.2d%2.2d%s/mts/DOWNLOAD/', ...
    procYear, procMonth, procDay, procStation);
URL = ['"' baseURL dateLocationString '"'];

% Check if outDir exists, if not then create it.
if ~exist(outDir, 'dir')
    mkdir(outDir)
end

% Construct the file name
fileName = sprintf('%4.4d%2.2d%2.2d%s.mts', procYear, procMonth, procDay, procStation);

% Create the command string to pass to CURL
cmdstr = ['curl -o ' outDir fileName ' ' URL];

% Actually call CURL
system(['DYLD_LIBRARY_PATH="";' cmdstr]);

fprintf('Created %s in %s\n', fileName, outDir)
status = 1;