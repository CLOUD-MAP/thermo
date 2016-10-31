function [iMetXQ, status] = readiMetXQ(dirName, fileName)
% =====================================================================
% readiMetXQ
% [iMetXQ, status] = readiMetXQ(dirName, fileName)
% =====================================================================
% Read data in the iMet format
% Inputs:
% dirName  = directory where data file exists
% fileName = name of the iMet data file
% Outputs
% iMetXQ   = structured array containing data
% status   = flag indiating status of read
% Created 2015-12-09 Phil Chilson
% Revision history

% =====================================================================
% Check if the file exists
% =====================================================================
if ~exist([dirName fileName], 'file')
    fprintf('*** readiMet: file not found ... exiting!\n')
    iMetXQ = [];
    status = 0;
    return
end

% =====================================================================
% Set the delimeter adn format structure
% =====================================================================
delimiter = ',';
formatSpec = '%s%f%f%f%s%s%f%f%f%f%[^\n\r]';

% =====================================================================
% Open and read the data
% =====================================================================
fileID = fopen([ dirName fileName ], 'r');
fprintf('Reading file: %s\n', [ dirName fileName ])
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

% =====================================================================
% Assign the parameters to the structured array
% =====================================================================
% must be a more elegant way to get the time
[procYear, ~, ~, ~, ~, ~] = datevec(now);
iMetXQ.obsTime = datenum(dataArray{:, 5}) + ...
    datenum(dataArray{:, 6}) - datenum(procYear, 1, 1);
iMetXQ.pressure_Pa = dataArray{:, 2};
iMetXQ.temperature_C = dataArray{:, 3}/1e2;
iMetXQ.humidity_perCent = dataArray{:, 4}/1e1;
iMetXQ.latitude_deg = dataArray{:, 7}/1e7;
iMetXQ.longitude_deg = dataArray{:, 8}/1e7;
iMetXQ.altitude_m = dataArray{:, 9}/1e3;
iMetXQ.nSatellites = dataArray{:, 10};
status = 1;