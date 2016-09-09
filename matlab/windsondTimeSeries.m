% This script is used to process windsond data
% You are asked to enter a flight number for a given day

%% Set up & user inputs
clear all
clc

% Enter date of flight
procYear = 2016;
procMonth = 6;
procDay = 29;

% Flag to decide if image file should be created
imgFlag = false;

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

%% Read in the data

% Create the directory of the matlab library and add it to the path
libDir = [ baseDir 'thermo' filesep 'matlab' filesep ];
addpath(libDir)

% Read the copter data
sensorType = 'iris+';
% Find the appropriate directory based on instrument type
dataDirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
inFileName = sprintf('%4.4d%2.2d%2.2d.mat', procYear, procMonth, procDay);
fprintf('Reading file: %s%s\n', dataDirName, inFileName)
load([ dataDirName inFileName ]);

% Read the sensor data
iFlight = input('Enter the flight number to process: ');
sensorType = 'Windsond';
% Find the appropriate directory based on instrument type
dataDirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
% Get the log file
logFileName = sprintf('%4.4d%2.2d%2.2d_log.txt', procYear, procMonth, procDay);
fp = fopen([ dataDirName logFileName ]);
while ~feof(fp);
    str = fgetl(fp);
    if strfind(str, '#Flight')
        logFlight = fscanf(fp, '%d', 1);
        nSensorFiles = fscanf(fp, '%d', 1);
        if logFlight == iFlight
            for iFile = 1: nSensorFiles
                sensorFileName{iFile} = fscanf(fp, '%s', 1);
            end
            break
        else
            for iFile = 1: nSensorFiles
                fgetl(fp);
            end
        end
    end
end

for iFile = 1: nSensorFiles
    [windsond, ~] = readWindsond(dataDirName, sensorFileName{iFile});
    windsondArr(iFile) = windsond;
end

nNans = 10; % arbitrarily chosen
for iFile = nSensorFiles + 1: 4
    windsondArr(iFile).obsTime = nan(1, nNans);
    windsondArr(iFile).battery_V = nan(1, nNans);
    windsondArr(iFile).pressure_Pa = nan(1, nNans);
    windsondArr(iFile).temperature_C = nan(1, nNans);
    windsondArr(iFile).humidity_perCent = nan(1, nNans);
    windsondArr(iFile).temperatureSensor_C = nan(1, nNans);
    windsondArr(iFile).latitude_deg = nan(1, nNans);
    windsondArr(iFile).longitude_deg = nan(1, nNans);
    windsondArr(iFile).altitude_m = nan(1, nNans);
    windsondArr(iFile).speed_mps = nan(1, nNans);
    windsondArr(iFile).heading_deg = nan(1, nNans);
end

% Remove the matlab library
rmpath(libDir)

%% Find the time range to be used processing - this is interactive

timeBeg = nanmin([windsondArr(1).obsTime(1) windsondArr(2).obsTime(1) windsondArr(3).obsTime(1) windsondArr(4).obsTime(1)]);
timeEnd = nanmax([windsondArr(1).obsTime(end) windsondArr(2).obsTime(end) windsondArr(3).obsTime(end) windsondArr(4).obsTime(end)]);
indGPS = find(timeBeg <= iris.obsTimeGPS & iris.obsTimeGPS <= timeEnd);
indBARO = find(timeBeg <= iris.obsTimeBARO & iris.obsTimeBARO <= timeEnd);
indATT = find(timeBeg <= iris.obsTimeATT & iris.obsTimeATT <= timeEnd);

figure(1)
clf
plot(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS))
xlabel('Time UTC')
ylabel('Iris GPS Height AGL (m)')
datetick('x', 13)
shg

fprintf('Click start and end time\n')
[x, ~] = ginput(2);
timeTakeoff = x(1);
timeLand = x(2);

fprintf('Takeoff Time (UTC): %s\n', datestr(timeTakeoff))
fprintf('Land Time (UTC): %s\n', datestr(timeLand))

%% Find the indices, times, and heights corresponding to the ascent and descent legs

indWindsond1 = find(timeTakeoff <= windsondArr(1).obsTime & windsondArr(1).obsTime <= timeLand);
indWindsond2 = find(timeTakeoff <= windsondArr(2).obsTime & windsondArr(2).obsTime <= timeLand);
indWindsond3 = find(timeTakeoff <= windsondArr(3).obsTime & windsondArr(3).obsTime <= timeLand);
indWindsond4 = find(timeTakeoff <= windsondArr(4).obsTime & windsondArr(4).obsTime <= timeLand);

