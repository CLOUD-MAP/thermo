function [matFileName, dataDir, status] = windsond2mat(procYear, ...
    procMonth, procDay, baseDir)
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
for iFile = 1: nFiles
    % Read in the data file and create a matlab structured array
    windsondFileName = d(iFile).name;
    [windsond, readStatus] = readWindsond(dataDir, windsondFileName);
    if readStatus
        % were good here
    else
        fprintf('*** Problem reading windsond data ... exiting!\n')
        matFileName = [];
        status = 0;
        return
    end
    matFileName{iFile} = strrep(windsondFileName, '.sounding', '.mat');
    save([ dataDir matFileName{iFile} ], 'windsond')
end
status = 1;