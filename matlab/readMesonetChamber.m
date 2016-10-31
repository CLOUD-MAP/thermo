function [mesonetChamber, status] = readMesonetChamber(dirName, fileName)
% =====================================================================
% readMesonetChamber
% [mesonetChamber, status] = readMesonetChamber(dirName, fileName)
% =====================================================================
% Read data in data from the Mesonet Chamber (datalogger format)
% Inputs:
% dirName  = directory where data file exists
% fileName = name of the iMet data file
% Outputs
% mesonetChamber = structured array containing data
% status   = flag indiating status of read
% Created 2016-09-03 Phil Chilson
% Revision history

% =====================================================================
% Check if the file exists
% =====================================================================
if ~exist([dirName fileName], 'file')
    fprintf('*** readMesonetChamber: file not found ... exiting!\n')
    mesonetChamber = [];
    status = 0;
    return
end

% =====================================================================
% Set the delimeter adn format structure
% =====================================================================
delimiter = ',';
startRow = 5;
formatSpec = '%q%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

% =====================================================================
% Open and read the data
% =====================================================================
fileID = fopen([ dirName fileName ], 'r');
fprintf('Reading file: %s\n', [ dirName fileName ])
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

% =====================================================================
% Assign the parameters to the structured array
% =====================================================================
mesonetChamber.obsTime = datenum(dataArray{:, 1}, 'yyyy-mm-dd HH:MM:SS');
mesonetChamber.record = dataArray{:, 2};
mesonetChamber.temperatureFluke5615_C = dataArray{:, 3};
mesonetChamber.temperatureFluke5610_C = dataArray{:, 4};
mesonetChamber.temperatureRMY41342_C = dataArray{:, 5};
mesonetChamber.temperatureFastTherm_C = dataArray{:, 6};
mesonetChamber.relativeHumidityHMP155A_perCent = dataArray{:, 7};
mesonetChamber.temperatureHMP155A_C = dataArray{:, 8};
mesonetChamber.dewpointTemperatureHMP155A_C = dataArray{:, 9};
mesonetChamber.voltageP12V_V = dataArray{:, 10};
mesonetChamber.scanTime_s = dataArray{:, 11};
status = 1;

% 1. Date Time
% 2. Record #
% 3. Fluke_5615  (PRT Primary Reference)
% 4. Fluke_5610 (Thermistor Secondary Reference)
% 5. PRT_RMY_STN (RM Young 41342 PRT #19920 which is included in every calibration run)
% 6. FASTTHERM (#98848 which is included in every calibration run)
% 7. CHAMBER_RH (HMP155A #L1310896)
% 8. CHAMBER_TEMP (HMP155A #L1310896)
% 9. CHAMBER_DEWP (Calculated from CHAMBER_RH and CHAMBER_TEMP)
% 10. P12V (Datalogger Power Supply Voltage)
% 11. STIME (Measurement Scan Time in Seconds)


% TIMESTAMP = dataArray{:, 1};
% RECORD = dataArray{:, 2};
% FLUKE_5615 = dataArray{:, 3};
% FLUKE_5610 = dataArray{:, 4};
% PRT_RMY_STN = dataArray{:, 5};
% FASTTHERM = dataArray{:, 6};
% CHAMBER_RH = dataArray{:, 7};
% CHAMBER_TEMP = dataArray{:, 8};
% CHAMBER_DEWP = dataArray{:, 9};
% P12V = dataArray{:, 10};
% STIME = dataArray{:, 11};