procTime1 = windsondArr(1).obsTime(indWindsond1);
height1_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTime1);
procTime2 = windsondArr(2).obsTime(indWindsond2);
height2_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTime2);
procTime3 = windsondArr(3).obsTime(indWindsond3);
height3_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTime3);
procTime4 = windsondArr(4).obsTime(indWindsond4);
height4_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTime4);


%% Plot the data

lineWidth = 1;
% markerSize = 10;
% heightRange_m = [0 sampleHeights_m(end)];
% temperatureRange_C = [15 30];
% humidityRange_perCent = [0 100];
fontSize = 15;
plotLineWidth = 1.5;
dateTickType = 15;

figure(2)
clf
plot(windsondArr(1).obsTime(indWindsond1),  windsondArr(1).temperature_C(indWindsond1), ...
    'linewidth', lineWidth)
hold on
plot(windsondArr(2).obsTime(indWindsond2),  windsondArr(2).temperature_C(indWindsond2), ...
    'linewidth', lineWidth)
plot(windsondArr(3).obsTime(indWindsond3),  windsondArr(3).temperature_C(indWindsond3), ...
    'linewidth', lineWidth)
plot(windsondArr(4).obsTime(indWindsond4),  windsondArr(4).temperature_C(indWindsond4), ...
    'linewidth', lineWidth)
hold off
grid
datetick('x', dateTickType)
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', plotLineWidth)
temperatureRange_C = get(gca, 'ylim');
xlabel('Time UTC')
ylabel('Temperature (C)')
title(sprintf('%s - %s', datestr(timeTakeoff, dateTickType), datestr(timeLand, dateTickType)))
shg

if imgFlag
    imgFileName = sprintf('%4.4d%2.2d%2.2d_%2.2d_temperature.png', ...
        procYear, procMonth, procDay, iFlight);
    imgDirName = './imgs/';
    fprintf('Creating file: %s\n', imgFileName)
    print([ imgDirName imgFileName ], '-dpng')
end

figure(3)
clf
plot(windsondArr(1).obsTime(indWindsond1),  windsondArr(1).humidity_perCent(indWindsond1), ...
    'linewidth', lineWidth)
hold on
plot(windsondArr(2).obsTime(indWindsond2),  windsondArr(2).humidity_perCent(indWindsond2), ...
    'linewidth', lineWidth)
plot(windsondArr(3).obsTime(indWindsond3),  windsondArr(3).humidity_perCent(indWindsond3), ...
    'linewidth', lineWidth)
plot(windsondArr(4).obsTime(indWindsond4),  windsondArr(4).humidity_perCent(indWindsond4), ...
    'linewidth', lineWidth)
hold off
grid
datetick('x', dateTickType)
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', plotLineWidth)
timeRange = get(gca, 'xlim');
humidityRange_perCent = get(gca, 'ylim');
xlabel('Time UTC')
ylabel('Relative Humidity (percent)')
title(sprintf('%s - %s', datestr(timeTakeoff, dateTickType), datestr(timeLand, dateTickType)))
shg

if imgFlag
    imgFileName = sprintf('%4.4d%2.2d%2.2d_%2.2d_humidity.png', ...
        procYear, procMonth, procDay, iFlight);
    imgDirName = './imgs/';
    fprintf('Creating file: %s\n', imgFileName)
    print([ imgDirName imgFileName ], '-dpng')
end

figure(4)
clf
plot(procTime1, height1_m, 'linewidth', lineWidth)
hold on
plot(procTime2, height2_m, 'linewidth', lineWidth)
plot(procTime3, height3_m, 'linewidth', lineWidth)
plot(procTime4, height4_m, 'linewidth', lineWidth)
hold off
grid
datetick('x', dateTickType)
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', plotLineWidth)
xlabel('Time UTC')
ylabel('Height (m)')
title(sprintf('%s - %s', datestr(timeTakeoff, dateTickType), datestr(timeLand, dateTickType)))
shg

if imgFlag
    imgFileName = sprintf('%4.4d%2.2d%2.2d_%2.2d_humidity.png', ...
        procYear, procMonth, procDay, iFlight);
    imgDirName = './imgs/';
    fprintf('Creating file: %s\n', imgFileName)
    print([ imgDirName imgFileName ], '-dpng')
end