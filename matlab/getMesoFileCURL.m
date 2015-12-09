function status = getMesoFileCURL(procYear, procMonth, procDay, ...
    procStation, outDir)
<<<<<<< HEAD
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
=======
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
>>>>>>> origin/master
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

<<<<<<< HEAD
% =====================================================================
% Use cURL to fetch the data.  This command can be run from the system
% level, so first a command string has to be built which contains the
% command and the exact file which is to be retrieved.
% =====================================================================
=======
% Use cURL to fetch the data.  This command can be run from the system
% level, so first a command string has to be built which contains the
% command and the exact file which is to be retrieved.
>>>>>>> origin/master
baseURL = 'https://www.mesonet.org/index.php/dataMdfMts/dataController/getFile/';
dateLocationString = sprintf('%4.4d%2.2d%2.2d%s/mts/DOWNLOAD/', ...
    procYear, procMonth, procDay, procStation);
URL = ['"' baseURL dateLocationString '"'];

<<<<<<< HEAD
% =====================================================================
% Check if outDir exists, if not then create it.
% =====================================================================
=======
% Check if outDir exists, if not then create it.
>>>>>>> origin/master
if ~exist(outDir, 'dir')
    mkdir(outDir)
end

<<<<<<< HEAD
% =====================================================================
% Construct the file name
% =====================================================================
fileName = sprintf('%4.4d%2.2d%2.2d%s.mts', procYear, procMonth, procDay, procStation);

% =====================================================================
% Create the command string to pass to CURL
% =====================================================================
cmdstr = ['curl -o ' outDir fileName ' ' URL];

% =====================================================================
% Actually call CURL
% =====================================================================
=======
% Construct the file name
fileName = sprintf('%4.4d%2.2d%2.2d%s.mts', procYear, procMonth, procDay, procStation);

% Create the command string to pass to CURL
cmdstr = ['curl -o ' outDir fileName ' ' URL];

% Actually call CURL
>>>>>>> origin/master
system(['DYLD_LIBRARY_PATH="";' cmdstr]);

fprintf('Created %s in %s\n', fileName, outDir)
status = 1;