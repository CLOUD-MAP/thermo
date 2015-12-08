function [matFileName, dataDir, status] = mts2mat(procYear, ...
    procMonth, procDay, procStation, batchFlag, baseDir)
% 

% Set up the inputs
sensorType = 'Mesonet';

% Create the directory using the file separators appropriate for your OS
dataDir = sprintf('%sthermo%sdata%s%s%s%4.4d%s%2.2d%s%2.2d%s', ...
    baseDir, filesep, filesep, sensorType, filesep, ...
    procYear, filesep, procMonth, filesep, procDay, filesep);

% This allows you to grab the data automatically from the mesonet site, but
% it requires the CURL library. If you are using a PC then you will need to
% download the file by hand and place it in the appropriate directory
if batchFlag
    getStatus = getMesoFileCURL(procYear, procMonth, ...
        procDay, procStation, dataDir);
    if getStatus ~= 1
        fprintf('*** Problem getting mesonet data ... exiting!\n')
        status = 0;
        return
    end
end

% Read in the data file and create a matlab structured array
mesoFileName = sprintf('%4.4d%2.2d%2.2d%s.mts', procYear, procMonth, procDay, procStation);
if exist([ dataDir mesoFileName ], 'file')
    [mts, readStatus] = readMTSData(mesoFileName, dataDir);
    if ~readStatus
        status = 0;
    end
else
    fprintf('searching for %s\n', [ dataDir fileName ])
    fprintf('*** Data file not found ... exiting!\n')
    status = 0;
    return
end

% Save mts as a mat file
matFileName = sprintf('%4.4d%2.2d%2.2d%s.mat', procYear, procMonth, procDay, procStation);
save([ dataDir matFileName ], 'mts')

status = 1;