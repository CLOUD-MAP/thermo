function calibScript(procYear, procMonth, procDay, sensorType, offsetFlag, quickLookFlag)
% validScript: Used to validate sensors
% Function call:
% validScript(procYear, procMonth, procDay, sensorType, offsetFlag, quickLookFlag)

clc

%% User inputs
% Check the number of user inputs
switch nargin
    case 0
        % If no inputs, then we must prompt user
        DialogTitle = 'Enter the Data and sensor information';
        Prompt = { 'Year:', ...
            'Month:', ...
            'Day:', ...
            'Sensor (Windsond or iMet):', ...
            'offsetFlag (0 or 1 or blank):', ...
            'quickLookFlag (0 or 1 or blank):'};
        %
        LineNo = 1;
        %
        reply = inputdlg(Prompt, DialogTitle, LineNo);
        %
        procYear = str2double(reply{1});
        procMonth = str2double(reply{2});
        procDay = str2double(reply{3});
        sensorType = reply{4};
        if isempty(reply{5})
            offsetFlag = 0;
        else
            offsetFlag = reply{6};
        end
        if isempty(reply{6})
            quickLookFlag = 0;
        else
            quickLookFlag = reply{5};
        end
    case {1, 2, 3}
        % If the year, month, day, and sensor not specified, then exit
        fprintf('*** Insufficient inputs ... exiting!\n')
        return
    case 4
        % If inputs end after the sensor type , set offset and quicklook flags
        offsetFlag = 0;
        quickLookFlag = 0;
    case 5
        % if only offset flag set, set quicklook flag
        quickLookFlag = 0;
end

% check spelling of the sensor name
switch sensorType
    case {'Windsond', 'iMet'}
        % we're good here
    otherwise
        fprintf('*** Unknown sensor type specified. Should be Windsond or iMet ... exiting!\n')
        return
end

procStation = 'wash';
% set fetchFlag to 1 if mesonet data retrieved automatically (mac)
% set fetchFlag to 0 if you will download the file by hand (PC)
fetchFlag = 1;

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

%% Read in the data
% Create the directory of the matlab library and add it to the path
libDir = [ baseDir 'thermo' filesep 'matlab' filesep ]; 
addpath(libDir)

% Find the appropriate data directory based on instrument type
dataDirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

if quickLookFlag
    % Find the appropriate image directory based on instrument type
    imgDirName = sprintf('%sthermo%squickLooks%s%s%s%4.4d%s%2.2d%s%2.2d%s', ...
        baseDir, filesep, filesep, sensorType, filesep, ...
        procYear, filesep, procMonth, filesep, procDay, filesep);
    if ~exist(imgDirName, 'dir')
        mkdir(imgDirName)
    end
end

% Read the sensor data
switch sensorType
    case 'Windsond'
        % Interactively choose the file name
        % First see if files exist
        d = dir([ dataDirName '*.sounding' ]);
        if isempty(d)
            fprintf('*** File not available ... exiting!\n')
            return
        end
        [sensorFileName, dataDirName] = uigetfile([ dataDirName '*.sounding' ], 'Pick a data file or click Cancel to exit');
        if isequal(sensorFileName, 0) || isequal(dataDirName, 0)
            fprintf('*** Operation cancelled ... exiting!\n')
            return
        end
        [windsond, status] = readWindsond(dataDirName, sensorFileName);
        sensor = windsond;
    case 'iMet'
        % Interactively choose the file name
        % First see if files exist
        d = dir([ dataDirName '*.csv' ]);
        if isempty(d)
            fprintf('*** File not available ... exiting!\n')
            return
        end
        [sensorFileName, dataDirName] = uigetfile([ dataDirName '*.csv' ], 'Pick a data file or click Cancel to exit');
        if isequal(sensorFileName, 0) || isequal(dataDirName, 0)
            fprintf('*** Operation cancelled ... exiting!\n')
            return
        end
        [iMetXQ, status] = readiMetXQ(dataDirName, sensorFileName);
        sensor = iMetXQ;
end

% Check if the mts file available, if not, try to retrieve it
[mesoFileName, status] = getMtsFile(procYear, procMonth, procDay, ...
    procStation, fetchFlag, baseDir);

if status
    sensorType = 'Mesonet';
    if strcmp(procStation, 'nwcm');
        NWCFlag = true;
    else
        NWCFlag = false;
    end
    % Find the appropriate directory based on instrument type
    mesoDirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
    [mts, status] = readMTSData(mesoFileName, mesoDirName, NWCFlag);
end

% Remove the matlab library
rmpath(libDir)

%% Process the data
% Desired start and stop time (UTC) for plotting 
timeBeg = sensor.obsTime(1);
timeEnd = sensor.obsTime(end);

% Find the indices corresponding to the chosen ranges of time
indSensor = find(timeBeg <= sensor.obsTime & sensor.obsTime <= timeEnd);
indMeso = find(timeBeg <= mts.obsTime & mts.obsTime <= timeEnd);

