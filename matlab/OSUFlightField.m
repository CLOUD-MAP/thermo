% This script is used to process data from the CLOUDMAP Experiment in
% Stillwater during 2016
% You are asked to enter a flight number for a given day

%% Set up & user inputs
clear all
clc

% Enter date of flight
procYear = 2016;
procMonth = 6;
procDay = 29;

% Set the sampling height parameters for averaging
lowerHeight_m = 5;
upperHeight_m = 300;
deltaHeight_m = 5;

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
dataDirName = getDataDir(procYear, procMonth, procDay, sensorType);
inFileName = sprintf('%4.4d%2.2d%2.2d.mat', procYear, procMonth, procDay);
fprintf('Reading file: %s%s\n', dataDirName, inFileName)
load([ dataDirName inFileName ]);

% Read the sensor data
iFlight = input('Enter the flight number to process: ');
sensorType = 'Windsond';
% Find the appropriate directory based on instrument type
dataDirName = getDataDir(procYear, procMonth, procDay, sensorType);
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

fprintf('Click start, max, and end time\n')
[x, ~] = ginput(3);
timeTakeoff = x(1);
timeMax = x(2);
timeLand = x(3);
if (timeMax < timeBeg || timeMax > timeEnd), timeMax = nan; end

fprintf('Takeoff Time (UTC): %s\n', datestr(timeTakeoff))
fprintf('Land Time (UTC): %s\n', datestr(timeLand))

%% Find the indices, times, and heights corresponding to the ascent and descent legs

indWindsondAsc1 = find(timeTakeoff <= windsondArr(1).obsTime & windsondArr(1).obsTime <= timeMax);
indWindsondAsc2 = find(timeTakeoff <= windsondArr(2).obsTime & windsondArr(2).obsTime <= timeMax);
indWindsondAsc3 = find(timeTakeoff <= windsondArr(3).obsTime & windsondArr(3).obsTime <= timeMax);
indWindsondAsc4 = find(timeTakeoff <= windsondArr(4).obsTime & windsondArr(4).obsTime <= timeMax);

procTimeAsc1 = windsondArr(1).obsTime(indWindsondAsc1);
heightAsc1_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeAsc1);
procTimeAsc2 = windsondArr(2).obsTime(indWindsondAsc2);
heightAsc2_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeAsc2);
procTimeAsc3 = windsondArr(3).obsTime(indWindsondAsc3);
heightAsc3_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeAsc3);
procTimeAsc4 = windsondArr(4).obsTime(indWindsondAsc4);
heightAsc4_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeAsc4);

indWindsondDes1 = find(timeMax <= windsondArr(1).obsTime & windsondArr(1).obsTime <= timeLand);
indWindsondDes2 = find(timeMax <= windsondArr(2).obsTime & windsondArr(2).obsTime <= timeLand);
indWindsondDes3 = find(timeMax <= windsondArr(3).obsTime & windsondArr(3).obsTime <= timeLand);
indWindsondDes4 = find(timeMax <= windsondArr(4).obsTime & windsondArr(4).obsTime <= timeLand);

procTimeDes1 = windsondArr(1).obsTime(indWindsondDes1);
heightDes1_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeDes1);
procTimeDes2 = windsondArr(2).obsTime(indWindsondDes2);
heightDes2_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeDes2);
procTimeDes3 = windsondArr(3).obsTime(indWindsondDes3);
heightDes3_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeDes3);
procTimeDes4 = windsondArr(4).obsTime(indWindsondDes4);
heightDes4_m = interp1(iris.obsTimeGPS(indGPS), iris.altitudeGPS_m(indGPS), procTimeDes4);

sampleHeights_m = lowerHeight_m: deltaHeight_m: upperHeight_m;
nHeights = length(sampleHeights_m);
% temperature
temperatureAvgAsc1_C = nan(1, nHeights);
temperatureAvgAsc2_C = nan(1, nHeights);
temperatureAvgAsc3_C = nan(1, nHeights);
temperatureAvgAsc4_C = nan(1, nHeights);
temperatureAvgDes1_C = nan(1, nHeights);
temperatureAvgDes2_C = nan(1, nHeights);
temperatureAvgDes3_C = nan(1, nHeights);
temperatureAvgDes4_C = nan(1, nHeights);
% humidity
humidityAvgAsc1_perCent = nan(1, nHeights);
humidityAvgAsc2_perCent = nan(1, nHeights);
humidityAvgAsc3_perCent = nan(1, nHeights);
humidityAvgAsc4_perCent = nan(1, nHeights);
humidityAvgDes1_perCent = nan(1, nHeights);
humidityAvgDes2_perCent = nan(1, nHeights);
humidityAvgDes3_perCent = nan(1, nHeights);
humidityAvgDes4_perCent = nan(1, nHeights);

