function calibScript(procYear, procMonth, procDay, sensorType)
% Description of the code
clc

%% User inputs
% Date and sensor information if not specified in function call
if nargin == 0
    DialogTitle = 'Enter the Data and sensor information';
    Prompt = { 'Year:', ...
        'Month:', ...
        'Day:', ...
        'Sensor (Windsond or iMet):' };
    %
    LineNo = 1;
    %
    reply = inputdlg(Prompt, DialogTitle, LineNo);
    %
    procYear = str2double(reply{1});
    procMonth = str2double(reply{2});
    procDay = str2double(reply{3});
    sensorType = reply{4};
end

procStation = 'nwcm';
% set fetchFlag to 1 if mesonet data retrieved automatically (mac)
% set fetchFlag to 0 if you will download the file by hand (PC)
fetchFlag = 1;

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';
libDirName = '/Users/chilson/Matlab/CLOUDMAP/thermo/matlab/';

%% Read in the data
% Create the directory of the matlab library and add it to the path
libDir = [ baseDir filesep 'thermo' filesep 'matlab' filesep ]; 
addpath(libDir)

% Find the appropriate directory based on instrument type
dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

% Read the sensor data
switch sensorType
    case 'Windsond'
        % Interactively choose the file name
        [fileName, dirName] = uigetfile([ dirName '*.sounding' ], 'Pick a data file');
        [windsond, status] = readWindsond(dirName, fileName);
        sensor = windsond;
    case 'iMet'
        % Interactively choose the file name
        [fileName, dirName] = uigetfile([ dirName '*.csv' ], 'Pick a data file');
        [iMetXQ, status] = readiMetXQ(dirName, fileName);
        sensor = iMetXQ;
end

% Check if the mts file available, if not, try to retrieve it
[fileName, status] = getMtsFile(procYear, procMonth, procDay, ...
    procStation, fetchFlag, baseDir);

if status
    sensorType = 'Mesonet';
    if strcmp(procStation, 'nwcm');
        NWCFlag = true;
    else
        NWCFlag = false;
    end
    % Find the appropriate directory based on instrument type
    dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
    [mts, status] = readMTSData(fileName, dirName, NWCFlag);
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

mts.temperature1p5m_C(mts.temperature1p5m_C < -99) = NaN;

%% Plot the data
figure(1)
clf
plot(sensor.obsTime(indSensor), sensor.pressure_Pa(indSensor)/100, 'r')
hold on
plot(mts.obsTime(indMeso), mts.pressure_Pa(indMeso)/100, 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
xlabel('Time UTC')
ylabel('Pressure (hPa)')
shg

figure(2)
clf
plot(sensor.obsTime(indSensor), sensor.temperature_C(indSensor), 'r')
hold on
plot(mts.obsTime(indMeso), mts.temperature1p5m_C(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
xlabel('Time UTC')
ylabel('Temperature (C)')
shg

figure(3)
clf
plot(sensor.obsTime(indSensor), sensor.humidity_perCent(indSensor), 'r')
hold on
plot(mts.obsTime(indMeso), mts.humidity_perCent(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
xlabel('Time UTC')
ylabel('Relative Humidity (%)')
shg