% Check for missing data in mesonet files
mts.pressure_Pa(mts.pressure_Pa < -99) = NaN;
mts.temperature1p5m_C(mts.temperature1p5m_C < -99) = NaN;
mts.humidity_perCent(mts.humidity_perCent < -99) = NaN;

% average the sensor data to be consisent with the 1-minute NWC mesonet
% data
nVals = length(indMeso);
sensorObsTimeAvg = nan(1, nVals);
sensorPressureAvg_Pa = nan(1, nVals);
sensorTemperatureAvg_C = nan(1, nVals);
sensorHumidityAvg_perCent = nan(1, nVals);
for iVal = 1: nVals
    sensorObsTimeAvg(iVal) = mts.obsTime(indMeso(iVal));
    ind = find(sensorObsTimeAvg(iVal) - 1/60/24 <= sensor.obsTime & ...
        sensor.obsTime <= sensorObsTimeAvg(iVal));
    if isempty(ind)
        % we're good here
    else
        sensorPressureAvg_Pa(iVal) = nanmean(sensor.pressure_Pa(ind));
        sensorTemperatureAvg_C(iVal) = nanmean(sensor.temperature_C(ind));
        sensorHumidityAvg_perCent(iVal) = nanmean(sensor.humidity_perCent(ind));
    end
end

% ------------------------------------------
% Calculate the offsets

if offsetFlag
    % need values here for particular sensor ... set to 0 for now
    offsetPressure_Pa = 0;
    offsetTemperature_C = 0;
    offsetHumidity_perCent = 0;
else
    % set offsets to 0
    offsetPressure_Pa = 0;
    offsetTemperature_C = 0;
    offsetHumidity_perCent = 0;
end

%% Plot the data
fontSize = 12;
lineWidth = 1.5;
axisWidth = 1.5;
% --------------------------------------
figure(1)
% --------------------------------------
clf
plot(sensor.obsTime(indSensor), (sensor.pressure_Pa(indSensor) + offsetPressure_Pa)/100, 'r', ...
    'linewidth', lineWidth)
hold on
plot(sensorObsTimeAvg, (sensorPressureAvg_Pa + offsetPressure_Pa)/100, '*-b', 'linewidth', 2, ...
    'linewidth', lineWidth)
plot(mts.obsTime(indMeso), mts.pressure_Pa(indMeso)/100, '*-k', 'linewidth', 2, ...
    'linewidth', lineWidth)
hold off
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', axisWidth)
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
xlabel('Time UTC')
ylabel('Pressure (hPa)')
title(sensorFileName, 'interpreter', 'non')
shg
if quickLookFlag
    % Create the quick look plot
    ind = strfind(sensorFileName, '.');
    imgFileName = strrep(sensorFileName, sensorFileName(ind: end), '_pressure.png');
    print([ imgDirName imgFileName ], '-dpng')
end

% --------------------------------------
figure(2)
% --------------------------------------
clf
plot(sensor.obsTime(indSensor), sensor.temperature_C(indSensor) + offsetTemperature_C, 'r', ...
    'linewidth', lineWidth)
hold on
plot(sensorObsTimeAvg, sensorTemperatureAvg_C + offsetTemperature_C, '*-b', 'linewidth', 2, ...
    'linewidth', lineWidth)
plot(mts.obsTime(indMeso), mts.temperature9m_C(indMeso), '*-k', 'linewidth', 2, ...
    'linewidth', lineWidth)
hold off
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', axisWidth)
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
xlabel('Time UTC')
ylabel('Temperature (C)')
title(sensorFileName, 'interpreter', 'non')
shg
if quickLookFlag
    % Create the quick look plot
    ind = strfind(sensorFileName, '.');
    imgFileName = strrep(sensorFileName, sensorFileName(ind: end), '_temperature.png');
    print([ imgDirName imgFileName ], '-dpng')
end

% --------------------------------------
figure(3)
% --------------------------------------
clf
plot(sensor.obsTime(indSensor), sensor.humidity_perCent(indSensor) + offsetHumidity_perCent, 'r', ...
    'linewidth', lineWidth)
hold on
plot(sensorObsTimeAvg, sensorHumidityAvg_perCent + offsetHumidity_perCent, '*-b', 'linewidth', 2, ...
    'linewidth', lineWidth)
plot(mts.obsTime(indMeso), mts.humidity_perCent(indMeso), '*-k', 'linewidth', 2, ...
    'linewidth', lineWidth)
hold off
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', axisWidth)
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
xlabel('Time UTC')
ylabel('Relative Humidity (%)')
title(sensorFileName, 'interpreter', 'non')
shg
if quickLookFlag
    % Create the quick look plot
    ind = strfind(sensorFileName, '.');
    imgFileName = strrep(sensorFileName, sensorFileName(ind: end), '_relativeHumidty.png');
    print([ imgDirName imgFileName ], '-dpng')
end
