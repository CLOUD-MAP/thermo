function [matFileName, dataDir, status] = iMet2mat(procYear, ...
    procMonth, procDay, baseDir)
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
        matFileName = [];
        status = 0;
        return
    end
    matFileName{iFile} = strrep(iMetFileName, '.csv', '.mat');
    save([ dataDir matFileName{iFile} ], 'dataXQ')
end
status = 1;