for iHeight = 1: nHeights
    ind1 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightAsc1_m & ...
        heightAsc1_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    ind2 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightAsc2_m & ...
        heightAsc2_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    ind3 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightAsc3_m & ...
        heightAsc3_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    ind4 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightAsc4_m & ...
        heightAsc4_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    temperatureAvgAsc1_C(iHeight) = nanmean(windsondArr(1).temperature_C(indWindsondAsc1(ind1)));
    temperatureAvgAsc2_C(iHeight) = nanmean(windsondArr(2).temperature_C(indWindsondAsc2(ind2)));
    temperatureAvgAsc3_C(iHeight) = nanmean(windsondArr(3).temperature_C(indWindsondAsc3(ind3)));
    temperatureAvgAsc4_C(iHeight) = nanmean(windsondArr(4).temperature_C(indWindsondAsc4(ind4)));
    humidityAvgAsc1_perCent(iHeight) = nanmean(windsondArr(1).humidity_perCent(indWindsondAsc1(ind1)));
    humidityAvgAsc2_perCent(iHeight) = nanmean(windsondArr(2).humidity_perCent(indWindsondAsc2(ind2)));
    humidityAvgAsc3_perCent(iHeight) = nanmean(windsondArr(3).humidity_perCent(indWindsondAsc3(ind3)));
    humidityAvgAsc4_perCent(iHeight) = nanmean(windsondArr(4).humidity_perCent(indWindsondAsc4(ind4)));
    ind1 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightDes1_m & ...
        heightDes1_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    ind2 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightDes2_m & ...
        heightDes2_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    ind3 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightDes3_m & ...
        heightDes3_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    ind4 = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightDes4_m & ...
        heightDes4_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    temperatureAvgDes1_C(iHeight) = nanmean(windsondArr(1).temperature_C(indWindsondDes1(ind1)));
    temperatureAvgDes2_C(iHeight) = nanmean(windsondArr(2).temperature_C(indWindsondDes2(ind2)));
    temperatureAvgDes3_C(iHeight) = nanmean(windsondArr(3).temperature_C(indWindsondDes3(ind3)));
    temperatureAvgDes4_C(iHeight) = nanmean(windsondArr(4).temperature_C(indWindsondDes4(ind4)));
    humidityAvgDes1_perCent(iHeight) = nanmean(windsondArr(1).humidity_perCent(indWindsondDes1(ind1)));
    humidityAvgDes2_perCent(iHeight) = nanmean(windsondArr(2).humidity_perCent(indWindsondDes2(ind2)));
    humidityAvgDes3_perCent(iHeight) = nanmean(windsondArr(3).humidity_perCent(indWindsondDes3(ind3)));
    humidityAvgDes4_perCent(iHeight) = nanmean(windsondArr(4).humidity_perCent(indWindsondDes4(ind4)));
end

%% Plot the data

lineWidth = 1;
markerSize = 10;
heightRange_m = [0 sampleHeights_m(end)];
temperatureRange_C = [15 30];
humidityRange_perCent = [0 100];
fontSize = 15;
plotLineWidth = 1.5;

figure(2)
clf
plot(temperatureAvgAsc1_C, sampleHeights_m, '-^r', ...
    'linewidth', lineWidth, 'markersize', markerSize)
hold on
plot(temperatureAvgAsc2_C, sampleHeights_m, '-^b', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(temperatureAvgAsc3_C, sampleHeights_m, '-^k', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(temperatureAvgAsc4_C, sampleHeights_m, '-^g', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(temperatureAvgDes1_C, sampleHeights_m, '-vr', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(temperatureAvgDes2_C, sampleHeights_m, '-vb', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(temperatureAvgDes3_C, sampleHeights_m, '-vk', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(temperatureAvgDes4_C, sampleHeights_m, '-vg', ...
    'linewidth', lineWidth, 'markersize', markerSize)
hold off
set(gca, 'xlim', temperatureRange_C)
set(gca, 'ylim', heightRange_m)
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', plotLineWidth)
xlabel('Temperature (C)')
ylabel('Iris GPS Height AGL (m)')
title(sprintf('%s - %s', datestr(timeTakeoff, 13), datestr(timeLand, 13)))
shg

imgFileName = sprintf('%4.4d%2.2d%2.2d_%2.2d_temperature.png', ...
    procYear, procMonth, procDay, iFlight);
imgDirName = './imgs/';
fprintf('Creating file: %s\n', imgFileName)
print([ imgDirName imgFileName ], '-dpng')

figure(3)
clf
plot(humidityAvgAsc1_perCent, sampleHeights_m, '-^r', ...
    'linewidth', lineWidth, 'markersize', markerSize)
hold on
plot(humidityAvgAsc2_perCent, sampleHeights_m, '-^b', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(humidityAvgAsc3_perCent, sampleHeights_m, '-^k', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(humidityAvgAsc4_perCent, sampleHeights_m, '-^g', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(humidityAvgDes1_perCent, sampleHeights_m, '-vr', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(humidityAvgDes2_perCent, sampleHeights_m, '-vb', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(humidityAvgDes3_perCent, sampleHeights_m, '-vk', ...
    'linewidth', lineWidth, 'markersize', markerSize)
plot(humidityAvgDes4_perCent, sampleHeights_m, '-vg', ...
    'linewidth', lineWidth, 'markersize', markerSize)
hold off
set(gca, 'xlim', humidityRange_perCent)
set(gca, 'ylim', heightRange_m)
set(gca, 'fontsize', fontSize)
set(gca, 'linewidth', plotLineWidth)
xlabel('Relative Humidity (percent)')
ylabel('Iris GPS Height AGL (m)')
title(sprintf('%s - %s', datestr(timeTakeoff, 13), datestr(timeLand, 13)))
shg

imgFileName = sprintf('%4.4d%2.2d%2.2d_%2.2d_humidity.png', ...
    procYear, procMonth, procDay, iFlight);
imgDirName = './imgs/';
fprintf('Creating file: %s\n', imgFileName)
print([ imgDirName imgFileName ], '-dpng')
