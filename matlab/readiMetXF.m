function [iMetXF, status] = readiMetXF(dirName, fileName)
% =====================================================================
% readiMetXF
% [iMetXF, status] = readiMetXF(dirName, fileName)
% =====================================================================
% Read data in data from the iMetXF
% Inputs:
% dirName  = directory where data file exists
% fileName = name of the iMet data file
% Outputs
% iMetXF = structured array containing data
% status   = flag indiating status of read
% Created 2016-09-03 Phil Chilson
% Revision history

% =====================================================================
% Check if the file exists
% =====================================================================
if ~exist([dirName fileName], 'file')
    fprintf('*** readiMetXF: file not found ... exiting!\n')
    iMetXF = [];
    status = 0;
    return
end

% =====================================================================
% Set the delimeter adn format structure
% =====================================================================
delimiter = ',';
startRow = 4;
% 00000000,2016/08/29,16:16:36.932244,0,2000,2013/09/01,00:00:02,+0000000000,+0000000000,-00017000,00,+097815,+2645,+0384,+2620,A,+1338,B,+1326,C,+1329,D,+1327
formatSpec = '%f%s%s%f%f%s%s%f%f%f%f%f%f%f%f%c%f%c%f%c%f%c%f%[^\n\r]';

% =====================================================================
% Open and read the data
% =====================================================================
fileID = fopen([ dirName fileName ], 'r');
fprintf('Reading file: %s\n', [ dirName fileName ])
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

iMetXF.obsTime = datenum(strcat(dataArray{:, 2}, dataArray{:, 3}), 'yyyy/mm/ddHH:MM:SS');
iMetXF.latitude_deg = 1e-7*dataArray{:, 8};
iMetXF.longitude_deg = 1e-7*dataArray{:, 9};
iMetXF.altitude_m = 1e-3*dataArray{:, 10};
iMetXF.nSatellites = dataArray{:, 11};
iMetXF.pressure_Pa = dataArray{:, 12};
iMetXF.relativeHumidity_perCent= 1e-1*dataArray{:, 14};
iMetXF.temperatureA_C = 1e-2*dataArray{:, 17};
iMetXF.temperatureB_C = 1e-2*dataArray{:, 19};
iMetXF.temperatureC_C = 1e-2*dataArray{:, 21};
iMetXF.temperatureD_C = 1e-2*dataArray{:, 23};
status = 1;